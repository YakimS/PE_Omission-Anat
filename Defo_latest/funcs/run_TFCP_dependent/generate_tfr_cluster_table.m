function results_table = generate_tfr_cluster_table(file_pattern)

% INPUTS:
%   file_pattern  - File pattern to match (e.g., 'path/to/data/TFR-*T1234_clust.mat')
%
% OUTPUTS:
%   results_table - Table containing time-frequency cluster statistics
%
% Example usage:
%   results = generate_tfr_cluster_table('path/to/data/TFR-*T1234_clust.mat');

    % Validate inputs
    if nargin < 1
        error('file_pattern is required');
    end
    
    % Create a map to track processed contrasts
    processed_contrasts = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    
    % Initialize results cell array
    results = {};
    row = 1;
    
    % Get list of files matching the pattern
    files = dir(file_pattern);
    
    % Check if any files were found
    if isempty(files)
        warning('No files found matching pattern: %s', file_pattern);
        results_table = table();
        return;
    end
    
    % Process each file
    for file_i = 1:numel(files)
        file_path = fullfile(files(file_i).folder, files(file_i).name);
        data = load(file_path);
        if ~isfield(data, 'metadata') || ~isfield(data.metadata, 'stat') || ~isfield(data.metadata, 'sub_num')
            error('File %s does not contain the expected data structure', files(file_i).name);
        end
        contrast_name = files(file_i).name;
        
        if isKey(processed_contrasts, contrast_name)
            continue;
        end
        processed_contrasts(contrast_name) = true; % Mark as processed
        stat_data = data.metadata.stat;

        % Process positive and negative clusters
        negpos_arr = {'pos', 'neg'};
        for negpos_i = 1:numel(negpos_arr)
            negpos = negpos_arr{negpos_i};
            cluster_field = [negpos 'clusters'];
            label_field = [negpos 'clusterslabelmat'];
            
            % Check if cluster data exists and is not empty
            if isfield(stat_data, cluster_field) && ~isempty(stat_data.(cluster_field))
                for clust_idx = 1:length(stat_data.(cluster_field))
                    cluster_mask = stat_data.(label_field) == clust_idx; % Get cluster mask (3D: chan x freq x time)
                    [chan_idx, freq_idx, time_idx] = ind2sub(size(cluster_mask), find(cluster_mask)); % Find frequency and time indices where cluster exists
                   
                    if isempty(freq_idx) || isempty(time_idx) % Skip if no points in cluster
                        continue;
                    end

                    clust_freqRange = stat_data.(cluster_field)(clust_idx).clust_freqRange;
                    clust_timeRange = stat_data.(cluster_field)(clust_idx).clust_timeRange;

                    % Calculate maximum absolute statistical value within the cluster
                    cluster_stat_values = stat_data.stat .* cluster_mask;
                    max_stat = max(abs(cluster_stat_values(cluster_stat_values ~= 0)));
                    
                    % Get channels involved in cluster
                    unique_channels = unique(chan_idx);
                    channel_labels = stat_data.label(unique_channels);

                    if isfield(stat_data.(cluster_field)(clust_idx),"cohensd_mean")
                        cohens_mean = stat_data.(cluster_field)(clust_idx).cohensd_mean;
                    else
                        cohens_mean = NaN;
                    end
                    
                    
                    results(row, :) = {
                        [contrast_name '_' negpos], ...
                        strjoin(channel_labels, ','), ...
                        sprintf('%.1f-%.1f', clust_freqRange(1), clust_freqRange(2)), ...
                        sprintf('%.3f-%.3f', clust_timeRange(1), clust_timeRange(2)), ...
                        stat_data.(cluster_field)(clust_idx).prob, ...
                        max_stat, ...
                        cohens_mean, ...
                        data.metadata.sub_num
                    };
                    
                    row = row + 1;
                end
            end
        end
    end
    
    % Create and return the table
    if ~isempty(results)
        headers = {'contrast', 'channels', 'freq_range_Hz', 'time_range_s', 'pval', 'max_stat', 'cohens_d', 'N'};
        results_table = cell2table(results, 'VariableNames', headers);
    else
        warning('No significant clusters found in any of the files.');
        results_table = table();
    end
end