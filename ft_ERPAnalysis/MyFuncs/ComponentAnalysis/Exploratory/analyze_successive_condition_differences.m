function resultTable = analyze_successive_condition_differences(output_dir, comps, contrasts, sovs, sovgroup_name, cfg)
% ANALYZE_SUCCESSIVE_CONDITION_DIFFERENCES Compares differences between successive conditions across SOV groups
%
% Analyzes how the difference between successive conditions (e.g., T1-T2, T2-T3) 
% varies across different states of vigilance (SOVs), performing statistical comparisons
% and visualizations for each component.
%
% INPUTS:
%   output_dir     - Directory containing component data files and for saving results
%   comps          - Cell array of ERP component structures (e.g., {v.N100, v.P2, v.N350})
%                    Each component should have fields: .short_s (name), .latency
%   contrasts      - Cell array of contrast names (e.g., {'T1-T2', 'T2-T3', 'T3-T4'})
%                    These define which successive differences to analyze
%   sovs           - Cell array of SOV structures to compare
%                    Each SOV should have fields: .short_s (name), .color
%   sovgroup_name  - String identifier for this SOV group (used in filenames)
%   cfg            - Configuration structure with fields:
%                    .color_by_cond_or_sov - Color scheme ('sov' or 'cond')
%                    .is_fdr_inside_comp - Boolean for FDR correction scope
%                                          true: correct within each component
%                                          false: correct across all tests
%                    .ylim_ - Y-axis limits for plots (e.g., [-10, 10])
%                    .ticksY - Y-axis tick marks (e.g., -8:4:8)
%                    .is_remove_no_peak_outliers - Always set to 0 for this analysis
%                    Additional fields may be passed to plotting functions
%
% OUTPUTS:
%   resultTable    - Table with statistical comparison results including:
%                    - Component, Contrast, SOV comparison, p-values
%                    - FDR-corrected p-values and significance levels
%
% Example usage:
%   cfg = struct('color_by_cond_or_sov', 'sov', 'is_fdr_inside_comp', false, ...
%                'ylim_', [-10, 10], 'ticksY', -8:4:8);
%   results = analyze_successive_condition_differences(subs, comp_dir, comps, ...
%                                                     conds, {'T1m2', 'T2m3'}, ...
%                                                     sovs, 'N2_events', out_dir, cfg);

    cfg.is_remove_no_peak_outliers =0; % DONT CHANGE. in T1m2m3m4 is_remove_no_peak_outliers doesnt makes sense
    
    % Initialize result table
    resultTable = table([], [], [], [], 'VariableNames', {'Comp', 'Contrast', 'SOVComparison', 'Pval'});
    
    % Check if results already exist
    output_filename = sprintf("%s\\%s_successive_diff_results.csv", output_dir, sovgroup_name);
    if isfile(output_filename)
        fprintf('Loading existing results from: %s\n', output_filename);
        resultTable = readtable(output_filename);
        return;
    end
    
    % Process each component and contrast
    for comp_idx = 1:numel(comps)
        comp = comps{comp_idx};
        comp_name = comp.short_s;
        
        for contrast_idx = 1:numel(contrasts)
            contrast = contrasts{contrast_idx};
            
            % Load and align data across all SOVs
            [aligned_data, subject_ids] = load_and_align_sov_data(output_dir, ...
                                                                  comp_name, sovs);
            
            % Calculate successive differences
            diff_data = calculate_successive_differences(aligned_data, contrast_idx);
            
            % Prepare data for comparison
            comparison_data = zeros(numel(subject_ids), numel(sovs));
            sov_labels = cell(1, numel(sovs));
            
            for sov_idx = 1:numel(sovs)
                comparison_data(:, sov_idx) = diff_data{sov_idx};
                sov_labels{sov_idx} = sovs{sov_idx}.short_s;
            end
            
            % Perform pairwise SOV comparisons
            comparison_results = perform_sov_comparisons(comparison_data, sov_labels, comp_name, contrast);
            
            % Add results to table
            resultTable = [resultTable; comparison_results];

            colormap = get_colormap(sovs,sovs,'sov');
            
            % Create visualization
            create_comparison_plot( comparison_data, colormap, sov_labels, subject_ids, ...
                                  comp, contrast, sovgroup_name, output_dir, cfg);
        end
    end
    
    % Apply FDR correction
    resultTable = apply_fdr_correction(resultTable, cfg.is_fdr_inside_comp);
    
    % Save results
    writetable(resultTable, output_filename);
end

function [aligned_data, subject_ids] = load_and_align_sov_data(comp_output_dir, comp_name, sovs)
    % Load data for all SOVs and align by subjects
    
    % First pass: collect all unique subjects
    all_subjects = {};
    for sov_idx = 1:numel(sovs)
        filename = sprintf("%s\\Comp-%s_name-T1234-%s-noOutliers_clust-centElec.mat", ...
                          comp_output_dir, comp_name, sovs{sov_idx}.short_s);
        
        if ~isfile(filename)
            error('File not found: %s', filename);
        end
        
        loaded_data = load(filename);
        all_subjects = union(all_subjects, loaded_data.metadata.subs, 'stable');
    end
    
    subject_ids = all_subjects;
    aligned_data = cell(1, numel(sovs));
    
    % Second pass: create aligned data matrices
    for sov_idx = 1:numel(sovs)
        filename = sprintf("%s\\Comp-%s_name-T1234-%s-noOutliers_clust-centElec.mat", ...
                          comp_output_dir, comp_name, sovs{sov_idx}.short_s);
        
        loaded_data = load(filename);
        current_subs = loaded_data.metadata.subs;
        current_data = loaded_data.metadata.data;
        
        % Align data to common subject order
        aligned_matrix = nan(numel(subject_ids), size(current_data, 2));
        
        for sub_idx = 1:numel(subject_ids)
            match_idx = find(strcmp(current_subs, subject_ids{sub_idx}));
            if ~isempty(match_idx)
                aligned_matrix(sub_idx, :) = current_data(match_idx, :);
            end
        end
        
        aligned_data{sov_idx} = aligned_matrix;
    end
end

function diff_data = calculate_successive_differences(aligned_data, contrast_idx)
    % Calculate successive differences (T1-T2, T2-T3, or T3-T4)
    
    diff_data = cell(size(aligned_data));
    
    for sov_idx = 1:numel(aligned_data)
        data = aligned_data{sov_idx};
        
        % Calculate all possible differences
        diff_matrix = nan(size(data, 1), 3);
        diff_matrix(:, 1) = data(:, 1) - data(:, 2);  % T1-T2
        diff_matrix(:, 2) = data(:, 2) - data(:, 3);  % T2-T3
        if size(data, 2) >= 4
            diff_matrix(:, 3) = data(:, 3) - data(:, 4);  % T3-T4
        end
        
        % Select the requested contrast
        diff_data{sov_idx} = diff_matrix(:, contrast_idx);
    end
end

function comparison_results = perform_sov_comparisons(comparison_data, sov_labels, comp_name, contrast)
    % Perform pairwise comparisons between SOVs
    
    comparison_results = table();
    
    for i = 1:numel(sov_labels)
        for j = (i+1):numel(sov_labels)
            % Get valid subjects (non-NaN in both conditions)
            valid_mask = ~isnan(comparison_data(:, i)) & ~isnan(comparison_data(:, j));
            
            if sum(valid_mask) < 5  % Minimum subjects required
                continue;
            end
            
            data_i = comparison_data(valid_mask, i);
            data_j = comparison_data(valid_mask, j);
            
            % Perform Wilcoxon signed-rank test
            [p_value, ~, ~] = signrank(data_i - data_j);
            
            % Create comparison label
            comparison_label = sprintf("%s_vs_%s", sov_labels{i}, sov_labels{j});
            
            % Add to results
            new_row = table({comp_name}, {contrast}, {comparison_label}, p_value, ...
                           'VariableNames', {'Comp', 'Contrast', 'SOVComparison', 'Pval'});
            comparison_results = [comparison_results; new_row];
        end
    end
end

function create_comparison_plot(comparison_data, colormap,sov_labels, subject_ids, comp, contrast, sovgroup_name, output_dir, cfg)
    % Create violin plot for SOV comparisons
    
    % Remove subjects with missing data in any SOV
    valid_subjects = all(~isnan(comparison_data), 2);
    plot_data = comparison_data(valid_subjects, :);
    
    if isempty(plot_data)
        warning('No complete data for plotting %s - %s', comp.short_s, contrast);
        return;
    end
    
    % Prepare plot configuration
    plot_cfg = cfg;
    plot_cfg.title_ = sprintf('%s Component - %s Contrast', comp.short_s, contrast);
    plot_cfg.subtitle_ = sprintf('\nTotal subjects: %d\nComplete data: %d\n', ...
                                length(subject_ids), sum(valid_subjects));
    
    % Calculate statistics for display
    stats_text = calculate_comparison_statistics(plot_data, sov_labels);
    plot_cfg.bottom_string = stats_text;

    output_filename = sprintf("%s\\Comp-%s_contrast-%s_sovs-%s_clust-%s", output_dir, comp.short_s, contrast, sovgroup_name,"centElec");
    
    
    plot_violins(sov_labels, plot_data, output_filename, colormap, valid_subjects, plot_cfg);
end

function stats_text = calculate_comparison_statistics(data, labels)
    % Calculate pairwise statistics for display
    
    stats_text = sprintf("___Pairwise Comparisons___\n");
    
    for i = 1:size(data, 2)
        for j = (i+1):size(data, 2)
            % Calculate statistics
            diff = data(:, i) - data(:, j);
            [p_value, ~, ~] = signrank(diff);
            effect_size = mean(diff) / std(diff);  % Cohen's d
            
            % Add to text
            stats_text = sprintf("%s%s vs %s: p=%.4f, d=%.3f, n=%d\n", ...
                                stats_text, labels{i}, labels{j}, ...
                                p_value, effect_size, length(diff));
        end
    end
    
    return;
end

function resultTable = apply_fdr_correction(resultTable, is_within_component)
    % Apply FDR correction to p-values
    
    if is_within_component
        % Apply FDR correction within each component
        unique_comps = unique(resultTable.Comp);
        fdr_corrected = zeros(height(resultTable), 1);
        
        for comp = unique_comps'
            comp_mask = strcmp(resultTable.Comp, comp);
            comp_pvals = resultTable.Pval(comp_mask);
            fdr_corrected(comp_mask) = mafdr(comp_pvals, 'BHFDR', true);
        end
    else
        % Apply FDR correction across all comparisons
        fdr_corrected = mafdr(resultTable.Pval, 'BHFDR', true);
    end
    
    % Add FDR-corrected values and significance indicators
    resultTable.Pval_fdrCorrected = fdr_corrected;
    resultTable.FDR_Significant = fdr_corrected < 0.05;
    
    % Add significance level markers
    sig_levels = repmat({''}, height(resultTable), 1);
    sig_levels(fdr_corrected < 0.001) = {'***'};
    sig_levels(fdr_corrected >= 0.001 & fdr_corrected < 0.01) = {'**'};
    sig_levels(fdr_corrected >= 0.01 & fdr_corrected < 0.05) = {'*'};
    
    % Insert at beginning of table
    resultTable = addvars(resultTable, sig_levels, 'Before', 'Comp', ...
                         'NewVariableNames', 'SignificanceLevel');
end