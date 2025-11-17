function trial_counts_table = analyze_trial_counts(subs, sovs, conds, ft_cond_input_dir, ft_cond_output_dir)
    % ANALYZE_TRIAL_COUNTS Analyzes number of trials for each condition-SOV pair
    %
    % INPUTS:
    %   subs                - Cell array of subject IDs
    %   sovs                - Cell array of states of vigilance
    %   conds               - Cell array of conditions to analyze
    %   ft_cond_input_dir   - Input directory for Fieldtrip condition files
    %   ft_cond_output_dir  - Output directory for Fieldtrip condition files
    %
    % OUTPUTS:
    %   trial_counts_table  - Cross-tabulated table with SOVs as rows, conditions as columns
    

        % Initialize cell array for the cross-tabulated data
        data_matrix = cell(numel(sovs), numel(conds));
        
        % Process each SOV and condition combination
        for sov_i = 1:numel(sovs)
            for cond_i = 1:numel(conds)
                % Initialize array for trial counts
                trial_counts = zeros(numel(subs), 1);
                
                % Get trial counts for each subject
                for sub_i = 1:numel(subs)
                    try
                        % Get trials for current condition, subject, and SOV
                        curr_timelock = get_cond_timelocked({subs{sub_i}}, conds{cond_i}, sovs{sov_i}, ft_cond_input_dir, ft_cond_output_dir);
                        trial_counts(sub_i) = curr_timelock{1}.cfg.trials_timelocked_avg;
                    catch ME
                        if contains(ME.identifier, 'MyComponent:LessThanFiveTrials')
                            tokens = regexp(ME.message, 'Trials: (\d+)', 'tokens', 'once');
                            if ~isempty(tokens)
                                trial_counts(sub_i) = str2double(tokens{1});
                            else
                                trial_counts(sub_i) = 0;
                            end
                        else
                            trial_counts(sub_i) = 0;
                        end
                    end
                end
                
                % Calculate mean and SD
                mean_trials = mean(trial_counts);
                sd_trials = std(trial_counts);
                
                % Format as "mean +/- SD" string
                data_matrix{sov_i, cond_i} = sprintf('%.2f +/- %.2f', mean_trials, sd_trials);
            end
        end
        
        % Create column names from condition long names
        col_names = cell(1, numel(conds));
        for i = 1:numel(conds)
            col_names{i} = conds{i}.long_s;
        end
        
        % Create row names from SOV long names
        row_names = cell(numel(sovs), 1);
        for i = 1:numel(sovs)
            row_names{i} = sovs{i}.long_s;
        end
        
        % Create the table with SOVs as rows and conditions as columns
        trial_counts_table = table(data_matrix(:,1), 'VariableNames', {col_names{1}}, 'RowNames', row_names);
        
        % Add remaining columns
        for i = 2:numel(conds)
            trial_counts_table.(col_names{i}) = data_matrix(:,i);
        end
        
        % Save to CSV file
        writetable(trial_counts_table, 'trial_counts_summary.csv', 'WriteRowNames', true);
    end