function results_table = extractMVPAStats(directory_path, contrast)
% EXTRACTMVPASTATS Extract statistics from all MVPA diagonal result files
%
% Input:
%   directory_path - Path to directory containing *diag-1.mat files
%   contrast - String specifying the contrast name in the filename
%
% Output:
%   results_table - Table with statistics for each file and cluster
%
% Usage:
%   results_table = extractMVPAStats('/path/to/results/', 'UnexOm-vs-ExOm');

    % Find all files matching pattern
    files = dir(fullfile(directory_path, sprintf('*diag-1_%s.mat', contrast)));
    if isempty(files)
        error('No files matching pattern "*diag-1_%s.mat" found in directory: %s', contrast, directory_path);
    end
    
    all_results = [];
    for f = 1:length(files)
        filename = files(f).name;
        filepath = fullfile(directory_path, filename);
        
        data = load(filepath);
        if ~isfield(data, 'mvpa_stats')
            warning('File %s does not contain mvpa_stats variable, skipping...', filename);
            continue;
        end
        
        mvpa_stats = data.mvpa_stats;
        file_stats = extractSingleFileStats(mvpa_stats);
        
        if isempty(all_results)
            all_results = file_stats;
        else
            all_results = [all_results; file_stats];
        end
    end
    
    results_table = struct2table(all_results);
end

function stats_array = extractSingleFileStats(mvpa_stats)
    condition = mvpa_stats.condname;
    
    % Get accuracy data
    mean_accuracy = mvpa_stats.ClassOverTime;
    [peak_acc, peak_idx] = max(mean_accuracy);
    peak_acc_percent = peak_acc * 100;
    
    % Get time vector
    time_ms = mvpa_stats.settings.times{1} * 1000;
    peak_time = time_ms(peak_idx);
    
    number_of_subjs = size(mvpa_stats.indivClassOverTime, 1);
    
    % Trial count information
    mean_trials = mean(mvpa_stats.trialcount);
    min_trials = min(mvpa_stats.trialcount);
    max_trials = max(mvpa_stats.trialcount);
    
    % Find significant clusters
    p_vals_corrected = mvpa_stats.pVals;
    sig_mask = p_vals_corrected < 0.05;
    
    % Initialize n_clusters for later use
    n_clusters = 0;
    
    if any(sig_mask)
        % Find all contiguous clusters
        sig_diff = diff([0; sig_mask(:); 0]);
        cluster_starts = find(sig_diff == 1);
        cluster_ends = find(sig_diff == -1) - 1;
        cluster_lengths = cluster_ends - cluster_starts + 1;
        
        % Filter out single-point "clusters"
        valid_clusters = cluster_lengths >= 2;
        cluster_starts = cluster_starts(valid_clusters);
        cluster_ends = cluster_ends(valid_clusters);
        cluster_lengths = cluster_lengths(valid_clusters);
        
        n_clusters = length(cluster_starts);
        
        if n_clusters > 0
            % Sort clusters by size (largest first)
            [~, sort_idx] = sort(cluster_lengths, 'descend');
            cluster_starts = cluster_starts(sort_idx);
            cluster_ends = cluster_ends(sort_idx);
            
            % Create one row for each cluster
            stats_array = [];
            for c = 1:n_clusters
                stats = struct();
                
                % Basic info
                stats.Condition = {condition};
                stats.Cluster_Number = c;
                stats.Total_Clusters = n_clusters;
                
                % Cluster boundaries
                cluster_start_idx = cluster_starts(c);
                cluster_end_idx = cluster_ends(c);
                stats.Cluster_Start_ms = time_ms(cluster_start_idx);
                stats.Cluster_End_ms = time_ms(cluster_end_idx);
                
                % Cluster p-value
                cluster_indices = cluster_start_idx:cluster_end_idx;
                cluster_p_values = p_vals_corrected(cluster_indices);
                cluster_p_values(cluster_p_values == 0) = 1e-16;
                stats.Cluster_p = min(cluster_p_values);
                
                % Extract t-statistics from ttest_STATS
                % Average t-values within the cluster window
                cluster_t_values = mvpa_stats.ttest_stats.tstat(cluster_indices);
                stats.Cluster_t = mean(cluster_t_values);  % Or take max if preferred
                stats.Cluster_df = mvpa_stats.ttest_stats.df(1);  % df should be constant
                
                % Calculate Cohen's d from t-statistic
                stats.Cluster_d = stats.Cluster_t / sqrt(number_of_subjs);
                
                % Calculate mean accuracy in cluster window
                cluster_accs_per_subject = mean(mvpa_stats.indivClassOverTime(:, cluster_indices), 2) * 100;
                stats.Cluster_Mean_Acc = mean(cluster_accs_per_subject);
                
                % Overall file statistics
                stats.N_Subjects = number_of_subjs;
                stats.Peak_Accuracy = peak_acc_percent;
                stats.Peak_Time_ms = peak_time;
                stats.Mean_Trials = mean_trials;
                stats.Min_Trials = min_trials;
                stats.Max_Trials = max_trials;
                
                stats_array = [stats_array; stats];
            end
        end
    end
    
    % If no significant clusters found, create single row with NaN values
    if ~any(sig_mask) || n_clusters == 0
        stats = struct();
        stats.Condition = {condition};
        stats.Cluster_Number = NaN;
        stats.Total_Clusters = 0;
        stats.Cluster_Start_ms = NaN;
        stats.Cluster_End_ms = NaN;
        stats.Cluster_p = NaN;
        stats.Cluster_t = NaN;
        stats.Cluster_df = NaN;
        stats.Cluster_d = NaN;
        stats.Cluster_Mean_Acc = NaN;
        stats.N_Subjects = number_of_subjs;
        stats.Peak_Accuracy = peak_acc_percent;
        stats.Peak_Time_ms = peak_time;
        stats.Mean_Trials = mean_trials;
        stats.Min_Trials = min_trials;
        stats.Max_Trials = max_trials;
        stats_array = stats;
    end
end