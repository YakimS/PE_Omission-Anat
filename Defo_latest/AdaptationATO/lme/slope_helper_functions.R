# Helper functions for LME slope analysis
# Source this file in LME_slope.Rmd

plot_lmer_interaction <- function(model, x_var, color_var, y_var, save_path = NULL, width = 8, height = 6) {
  require(ggplot2)
  require(effects)

  pred_data <- as.data.frame(Effect(c(color_var, x_var), model))

  p <- ggplot(pred_data, aes_string(x = x_var, y = "fit", color = color_var, group = color_var)) +
    geom_line(size = 1) +
    geom_ribbon(aes_string(ymin = "lower", ymax = "upper", fill = color_var), alpha = 0.2) +
    theme_minimal() +
    labs(x = x_var, y = y_var, color = color_var, fill = color_var) +
    theme(legend.position = "bottom", panel.grid.minor = element_blank())

  if (!is.null(save_path)) {
    ggsave(save_path, p, width = width, height = height, dpi = 300)
  }

  return(p)
}

cv_lmer <- function(formula, data, k=5, response_var) {
  set.seed(123)
  folds <- createFolds(1:nrow(data), k=k)
  mse <- numeric(k)

  for(i in 1:k) {
    train <- data[-folds[[i]], ]
    test <- data[folds[[i]], ]
    fit <- lmer(formula, data=train)
    pred <- predict(fit, newdata=test, allow.new.levels=TRUE)
    mse[i] <- mean((test[[response_var]] - pred)^2, na.rm=TRUE)
  }
  return(mean(mse))
}

fit_step_models <- function(data, component, stage) {
  # Define all possible step models (between positions 1-2, 2-3, 3-4)
  data$step_12 <- factor(ifelse(data$trial_pos_num >= 2, "post", "pre"))
  data$step_23 <- factor(ifelse(data$trial_pos_num >= 3, "post", "pre"))
  data$step_34 <- factor(ifelse(data$trial_pos_num >= 4, "post", "pre"))

  # Create step models
  model_step_12 <- lmer(amplitude ~ step_12 + (1|sub), data = data)
  model_step_23 <- lmer(amplitude ~ step_23 + (1|sub), data = data)
  model_step_34 <- lmer(amplitude ~ step_34 + (1|sub), data = data)

  # Compare models
  models <- list(step_12 = model_step_12, step_23 = model_step_23, step_34 = model_step_34)

  # Calculate BIC
  bic_values <- sapply(models, BIC)

  # Find best model based on BIC
  best_step_model_name <- names(models)[which.min(bic_values)]
  best_step_model <- models[[best_step_model_name]]

  # Calculate mean values by group to determine step direction
  if (best_step_model_name == "step_12") {
    pre_values <- data$amplitude[data$step_12 == "pre"]
    post_values <- data$amplitude[data$step_12 == "post"]
    pre_mean <- mean(pre_values, na.rm = TRUE)
    post_mean <- mean(post_values, na.rm = TRUE)
    step_size <- post_mean - pre_mean
    step_p <- summary(best_step_model)$coefficients[2, 5]
    step_location <- "12"
  } else if (best_step_model_name == "step_23") {
    pre_values <- data$amplitude[data$step_23 == "pre"]
    post_values <- data$amplitude[data$step_23 == "post"]
    pre_mean <- mean(pre_values, na.rm = TRUE)
    post_mean <- mean(post_values, na.rm = TRUE)
    step_size <- post_mean - pre_mean
    step_p <- summary(best_step_model)$coefficients[2, 5]
    step_location <- "23"
  } else if (best_step_model_name == "step_34") {
    pre_values <- data$amplitude[data$step_34 == "pre"]
    post_values <- data$amplitude[data$step_34 == "post"]
    pre_mean <- mean(pre_values, na.rm = TRUE)
    post_mean <- mean(post_values, na.rm = TRUE)
    step_size <- post_mean - pre_mean
    step_p <- summary(best_step_model)$coefficients[2, 5]
    step_location <- "34"
  }

  return(list(
    best_model = best_step_model,
    best_model_name = best_step_model_name,
    step_location = step_location,
    step_size = step_size,
    step_p = step_p,
    bic_values = bic_values,
    pre_mean = pre_mean,
    post_mean = post_mean
  ))
}

compare_models <- function(data, component, stage) {
  # Fit linear trend model
  model_linear <- lmer(amplitude ~ trial_pos_num + (1|sub), data = data)

  # Fit step function models
  step_results <- fit_step_models(data, component, stage)

  # Calculate metrics for linear model
  linear_bic <- BIC(model_linear)
  linear_slope <- fixef(model_linear)["trial_pos_num"]
  linear_p <- summary(model_linear)$coefficients["trial_pos_num", "Pr(>|t|)"]

  # Compare best step model with linear model
  anova_result <- anova(model_linear, step_results$best_model)
  p_value <- anova_result$`Pr(>Chisq)`[2]

  # Calculate BIC-based Bayes Factor (approximation)
  bf_step_vs_linear <- exp((BIC(model_linear) - BIC(step_results$best_model))/2)

  # Determine better model based on BIC
  if (linear_bic < min(step_results$bic_values)) {
    better_model <- "linear"
  } else {
    better_model <- "step"
  }

  # Return comprehensive results
  return(list(
    component = component,
    stage = stage,
    n_subjects = length(unique(data$sub)),
    n_observations = nrow(data),
    linear_model = list(
      model = model_linear,
      bic = linear_bic,
      slope = linear_slope,
      p_value = linear_p
    ),
    step_model = list(
      model = step_results$best_model,
      model_name = step_results$best_model_name,
      bic = min(step_results$bic_values),
      step_location = step_results$step_location,
      step_size = step_results$step_size,
      p_value = step_results$step_p,
      pre_mean = step_results$pre_mean,
      post_mean = step_results$post_mean
    ),
    model_comparison = list(
      better_model = better_model,
      p_value = p_value,
      bf_step_vs_linear = bf_step_vs_linear
    )
  ))
}

create_summary_table <- function(results_list) {
  summary_df <- data.frame(
    Component = character(),
    Stage = character(),
    N_Subjects = integer(),
    N_Observations = integer(),
    Better_Model = character(),
    Linear_Slope = numeric(),
    Linear_P = numeric(),
    Step_Location = character(),
    Step_Size = numeric(),
    Step_P = numeric(),
    Linear_BIC = numeric(),
    Step_BIC = numeric(),
    Comparison_P = numeric(),
    BF_Step_vs_Linear = numeric(),
    stringsAsFactors = FALSE
  )

  for (result in results_list) {
    new_row <- data.frame(
      Component = result$component,
      Stage = result$stage,
      N_Subjects = result$n_subjects,
      N_Observations = result$n_observations,
      Better_Model = result$model_comparison$better_model,
      Linear_Slope = result$linear_model$slope,
      Linear_P = result$linear_model$p_value,
      Step_Location = result$step_model$step_location,
      Step_Size = result$step_model$step_size,
      Step_P = result$step_model$p_value,
      Linear_BIC = result$linear_model$bic,
      Step_BIC = result$step_model$bic,
      Comparison_P = result$model_comparison$p_value,
      BF_Step_vs_Linear = result$model_comparison$bf_step_vs_linear,
      stringsAsFactors = FALSE
    )

    summary_df <- rbind(summary_df, new_row)
  }

  return(summary_df)
}

plot_winning_model <- function(data_list, component, results_list, output_dir) {
  plot_list <- list()

  for (i in seq_along(data_list)) {
    stage_data <- data_list[[i]]
    stage_name <- names(data_list)[i]

    if (nrow(stage_data) > 0) {
      # Calculate mean and se for plotting
      plot_data <- stage_data %>%
        group_by(trial_pos_num) %>%
        summarise(
          mean_amp = mean(amplitude, na.rm = TRUE),
          se = sd(amplitude, na.rm = TRUE) / sqrt(n()),
          n = n()
        )

      # Create base plot with data points only (no model overlay yet)
      p <- ggplot(plot_data, aes(x = trial_pos_num, y = mean_amp)) +
        geom_point(size = 3) +
        geom_errorbar(aes(ymin = mean_amp - se, ymax = mean_amp + se), width = 0.2) +
        geom_line(linetype = "dashed", color = "gray50") +
        theme_minimal() +
        labs(
          title = paste("Component:", component, "- Stage:", stage_name),
          x = "Tone Repetition Position",
          y = "Mean Amplitude (µV)",
          caption = paste("N =", length(unique(stage_data$sub)), "subjects")
        )

      # Add winning model line ONLY if available in results
      if (stage_name %in% names(results_list)) {
        result <- results_list[[stage_name]]
        better_model <- result$model_comparison$better_model

        if (better_model == "linear") {
          # Get linear model parameters
          intercept <- fixef(result$linear_model$model)[1]
          slope <- fixef(result$linear_model$model)[2]

          # Create linear trend line data
          model_data <- data.frame(
            trial_pos_num = 1:4,
            predicted = intercept + slope * (1:4)
          )

          # Add ONLY linear trend line to plot
          p <- p +
            geom_line(data = model_data, aes(x = trial_pos_num, y = predicted),
                      color = "blue", size = 1) +
            labs(subtitle = paste("Best model: Linear trend, Slope =",
                                  round(slope, 3),
                                  ", p =", format.pval(result$linear_model$p_value, digits=2),
                                  ", BF =", format(1/result$model_comparison$bf_step_vs_linear, digits=2, scientific=TRUE)))
        }
        else if (better_model == "step") {
          # Get step model parameters
          step_loc <- result$step_model$step_location

          # Create step function data
          if (step_loc == "12") {
            model_data <- data.frame(
              trial_pos_num = 1:4,
              predicted = c(result$step_model$pre_mean,
                            rep(result$step_model$post_mean, 3))
            )
          } else if (step_loc == "23") {
            model_data <- data.frame(
              trial_pos_num = 1:4,
              predicted = c(rep(result$step_model$pre_mean, 2),
                            rep(result$step_model$post_mean, 2))
            )
          } else if (step_loc == "34") {
            model_data <- data.frame(
              trial_pos_num = 1:4,
              predicted = c(rep(result$step_model$pre_mean, 3),
                            result$step_model$post_mean)
            )
          }

          # Add ONLY step function line to plot
          p <- p +
            geom_line(data = model_data, aes(x = trial_pos_num, y = predicted),
                      color = "red", size = 1) +
            labs(subtitle = paste("Best model: Step function between tones",
                                  substr(step_loc, 1, 1), "and", substr(step_loc, 2, 2),
                                  ", Step size =", round(result$step_model$step_size, 3),
                                  ", p =", format.pval(result$step_model$p_value, digits=2),
                                  ", BF =", format(result$model_comparison$bf_step_vs_linear, digits=2, scientific=TRUE)))
        }
      }

      plot_list[[stage_name]] <- p
    }
  }

  # Save combined plot
  if (length(plot_list) > 0) {
    combined_plot <- do.call(gridExtra::grid.arrange, c(plot_list, ncol = 2))
    ggsave(paste0(output_dir, "\\slope_", component, "_winning_models.png"), combined_plot, width = 12, height = 10)
  }

  return(plot_list)
}

write_detailed_results <- function(results, component, output_dir) {
  output_file <- paste0(output_dir, "\\slope_", component, "_step_vs_linear_analysis.txt")

  sink(output_file)

  cat("==============================================================\n")
  cat(paste0("COMPONENT: ", component, " - STEP VS LINEAR ANALYSIS\n"))
  cat("==============================================================\n\n")

  for (result in results) {
    cat(paste0("SLEEP STAGE: ", result$stage, "\n"))
    cat(paste0("Number of subjects: ", result$n_subjects, "\n"))
    cat(paste0("Number of observations: ", result$n_observations, "\n\n"))

    cat("MODEL COMPARISON:\n")
    cat(paste0("Better model: ", toupper(result$model_comparison$better_model), "\n"))
    cat(paste0("Model comparison p-value: ", format(result$model_comparison$p_value, digits=4), "\n"))
    cat(paste0("BF (Step vs Linear): ", format(result$model_comparison$bf_step_vs_linear, digits=4), "\n\n"))

    cat("LINEAR TREND MODEL:\n")
    cat(paste0("Slope: ", format(result$linear_model$slope, digits=4), "\n"))
    cat(paste0("P-value: ", format(result$linear_model$p_value, digits=4), "\n"))
    cat(paste0("BIC: ", format(result$linear_model$bic, digits=4), "\n\n"))

    cat("BEST STEP MODEL:\n")
    cat(paste0("Model type: ", result$step_model$model_name, "\n"))
    if (!is.na(result$step_model$step_location)) {
      cat(paste0("Step location: Between tones ",
                substr(result$step_model$step_location, 1, 1),
                " and ",
                substr(result$step_model$step_location, 2, 2), "\n"))
      cat(paste0("Step size: ", format(result$step_model$step_size, digits=4), "\n"))
      cat(paste0("Step p-value: ", format(result$step_model$p_value, digits=4), "\n"))
    }
    cat(paste0("BIC: ", format(result$step_model$bic, digits=4), "\n\n"))

    cat("-----------------------------------------------------------\n\n")
  }

  sink()

  cat(paste0("Detailed results for component ", component, " written to ", output_file, "\n"))
}
