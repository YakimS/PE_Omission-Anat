function results_table = generate_tcp_cluster_table(file_pattern)
% GENERATE_ERP_CLUSTER_TABLE Extract cluster statistics from ERP data files
%
% INPUTS:
%   file_pattern  - File pattern to match (e.g., 'path/to/data/ERP_name-*T1234_clust-centElec.mat')
%
% OUTPUTS:
%   results_table - Table containing cluster statistics
%
% Example usage:
%   results = generate_erp_cluster_table('path/to/data/ERP_name-*T1234_clust-centElec.mat');

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
        % Load the data file
        file_path = fullfile(files(file_i).folder, files(file_i).name);
        data = load(file_path);
        
        % Check if the required fields exist
        if ~isfield(data, 'metadata') || ~isfield(data.metadata, 'cfg') || ~isfield(data.metadata.cfg, 'stats')
            warning('File %s does not contain the expected data structure. Skipping.', files(file_i).name);
            continue;
        end
        
        % Get all contrast names
        contrasts = fieldnames(data.metadata.cfg.stats);
        
        % Process each contrast
        for cont_idx = 1:length(contrasts)
            contrast_name = contrasts{cont_idx};
            
            % Skip if we've already processed this contrast
            if isKey(processed_contrasts, contrast_name)
                continue;
            end
            
            % Mark as processed
            processed_contrasts(contrast_name) = true;
            
            % Get the statistical data for this contrast
            stat_data = data.metadata.cfg.stats.(contrast_name);
            
            % Get the number of unique observations
            n = numel(unique(stat_data.cfg.design(2,:)));
            
            % Process positive and negative clusters
            negpos_arr = {'pos', 'neg'};
            for negpos_i = 1:numel(negpos_arr)
                negpos = negpos_arr{negpos_i};
                cluster_field = [negpos 'clusters'];
                label_field = [negpos 'clusterslabelmat'];
                
                % Check if cluster data exists and is not empty
                if isfield(stat_data, cluster_field) && ~isempty(stat_data.(cluster_field))
                    % Process each cluster
                    for clust_idx = 1:length(stat_data.(cluster_field))
                        % Get cluster mask and time indices
                        cluster_mask = stat_data.(label_field) == clust_idx;
                        time_idx = find(any(cluster_mask, 1));
                        
                        % Skip if no time points in cluster
                        if isempty(time_idx)
                            continue;
                        end
                        
                        % Calculate time range
                        time_range = stat_data.time(time_idx);
                        
                        % Calculate maximum t-value within the cluster
                        cluster_t_values = stat_data.stat .* cluster_mask;
                        max_t = max(abs(cluster_t_values(cluster_t_values ~= 0)));
                        
                        % Add to results
                        results(row, :) = {
                            [contrast_name '_' negpos], ...
                            sprintf('%.3f-%.3f', time_range(1), time_range(end)), ...
                            stat_data.(cluster_field)(clust_idx).prob, ...
                            max_t, ...
                            stat_data.(cluster_field)(clust_idx).cohensd_mean, ...
                            n
                        };
                        row = row + 1;
                    end
                end
            end
        end
    end
    
    % Create and return the table
    if ~isempty(results)
        headers = {'contrast', 'timerange', 'pval', 't_value', 'cohens_d', 'N'};
        results_table = cell2table(results, 'VariableNames', headers);
    else
        warning('No significant clusters found in any of the files.');
        results_table = table();
    end
end