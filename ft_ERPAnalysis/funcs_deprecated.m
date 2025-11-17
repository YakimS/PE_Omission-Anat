
        %%%%%%%%%%%%%%%%%%%% Componenets Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function lme_comp(fa, components, sovs, conds, plot_comp_mean_over_conds,elctrds_clusts,folder)
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electdLabel = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect_label');
                % get avg data to plot
                 [comps,~] = fa.get_comp_plot(fa, sovs, fa.imp.subs,conds, components,plot_comp_mean_over_conds,clust_electdLabel);

                 fieldnames_comps = fieldnames(comps);
                 for comp_i =1:numel(fieldnames_comps)
                     data = table([], [], [], [], 'VariableNames', {'sub', 'sov','cond', 'comp_amp'});
                     curr_comp = comps.(fieldnames_comps{comp_i});
                     curr_comp_name = fieldnames_comps{comp_i};
                     fieldnames_sovs = fieldnames(curr_comp);
                     for sov_i =1:numel(fieldnames_sovs)
                        curr_sov = curr_comp.(fieldnames_sovs{sov_i});
                        curr_sov_name = fieldnames_sovs{sov_i};
                        fieldnames_subs = fieldnames(curr_sov);
                        for sub_i =1:numel(fieldnames_subs)
                            curr_sub = curr_sov.(fieldnames_subs{sub_i});
                            curr_sub_name = fieldnames_subs{sub_i};
                            fieldnames_conds = fieldnames(curr_sub);
                            for cond_i =1:numel(fieldnames_conds)
                                curr_cond = curr_sub.(fieldnames_conds{cond_i});
                                curr_cond_name = fieldnames_conds{cond_i};
                                newRow = table({curr_sub_name}, {curr_sov_name}, {curr_cond_name}, curr_cond.amplitude, ...
                                    'VariableNames', {'sub', 'sov','cond', 'comp_amp'});
                                data = [data; newRow];
                            end
                        end
                     end

                    filename = sprintf("LME_%s.txt",curr_comp_name);
                    filepath = fullfile(folder, filename);
                    fileID = fopen(filepath, 'w');

                     % Test the normality of the comp_amp variable
                    [h, p] = swtest(data.comp_amp);
                    if h == 0
                        fprintf(fileID,'Shapiro-Wilk Test: Data is normally distributed (p = %.4f).\n', p);
                    else
                        fprintf(fileID,'Shapiro-Wilk Test: Data is NOT normally distributed (p = %.4f).\n', p);
                    end
                    % Using Lilliefors test (Kolmogorov-Smirnov test with estimated parameters)
                    [h, p] = lillietest(data.comp_amp);
                    
                    if h == 0
                        fprintf(fileID,'Lilliefors Test: Data is normally distributed (p = %.4f).\n', p);
                    else
                        fprintf(fileID,'Lilliefors Test: Data is NOT normally distributed (p = %.4f).\n', p);
                    end
                    % Test normality of comp_amp variable using kstest
                    [h, p] = kstest((data.comp_amp - mean(data.comp_amp)) / std(data.comp_amp));
                    
                    if h == 0
                        fprintf(fileID,'Kolmogorov-Smirnov Test: Data is normally distributed (p = %.4f).\n', p);
                    else
                        fprintf(fileID,'Kolmogorov-Smirnov Test: Data is NOT normally distributed (p = %.4f).\n', p);
                    end

                    writetable(data, sprintf('%s//%s_dataToR.csv',folder,curr_comp_name));

%                     % Example: Remove outliers manually
%                     zscore_thresh= 3;
%                     z_scores = abs(zscore(data.comp_amp));  % Calculate z-scores for comp_amp
%                     data_outlired = data(z_scores < zscore_thresh, :);  % Keep only data within the threshold
% 
%                     % Check if shifting is necessary
%                     min_value = min(data_outlired.comp_amp);
%                     if min_value <= 0
%                         shift_amount = abs(min_value) + 1;  % Ensure all values are positive
%                         data_outlired.comp_amp = data_outlired.comp_amp + shift_amount;
%                     end
% % 
%                     h0_formula = "comp_amp ~ 1 + (1|sub)";
%                     glme_gamma = fitglme(data_outlired, h0_formula, 'Distribution', 'Gamma', 'Link', 'log');
%                     fitted_vals = fitted(glme_gamma);  % Adjust to match your GLMM object
%                     residuals = residuals(glme_gamma);
%                     
%                     % Plot residuals against fitted values
%                     figure; plot(fitted_vals, residuals, 'o'); title('Residuals vs Fitted Values'); xlabel('Fitted Values');ylabel('Residuals');
%                     % Q-Q plot for residuals
%                     figure; qqplot(residuals); title('Q-Q Plot of Residuals');
% 
%                     h0_formula = "comp_amp ~ 1 + (1|sub)";
%                     lme_h0 = fitlme(data_outlired, h0_formula,'DummyVarCoding', 'effects');
%                     fprintf(fileID, h0_formula);
%                     fprintf(fileID, '\n%s\n', evalc('disp(lme_h0)')); 
% 
%                     
%                     f.test_residuals_normality(h0_formula, data_outlired);
% 
%                     data_variable = data.comp_amp;
%                     % Estimate Gamma distribution parameters (shape and scale)
%                     shape_hat = mean(data_variable)^2 / var(data_variable);
%                     scale_hat = var(data_variable) / mean(data_variable);
%                     
%                     sorted_data = sort(data_variable);
%                     gamma_cdf_values = gamcdf(sorted_data, shape_hat, scale_hat);
%                     
%                     % Step 3: Prepare a matrix with sorted data and corresponding CDF values
%                     cdf_matrix = [sorted_data, gamma_cdf_values];
%                     
%                     % Step 4: Perform Kolmogorov-Smirnov test
%                     [h, p] = kstest(data_variable, 'CDF', cdf_matrix);
%                     
%                     % Display the result
%                     if h == 0
%                         fprintf('Kolmogorov-Smirnov Test: Data is from a Gamma distribution (p = %.4f).\n', p);
%                     else
%                         fprintf('Kolmogorov-Smirnov Test: Data is NOT from a Gamma distribution (p = %.4f).\n', p);
%                     end
% 
%                     coefficients = fixedEffects(lme_h0); % Extract the fixed effects coefficients
%                     sov_coeffs = coefficients(contains(lme_h0.Coefficients.Name, 'sov')); % Get the coefficients for sov
%                     sov_REM = -sum(sov_coeffs); % Calculate the coefficient for the last level (e.g., REM)
%                     fprintf(fileID,'Coefficient for sov_REM: %f\n', sov_REM);
%                     anova_results = anova(lme_h0, 'DFMethod', 'Satterthwaite');
%                     fprintf(fileID, '\n%s\n', evalc('disp(anova_results)'));
% 
%                     
%                     h_sov_formula = 'comp_amp ~ sov + (1|sub)';
%                     lme_h_sov = fitlme(data, h_sov_formula,'DummyVarCoding', 'effects');
%                     fprintf(fileID, h_sov_formula);
%                     fprintf(fileID, '\n%s\n', evalc('disp(lme_h_sov)')); 
%                     coefficients = fixedEffects(lme_h_sov); % Extract the fixed effects coefficients
%                     sov_coeffs = coefficients(contains(lme_h_sov.Coefficients.Name, 'sov')); % Get the coefficients for sov
%                     sov_REM = -sum(sov_coeffs); % Calculate the coefficient for the last level (e.g., REM)
%                     fprintf(fileID,'Coefficient for sov_REM: %f\n', sov_REM);
%                     anova_results = anova(lme_h_sov, 'DFMethod', 'Satterthwaite');
%                     fprintf(fileID, '\n%s\n', evalc('disp(anova_results)'));
% 
% 
%                     h_sovcond = 'comp_amp ~ sov + cond + (1|sub)';
%                     lme_h_sovcond = fitlme(data, h_sovcond,'DummyVarCoding', 'effects');
%                     fprintf(fileID, h_sovcond);
%                     fprintf(fileID, '\n%s\n', evalc('disp(lme_h_sovcond)')); 
%                     coefficients = fixedEffects(lme_h_sovcond); % Extract the fixed effects coefficients
%                     sov_coeffs = coefficients(contains(lme_h_sovcond.Coefficients.Name, 'sov')); % Get the coefficients for sov
%                     sov_REM = -sum(sov_coeffs); % Calculate the coefficient for the last level (e.g., REM)
%                     fprintf(fileID,'Coefficient for sov_REM: %f\n', sov_REM);
%                     anova_results = anova(lme_h_sovcond, 'DFMethod', 'Satterthwaite');
%                     fprintf(fileID, '\n%s\n', evalc('disp(anova_results)'));
%                     
%                     comparisonResults = compare(lme_h0, lme_h_sov);
%                     fprintf(fileID, "lme_h0 VS lme_h_sov______________________________________\n");
%                     fprintf(fileID, '%s\n', evalc('disp(comparisonResults)')); 
%     
%                     comparisonResults = compare(lme_h_sov, lme_h_sovcond);
%                     fprintf(fileID, "lme_h_sov VS lme_h_sovcond______________________________________\n");
%                     fprintf(fileID, '\n%s\n', evalc('disp(comparisonResults)')); 
%                     
%                     fclose(fileID);
                 end
            end
        end
        
        function test_residuals_normality(formula, data)
            lme = fitlme(data, formula,'DummyVarCoding', 'effects');
            fitted_vals = fitted(lme);
            residuals_caped = data.comp_amp - fitted_vals;

            figure;
            histogram(residuals_caped);
            title('Histogram of Residuals');
            xlabel('Residuals');
            ylabel('Frequency');
            figure;
            qqplot(residuals_caped);
            title('Q-Q Plot of Residuals');

            normalized_residuals = (residuals_caped - mean(residuals_caped)) / std(residuals_caped);
            [h, p] = kstest(normalized_residuals);
            if h == 0
                fprintf('Kolmogorov-Smirnov Test: Residuals are normally distributed (p = %.4f).\n', p);
            else
                fprintf('Kolmogorov-Smirnov Test: Residuals are NOT normally distributed (p = %.4f).\n', p);
            end
            [h, p] = swtest(residuals_caped);
            if h == 0
                fprintf('Shapiro-Wilk Test: Residuals are normally distributed (p = %.4f).\n', p);
            else
                fprintf('Shapiro-Wilk Test: Residuals are NOT normally distributed (p = %.4f).\n', p);
            end
            [h, p] = lillietest(residuals_caped);
            if h == 0
                fprintf('Lilliefors Test: Residuals are normally distributed (p = %.4f).\n', p);
            else
                fprintf('Lilliefors Test: Residuals are NOT normally distributed (p = %.4f).\n', p);
            end
        end
