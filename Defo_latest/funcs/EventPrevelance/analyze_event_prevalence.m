function [rm_anova_results, parametric_posthoc, nonparametric_posthoc] = analyze_event_prevalence(subs, sovs, conds_sets, conds_sets_names, dirs, categories, plot_results)
% ANALYZE_EVENT_PREVALENCE Analyzes event prevalence across presentation orders
%
% INPUTS:
%   subs                - Cell array of subject IDs
%   sovs                - Cell array of states of vigilance (typically {v.N2})
%   conds_sets          - Cell array of condition sets to analyze
%   conds_sets_names    - Cell array of names for each condition set
%   ft_cond_input_dir   - Input directory for Fieldtrip condition files
%   ft_cond_output_dir  - Output directory for Fieldtrip condition files
%   time                - Time vector for ERP data
%   categories          - Cell array of category variables {KC, SS, Neither}
%                         e.g., {v.N2EliwJKc, v.N2EliwJSs, v.N2Eliwo}
%   plot_results        - Boolean flag for plotting (default: true)
%
% OUTPUTS:
%   rm_anova_results    - Table of repeated measures ANOVA results
%   parametric_posthoc  - Table of parametric post-hoc test results (t-tests)
%   nonparametric_posthoc - Table of non-parametric post-hoc test results (Wilcoxon)

    % Set default for plot_results if not provided
    if nargin < 7
        plot_results = true;
    end
    
    % Ensure categories is provided
    if nargin < 6 || isempty(categories) || ~iscell(categories) || length(categories) ~= 3
        error('Categories must be provided as a cell array with 3 elements: {KC, SS, Neither}');
    end
    
    % Initialize output tables
    rm_anova_results = table('Size', [0, 9], ...
                           'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'string'}, ...
                           'VariableNames', {'ConditionSet', 'Effect', 'DF1', 'DF2', 'F', 'P_Value', 'P_GG', 'Partial_Eta_Sq', 'Significance'});
    
    parametric_posthoc = table('Size', [0, 10], ...
                             'VariableTypes', {'string', 'string', 'string', 'double', 'double', 'double', 'double', 'double', 'double', 'string'}, ...
                             'VariableNames', {'ConditionSet', 'Category', 'Comparison', 'MeanDiff', 'CI_Lower', 'CI_Upper', 'P_Value', 'P_FDR', 'Cohens_d', 'Significance'});
    
    nonparametric_posthoc = table('Size', [0, 9], ...
                                'VariableTypes', {'string', 'string', 'string', 'double', 'double', 'double', 'double', 'double', 'string'}, ...
                                'VariableNames', {'ConditionSet', 'Category', 'Comparison', 'MedianDiff', 'P_Value', 'P_FDR', 'Z_Stat', 'Effect_Size_r', 'Significance'});
    
    % Define category labels for output
    categoryLevels = {'KC', 'SS', 'Neither'};
    
    % Process each condition set
    for conds_sets_i = 1:numel(conds_sets)
        % Extract current condition set and name
        conds = conds_sets{conds_sets_i};
        conds_name = conds_sets_names{conds_sets_i};
        
        % Initialize arrays to store proportions
        propor_data = zeros(numel(subs), numel(conds), 3); % [subjects, conditions, categories]
        
        % Process data for each condition and subject
        for cond_i = 1:numel(conds)
            for sub_i = 1:numel(subs)
                % Get all trials for current condition and subject
                curr_cond_timelockAll = get_cond_timelocked({subs{sub_i}}, conds{cond_i}, sovs{1}, dirs.ft_cond_input, dirs.ft_cond_output);
                count_n2_all = curr_cond_timelockAll{1}.cfg.trials_timelocked_avg;
                
                % Process each category (KC, SS, Neither) in a loop
                for cat_i = 1:3
                    try
                        curr_timelock = get_cond_timelocked({subs{sub_i}}, conds{cond_i}, categories{cat_i}, dirs.ft_cond_input, dirs.ft_cond_output);
                        propor_data(sub_i, cond_i, cat_i) = curr_timelock{1}.cfg.trials_timelocked_avg / count_n2_all;
                    catch ME
                        if contains(ME.message, 'This function requires ''raw+comp'' or ''raw'' data as input')
                            propor_data(sub_i, cond_i, cat_i) = 0;
                        elseif contains(ME.identifier, 'MyComponent:LessThanFiveTrials')
                            tokens = regexp(ME.message, 'Trials: (\d+)', 'tokens', 'once');
                            if ~isempty(tokens)
                                propor_data(sub_i, cond_i, cat_i) = str2double(tokens{1}) / count_n2_all;
                            else
                                propor_data(sub_i, cond_i, cat_i) = 0;
                            end
                        else
                            rethrow(ME);
                        end
                    end
                end
            end
        end
        
        % Extract data for easier use
        kc_propor = propor_data(:, :, 1);
        ss_propor = propor_data(:, :, 2);
        neither_propor = propor_data(:, :, 3);
        
        % Create table for RM-ANOVA
        varNames = {};
        for cat_idx = 1:3
            cat_names = {'KC', 'SS', 'Niet'};
            for i = 1:numel(conds)
                varNames{end+1} = sprintf('%s%d', cat_names{cat_idx}, i);
            end
        end
        
        % Create data table
        dataArray = [kc_propor(:, 1:numel(conds)), ss_propor(:, 1:numel(conds)), neither_propor(:, 1:numel(conds))];
        t = array2table(dataArray, 'VariableNames', varNames);
        
        % Define within-subject factors
        Category = categorical([ones(1, numel(conds)) 2*ones(1, numel(conds)) 3*ones(1, numel(conds))]');
        PresentationOrder = categorical(repmat(1:numel(conds), [1 3])');
        within = table(Category, PresentationOrder);
        
        % Run rm-ANOVA
        try
            rm = fitrm(t, [varNames{1} '-' varNames{end} ' ~ 1'], 'WithinDesign', within);
            [tbl, ~, ~] = ranova(rm);
            
            % Process ANOVA results - handle different table sizes
            numEffects = height(tbl);
            
            % Calculate effect sizes
            for i = 1:min(numEffects, 3)  % Only process available effects
                if i == 1  % Time effect
                    effect_name = 'Time';
                    partial_eta_sq = tbl.SumSq(i) / (tbl.SumSq(i) + tbl.SumSq(i+1));
                elseif i == 2  % Category effect
                    effect_name = 'Category';
                    partial_eta_sq = tbl.SumSq(i) / (tbl.SumSq(i) + tbl.SumSq(i+1));
                elseif i == 3  % Interaction
                    effect_name = 'Time x Category';
                    partial_eta_sq = tbl.SumSq(i) / (tbl.SumSq(i) + tbl.SumSq(i+1));
                end
                
                % Store rm-ANOVA results
                sig_level = get_significance_level(tbl.pValue(i));
                rm_anova_results = [rm_anova_results; {conds_name, effect_name, tbl.DF1(i), tbl.DF2(i), ...
                                  tbl.F(i), tbl.pValue(i), tbl.pValueGG(i), partial_eta_sq, sig_level}];
            end
        catch ME
            warning('RM-ANOVA failed: %s', ME.message);
            disp('Continuing with individual category analyses...');
        end
        
        % Run individual RM-ANOVAs for each category
        for cat_i = 1:3
            cat_data = t(:, ((cat_i-1)*numel(conds)+1):(cat_i*numel(conds)));
            
            try
                % Create category model
                cat_rm = fitrm(cat_data, [varNames{(cat_i-1)*numel(conds)+1} '-' varNames{cat_i*numel(conds)} ' ~ 1']);
                [cat_tbl, ~, ~] = ranova(cat_rm);
                
                % Skip if no rows in result
                if isempty(cat_tbl) || height(cat_tbl) < 1
                    continue;
                end
                
                % Calculate effect size for Time effect
                cat_eta_sq = cat_tbl.SumSq(1) / (cat_tbl.SumSq(1) + cat_tbl.SumSq(2));
                
                % Store category-specific rm-ANOVA results
                sig_level = get_significance_level(cat_tbl.pValue(1));
                rm_anova_results = [rm_anova_results; {conds_name, [categoryLevels{cat_i} ' Time'], ...
                                  cat_tbl.DF(1), cat_tbl.DF(2), cat_tbl.F(1), cat_tbl.pValue(1), ...
                                  cat_tbl.pValueGG(1), cat_eta_sq, sig_level}];
            catch ME
                warning('Category %d RM-ANOVA failed: %s', cat_i, ME.message);
                disp('Continuing with other analyses...');
            end
        end
        
        % Perform post-hoc tests for each category
        param_results = {};
        nonparam_results = {};
        
        for cat_i = 1:3
            cat_data = t(:, ((cat_i-1)*numel(conds)+1):(cat_i*numel(conds)));
            colNames = cat_data.Properties.VariableNames;
            
            % Initialize arrays to collect p-values for FDR correction
            param_pvals = [];
            nonparam_pvals = [];
            
            % Run pairwise tests for adjacent presentation orders
            for i = 1:(numel(conds)-1)
                col1 = cat_data.(colNames{i});
                col2 = cat_data.(colNames{i+1});
                
                try
                    % Parametric test (paired t-test)
                    [~, p_param, ci, stats_param] = ttest(col1, col2);
                    diff = col1 - col2;
                    cohens_d = mean(diff) / std(diff);
                    param_pvals = [param_pvals; p_param];
                    param_results{end+1} = {conds_name, categoryLevels{cat_i}, ...
                                           sprintf('%s vs %s', colNames{i}, colNames{i+1}), ...
                                           mean(diff), ci(1), ci(2), p_param, NaN, cohens_d, ''};
                catch ME
                    warning('T-test failed for %s vs %s: %s', colNames{i}, colNames{i+1}, ME.message);
                end
                
                try
                    % Non-parametric test (Wilcoxon signed-rank test)
                    [p_nonparam, ~, stats_nonparam] = signrank(col1, col2);
                    median_diff = median(col1 - col2);
                    valid_pairs = sum(~isnan(col1 - col2));
                    if isfield(stats_nonparam, 'zval')
                        zval = stats_nonparam.zval;
                        effect_r = zval / sqrt(valid_pairs);
                    else
                        zval = NaN;
                        effect_r = NaN;
                    end
                    nonparam_pvals = [nonparam_pvals; p_nonparam];
                    nonparam_results{end+1} = {conds_name, categoryLevels{cat_i}, ...
                                              sprintf('%s vs %s', colNames{i}, colNames{i+1}), ...
                                              median_diff, p_nonparam, NaN, zval, effect_r, ''};
                catch ME
                    warning('Wilcoxon test failed for %s vs %s: %s', colNames{i}, colNames{i+1}, ME.message);
                end
            end
            
            % Apply FDR correction within each category and store in results
            if ~isempty(param_pvals)
                param_fdr = mafdr(param_pvals, 'BHFDR', true);
                
                param_offset = (cat_i-1)*(numel(conds)-1);
                for j = 1:length(param_pvals)
                    if param_offset+j <= length(param_results)
                        % Update parametric results with FDR and significance
                        param_results{param_offset+j}{8} = param_fdr(j);
                        param_results{param_offset+j}{10} = get_significance_level(param_fdr(j));
                    end
                end
            end
            
            if ~isempty(nonparam_pvals)
                nonparam_fdr = mafdr(nonparam_pvals, 'BHFDR', true);
                
                nonparam_offset = (cat_i-1)*(numel(conds)-1);
                for j = 1:length(nonparam_pvals)
                    if nonparam_offset+j <= length(nonparam_results)
                        % Update non-parametric results with FDR and significance
                        nonparam_results{nonparam_offset+j}{6} = nonparam_fdr(j);
                        nonparam_results{nonparam_offset+j}{9} = get_significance_level(nonparam_fdr(j));
                    end
                end
            end
        end
        
        % Convert cell arrays to tables
        for i = 1:numel(param_results)
            parametric_posthoc = [parametric_posthoc; param_results{i}];
        end
        
        for i = 1:numel(nonparam_results)
            nonparametric_posthoc = [nonparametric_posthoc; nonparam_results{i}];
        end
        
        % Generate plots if requested
        if plot_results
            create_prevalence_plots(conds, propor_data, parametric_posthoc, conds_name, categoryLevels);
        end
    end
end

function create_prevalence_plots(conds, propor_data, param_posthoc, conds_name, categoryLevels)
    % Function to create visualization plots
    figure('Position', [50 50 1200 800]);
    
    % Extract data for each category
    kc_propor = propor_data(:, :, 1);
    ss_propor = propor_data(:, :, 2);
    neither_propor = propor_data(:, :, 3);
    
    % Create boxplots for each category
    for i = 1:3
        subplot(3, 1, i);
        
        % Get data for current category
        switch i
            case 1
                cat_data = kc_propor;
                title_str = 'K-Complex Category';
            case 2
                cat_data = ss_propor;
                title_str = 'Sleep Spindle Category';
            case 3
                cat_data = neither_propor;
                title_str = 'Neither Category';
        end
        
        % Create boxplot
        try
            condLabels = cellfun(@(x) char(x.short_s), conds, 'UniformOutput', false);
            boxplot(cat_data, 'Labels', condLabels);
        catch
            boxplot(cat_data);
        end
        
        title(title_str, 'FontWeight', 'bold');
        xlabel('Presentation Order');
        ylabel('Proportion of Trials');
        grid on;
        
        % Add mean line
        hold on;
        means = mean(cat_data, 1, 'omitnan');
        plot(1:numel(conds), means, 'r-', 'LineWidth', 2);
        
        % Add significance markers from parametric tests
        cat_results = param_posthoc(strcmp(param_posthoc.Category, categoryLevels{i}) & strcmp(param_posthoc.ConditionSet, conds_name), :);
        
        if ~isempty(cat_results)
            y_max = max(max(cat_data)) * 1.1;
            if isnan(y_max) || y_max <= 0
                y_max = 1;  % Default if no valid data
            end
            y_step = y_max * 0.05;
            
            for j = 1:height(cat_results)
                if cat_results.P_FDR(j) < 0.05
                    % Extract comparison indices
                    comp_str = cat_results.Comparison{j};
                    try
                        indices = sscanf(comp_str, '%*[^0-9]%d vs %*[^0-9]%d');
                        
                        % Plot significance line and marker
                        if length(indices) >= 2
                            x1 = indices(1);
                            x2 = indices(2);
                            y = y_max + (j-1) * y_step;
                            
                            plot([x1, x2], [y, y], 'k-');
                            text(mean([x1, x2]), y+y_step/4, cat_results.Significance{j}, 'HorizontalAlignment', 'center');
                        end
                    catch
                        warning('Could not extract indices from comparison: %s', comp_str);
                    end
                end
            end
        end
        
        hold off;
    end
    
    % Set overall title
    sgtitle([conds_name ' - Event Prevalence Analysis'], 'FontSize', 14, 'FontWeight', 'bold');
    
    % Adjust figure appearance
    set(gcf, 'Color', 'white');
    set(findall(gcf, '-property', 'FontSize'), 'FontSize', 12);
end

function sig_level = get_significance_level(p_value)
    % Helper function to determine significance symbols
    if isnan(p_value)
        sig_level = '';
    elseif p_value < 0.001
        sig_level = '***';
    elseif p_value < 0.01
        sig_level = '**';
    elseif p_value < 0.05
        sig_level = '*';
    else
        sig_level = 'n.s.';
    end
end

