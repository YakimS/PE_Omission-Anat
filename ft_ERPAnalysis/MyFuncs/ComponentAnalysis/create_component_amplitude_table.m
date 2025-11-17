function [flat_table, nested_struct, metadata] = create_component_amplitude_table(subs, sovs, comps, conds, cluster, dirs, time)
% CREATE_COMPONENT_AMPLITUDE_TABLE Creates both nested structure and flat table of component amplitudes
%
% INPUTS:
%   subs                - Cell array of subject IDs
%   sovs                - Cell array of states of vigilance (e.g., wake, sleep stages)
%   comps               - Cell array of component structures (e.g., N100, P2, N350)
%   conds               - Cell array of conditions (e.g., Bl0T1, Bl0T2, etc.)
%   cluster             - Structure containing electrode cluster information
%   dirs                - Structure containing directory paths
%   time                - Time vector for ERP data
%
% OUTPUTS:
%   flat_table          - Table with component amplitudes for all combinations
%   nested_struct       - Nested structure maintaining hierarchical organization
%   metadata            - Structure containing quality control information and missing data
%
% Example usage:
%   sovs = {v.wake_night_beg, v.wake_night_end, v.wake_morning, v.N1, v.N2, v.N3, v.REM};
%   comps = {v.N100, v.P2, v.N350};
%   conds = {v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4};
%   [flat_table, nested_struct, metadata] = create_component_amplitude_table(subs, sovs, comps, conds, cluster, dirs, time);

    % Initialize outputs
    flat_table = table('Size', [0 10], ...
                      'VariableTypes', {'string', 'string', 'string', 'string', 'double', 'double', 'logical', 'double', 'string', 'string'}, ...
                      'VariableNames', {'subject', 'component', 'sov', 'cond', 'amplitude', 'latency', 'is_peak', 'trials_count', 'color_id', 'error_msg'});
    
    nested_struct = struct();
    metadata = struct();
    metadata.missing_peaks = {};
    metadata.processing_errors = {};
    metadata.total_entries = 0;
    metadata.valid_entries = 0;
    metadata.color_map = struct();  % Store color information with IDs
    metadata.metadata_comp_string = '';  % Initialize metadata_comp_string
    
    % Process each combination
    for comp_idx = 1:numel(comps)
        curr_comp = comps{comp_idx};
        comp_name = curr_comp.short_s;
        
        for sov_idx = 1:numel(sovs)
            curr_sov = sovs{sov_idx};
            sov_name = curr_sov.short_s;
            
            % Get color for this SOV and store in metadata
            color_id = sprintf('color_%s', sov_name);
            if ~isfield(metadata.color_map, color_id)
                cols = create_custom_colormap(curr_sov.color, 2);
                sov_color = cols(2,:);
                metadata.color_map.(color_id) = struct('sov', sov_name, 'color', sov_color);
            else
                sov_color = metadata.color_map.(color_id).color;
            end
            
            for cond_idx = 1:numel(conds)
                curr_cond = conds{cond_idx};
                cond_name = curr_cond.short_s;
                
                for sub_idx = 1:numel(subs)
                    sub_name = subs{sub_idx};
                    metadata.total_entries = metadata.total_entries + 1;
                    
                    % Initialize this entry in nested structure
                    if ~isfield(nested_struct, comp_name)
                        nested_struct.(comp_name) = struct();
                    end
                    if ~isfield(nested_struct.(comp_name), sov_name)
                        nested_struct.(comp_name).(sov_name) = struct();
                    end
                    if ~isfield(nested_struct.(comp_name).(sov_name), cond_name)
                        nested_struct.(comp_name).(sov_name).(cond_name) = struct();
                    end
                    
                    % Process this combination
                    result = process_single_combination(sub_name, curr_sov, curr_cond, curr_comp, ...
                                                       cluster, dirs, time);
                    
                    % Store in nested structure
                    field_name = sprintf('s_%s', sub_name);
                    result.nested_data.color = sov_color;
                    nested_struct.(comp_name).(sov_name).(cond_name).(field_name) = result.nested_data;
                    
                    % Create table row with color ID reference
                    new_row = table(string(sub_name), ...
                                   string(comp_name), ...
                                   string(sov_name), ...
                                   string(cond_name), ...
                                   result.flat_data.amplitude, ...
                                   result.flat_data.latency, ...
                                   result.flat_data.is_peak, ...
                                   result.flat_data.trials_count, ...
                                   string(color_id), ...  % Store color ID reference
                                   string(result.flat_data.error_msg), ...
                                   'VariableNames', {'subject', 'component', 'sov', 'cond', ...
                                                    'amplitude', 'latency', 'is_peak', 'trials_count', ...
                                                    'color_id', 'error_msg'});
                    
                    flat_table = [flat_table; new_row];
                    
                    % Update metadata
                    if result.is_valid
                        metadata.valid_entries = metadata.valid_entries + 1;
                    end
                    
                    % Update metadata_comp_string for missing peaks
                    if ~result.nested_data.is_peak
                        if isempty(metadata.metadata_comp_string)
                            metadata.metadata_comp_string = sprintf('___Missing peaks-troughs___\n');
                        end
                        missing_info = sprintf('Sub:%s, Sov:%s, Cond:%s, Comp:%s', ...
                                              sub_name, sov_name, cond_name, comp_name);
                        if ~contains(metadata.metadata_comp_string, missing_info)
                            metadata.metadata_comp_string = sprintf('%s%s\n', ...
                                                              metadata.metadata_comp_string, missing_info);
                        end
                        metadata.missing_peaks{end+1} = missing_info;
                    end
                    
                    if ~isempty(result.error_msg)
                        error_info = struct('subject', sub_name, 'sov', sov_name, ...
                                           'cond', cond_name, 'comp', comp_name, ...
                                           'error', result.error_msg);
                        metadata.processing_errors{end+1} = error_info;
                    end
                end
            end
        end
    end
    
    % Create summary statistics
    metadata.summary = struct();
    metadata.summary.total_entries = metadata.total_entries;
    metadata.summary.valid_entries = metadata.valid_entries;
    metadata.summary.missing_peaks_count = length(metadata.missing_peaks);
    metadata.summary.error_count = length(metadata.processing_errors);
    metadata.summary.subjects = unique(flat_table.subject);
    metadata.summary.components = unique(flat_table.component);
    metadata.summary.sovs = unique(flat_table.sov);
    metadata.summary.conditions = unique(flat_table.cond);
    metadata.summary.unique_colors = length(fieldnames(metadata.color_map));
    
    % Display summary
    fprintf('Component amplitude extraction completed:\n');
    fprintf('Total entries processed: %d\n', metadata.total_entries);
    fprintf('Valid entries: %d (%.1f%%)\n', metadata.valid_entries, ...
            100 * metadata.valid_entries / metadata.total_entries);
    fprintf('Missing peaks: %d\n', metadata.summary.missing_peaks_count);
    fprintf('Processing errors: %d\n', metadata.summary.error_count);
    fprintf('Unique colors stored: %d\n', metadata.summary.unique_colors);
end

function result = process_single_combination(sub_name, sov, cond, comp, cluster, dirs, time)
    % Initialize result structure
    result = struct();
    result.is_valid = false;
    result.error_msg = '';
    result.nested_data = struct();
    result.flat_data = struct();
    
    % Initialize with default values
    result.flat_data.amplitude = NaN;
    result.flat_data.latency = NaN;
    result.flat_data.is_peak = false;
    result.flat_data.trials_count = NaN;
    result.flat_data.error_msg = '';
    
    try
        % Get functions for this combination
        f = ADAPTATION_get_funcs_instant({sub_name}, {sov}, {cond}, dirs.ft_cond_input, dirs.ft_cond_output, time);
        
        % Get timelocked data
        curr_cond_timelocked = f.imp.get_cond_timelocked(f.imp, {sub_name}, cond, sov);
        
        if isempty(curr_cond_timelocked) || ~iscell(curr_cond_timelocked)
            throw(MException('DataProcessing:NoData', 'No data returned from get_cond_timelocked'));
        end
        
        curr_cond_timelocked = curr_cond_timelocked{1};
        
        % Check for required fields
        if ~isfield(curr_cond_timelocked, 'cfg') || ~isfield(curr_cond_timelocked.cfg, 'trials_timelocked_avg')
            throw(MException('DataProcessing:MissingFields', 'Required fields missing in timelocked data'));
        end
        
        % Store trial count
        trials_count = curr_cond_timelocked.cfg.trials_timelocked_avg;
        result.flat_data.trials_count = trials_count;
        result.nested_data.trials_timelocked_avg = trials_count;
        
        % Average over cluster channels
        cfg = [];
        cfg.channel = cluster.elect_label;
        cfg.avgoverchan = 'yes';
        curr_cond_timelocked = ft_selectdata(cfg, curr_cond_timelocked);
        
        % Get mean signal
        curr_signal = squeeze(curr_cond_timelocked.avg);
        
        % Find component peak/trough
        comp_time_idx = find(f.imp.epoch_time >= comp.latency(1) & f.imp.epoch_time <= comp.latency(2));
        
        if isempty(comp_time_idx)
            throw(MException('DataProcessing:InvalidTimeWindow', 'No time points within component window'));
        end
        
        comp_data = curr_signal(comp_time_idx);
        is_peak = true;
        
        if comp.isPositive
            % Find positive peak
            [~, extreme_idx] = findpeaks(comp_data, 'NPeaks', 1, 'SortStr', 'descend');
            if isempty(extreme_idx)
                is_peak = false;
                [~, extreme_idx] = max(comp_data);
            end
        else
            % Find negative peak
            [~, extreme_idx] = findpeaks(-comp_data, 'NPeaks', 1, 'SortStr', 'descend');
            if isempty(extreme_idx)
                is_peak = false;
                [~, extreme_idx] = min(comp_data);
            end
        end
        
        % Calculate latency and amplitude
        actual_idx = comp_time_idx(extreme_idx);
        latency = f.imp.epoch_time(actual_idx);
        
        % Find exact time point in timelocked data
        tolerance = 1e-6;
        time_idx = find(abs(curr_cond_timelocked.time - latency) < tolerance);
        
        if isempty(time_idx)
            amplitude = curr_signal(actual_idx);
        else
            amplitude = curr_cond_timelocked.avg(time_idx);
        end
        
        % Store results
        result.flat_data.amplitude = amplitude;
        result.flat_data.latency = latency;
        result.flat_data.is_peak = is_peak;
        
        result.nested_data.amplitude = amplitude;
        result.nested_data.latency = latency;
        result.nested_data.is_peak = is_peak;
        
        result.is_valid = true;
        
    catch ME
        result.error_msg = ME.message;
        result.flat_data.error_msg = ME.message;
        
        % Set default values for nested structure
        result.nested_data.amplitude = NaN;
        result.nested_data.latency = NaN;
        result.nested_data.is_peak = false;
        result.nested_data.color = [0, 0, 0]; % Black for errors
    end
end