function [avg_diffs, avg_norm_diff, total_avg_norm_diff, total_avg_diff] = normalize_and_plot_diff_erps(subs, sovs, diffconds, ft_cond_input_dir, ft_cond_output_dir, clusts_struct, time, plotOptions)
% NORMALIZE_AND_PLOT_DIFF_ERPS Calculates, normalizes and plots difference ERPs
%
% INPUTS:
%   output_main_dir     - Main output directory
%   subs                - Cell array of subject IDs
%   sovs                - Cell array of states of vigilance (e.g., {v.wn, v.N2, v.N3, v.REM})
%   diffconds           - Cell array of condition pairs to compare (e.g., {{v.Bl0T1, v.Bl0T4}})
%   ft_cond_input_dir   - Input directory for Fieldtrip condition files
%   ft_cond_output_dir  - Output directory for Fieldtrip condition files
%   clusts_struct       - Structure containing electrode clusters
%   time                - Time vector for ERP data
%   plotOptions         - Structure with plotting options (default: both plots)
%                         Fields: .normalizedPlot (boolean)
%                                 .rawPlot (boolean)
%
% OUTPUTS:
%   avg_diffs           - Structure of raw difference ERPs by condition
%   avg_norm_diff       - Structure of normalized difference ERPs by condition
%   total_avg_norm_diff - Structure of subject-averaged normalized difference ERPs
%   total_avg_diff      - Structure of subject-averaged raw difference ERPs
%
% Example usage:
%   % Plot both normalized and raw differences
%   [diffs, norm_diffs, avg_norm, avg_raw] = normalize_and_plot_diff_erps(output_main_dir, subs, {v.wn, v.N2, v.N3, v.REM}, {{v.Bl0T1, v.Bl0T4}}, ft_cond_input_dir, ft_cond_output_dir, clusts_struct, time);
%
%   % Plot only normalized differences
%   options.normalizedPlot = true;
%   options.rawPlot = false;
%   [diffs, norm_diffs, avg_norm, avg_raw] = normalize_and_plot_diff_erps(output_main_dir, subs, {v.wn, v.N2, v.N3, v.REM}, {{v.Bl0T1, v.Bl0T4}}, ft_cond_input_dir, ft_cond_output_dir, clusts_struct, time, options);

    % Set default for plotOptions if not provided
    if nargin < 9 || isempty(plotOptions)
        plotOptions = struct('normalizedPlot', true, 'rawPlot', true);
    elseif ~isstruct(plotOptions)
        % If a simple boolean was passed, treat it as normalizedPlot setting
        normalizedPlot = plotOptions;
        plotOptions = struct('normalizedPlot', normalizedPlot, 'rawPlot', true);
    end
    
    % Ensure all fields exist
    if ~isfield(plotOptions, 'normalizedPlot')
        plotOptions.normalizedPlot = true;
    end
    if ~isfield(plotOptions, 'rawPlot')
        plotOptions.rawPlot = true;
    end

    % Initialize output structures
    avg_diffs = struct();
    avg_norm_diff = struct();
    
    % For each state of vigilance
    for sov_i = 1:numel(sovs)
        sov = sovs{sov_i};
        
        % Collect all difference values to find global max for normalization
        all_diffs_this_sov = [];
        
        % First pass: collect differences
        for dcond_i = 1:numel(diffconds)
            diff_pair = diffconds{dcond_i};
            
            % Get functions and data for this combination
            f = get_funcs_instant(subs, {sov}, diff_pair, ft_cond_input_dir, ft_cond_output_dir, time);
            
            % Get condition data
            [cond1_data, cond2_data] = get_condition_data(f, diff_pair, sov);
            
            % Calculate differences for each subject and collect them
            for sub_i = 1:numel(cond1_data)
                diff = calculate_avg_diff(cond1_data{sub_i}, cond2_data{sub_i}, clusts_struct.central5.elect_label);
                all_diffs_this_sov = [all_diffs_this_sov; diff(:)'];
            end
        end
        
        % Find global max for this vigilance state
        global_max = max(abs(all_diffs_this_sov(:)));
        
        % Second pass: normalize and store differences
        for dcond_i = 1:numel(diffconds)
            diff_pair = diffconds{dcond_i};
            
            % Get condition name
            name_diffcond = sprintf("%s_%s___%s", diff_pair{1}.short_s, diff_pair{2}.short_s, sov.short_s);
            
            % Get functions and data
            f = get_funcs_instant(subs, {sov}, diff_pair, ft_cond_input_dir, ft_cond_output_dir, time);
            
            % Get condition data
            [cond1_data, cond2_data] = get_condition_data(f, diff_pair, sov);
            
            % Initialize structures for this condition
            diff_conds = struct();
            normDiff_conds = struct();
            
            % Process each subject
            for sub_i = 1:numel(cond1_data)
                % Calculate difference
                diff = calculate_avg_diff(cond1_data{sub_i}, cond2_data{sub_i}, clusts_struct.central5.elect_label);
                
                % Normalize using the global max for this vigilance state
                normalized_diff = diff / global_max;
                
                % Store raw and normalized differences
                sub_field = sprintf("s_%s", f.subs{sub_i});
                diff_conds.(sub_field) = diff;
                normDiff_conds.(sub_field) = normalized_diff;
            end
            
            % Store data for this condition
            avg_diffs.(name_diffcond) = diff_conds;
            avg_norm_diff.(name_diffcond) = normDiff_conds;
        end
    end
    
    % Calculate average across subjects for each condition
    total_avg_norm_diff = calculate_subject_averages(avg_norm_diff);
    total_avg_diff = calculate_subject_averages(avg_diffs);
    
    % Plot results if requested
    if plotOptions.normalizedPlot
        plot_differences(total_avg_norm_diff, avg_norm_diff, time, 'Normalized Difference ERPs', true);
    end
    
    if plotOptions.rawPlot
        plot_differences(total_avg_diff, avg_diffs, time, 'Raw Difference ERPs', false);
    end
end

function [cond1_data, cond2_data] = get_condition_data(f, diff_pair, sov)
    % Helper function to retrieve condition data
    cond1_data = f.get_cond_timelocked(f.subs, diff_pair{1}, sov);
    cond2_data = f.get_cond_timelocked(f.subs, diff_pair{2}, sov);
end

function diff = calculate_avg_diff(cond1, cond2, channels)
    % Helper function to calculate the difference between conditions
    cfg = [];
    cfg.channel = channels;
    
    % Calculate averages
    grandavg1 = ft_timelockgrandaverage(cfg, cond1);
    grandavg2 = ft_timelockgrandaverage(cfg, cond2);
    
    % Calculate mean across channels
    grandavg1_mean = mean(grandavg1.avg, 1);
    grandavg2_mean = mean(grandavg2.avg, 1);
    
    % Calculate difference
    diff = grandavg1_mean - grandavg2_mean;
end

function total_avg = calculate_subject_averages(diff_struct)
    % Helper function to calculate average across subjects for each condition
    total_avg = struct();
    condition_names = fieldnames(diff_struct);
    
    for cond_i = 1:length(condition_names)
        curr_cond = condition_names{cond_i};
        subject_fields = fieldnames(diff_struct.(curr_cond));
        
        % Collect data from all subjects
        all_subjects_data = [];
        for sub_i = 1:length(subject_fields)
            all_subjects_data(sub_i,:) = diff_struct.(curr_cond).(subject_fields{sub_i});
        end
        
        % Calculate mean across subjects
        total_avg.(curr_cond) = mean(all_subjects_data, 1);
    end
end

function plot_differences(total_avg, diff_struct, time_vector, plot_title, is_normalized)
    % Helper function to plot differences
    figure;
    hold on;
    
    % Get all condition names
    condition_names = fieldnames(total_avg);
    
    % Define colors for different conditions
    colors = {'b', 'r', 'g', 'm', 'c', 'y', 'k', [0.5 0.5 0.5]};
    
    % Plot each condition
    for cond_i = 1:length(condition_names)
        curr_cond = condition_names{cond_i};
        color_idx = mod(cond_i-1, length(colors)) + 1;
        
        % Plot mean
        plot(time_vector, total_avg.(curr_cond), colors{color_idx}, 'LineWidth', 2);
        
        % Calculate and plot standard error bands
        subject_fields = fieldnames(diff_struct.(curr_cond));
        all_subjects_data = [];
        for sub_i = 1:length(subject_fields)
            all_subjects_data(sub_i,:) = diff_struct.(curr_cond).(subject_fields{sub_i});
        end
        
        % Calculate standard error
        sem = std(all_subjects_data, [], 1) / sqrt(size(all_subjects_data, 1));
        
        % Plot error bands
        fill([time_vector fliplr(time_vector)], ...
             [total_avg.(curr_cond)+sem fliplr(total_avg.(curr_cond)-sem)], ...
             colors{color_idx}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    end
    
    % Customize plot
    xlabel('Time (s)');
    if is_normalized
        ylabel('Normalized Difference');
    else
        ylabel('Difference (µV)');
    end
    title(plot_title);
    legend(strrep(condition_names, '_', ' '), 'Location', 'best');
    grid on;
    
    % Add zero line for reference
    yline(0, 'k--', 'Alpha', 0.5);
    
    hold off;
end