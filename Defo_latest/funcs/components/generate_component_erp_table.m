function [res_fdrCorrected, res_fdrComponentwiseCorrected] = generate_component_erp_table(file_pattern, excluded_conds)
% GENERATE_COMPONENT_ERP_TABLE Extract Wilcoxon statistics from component ERP data files
%
% INPUTS:
%   file_pattern    - File pattern to match (e.g., 'path/to/data/Comp-*_clust-centElec.mat')
%   excluded_conds  - Optional cell array of conditions to exclude (e.g., {'Bl0T3','Bl0T4'})
%
% OUTPUTS:
%   res_fdrCorrected              - Table containing stats with global FDR correction
%   res_fdrComponentwiseCorrected - Table containing stats with component-wise FDR correction

    % Validate inputs
    if nargin < 1
        error('file_pattern is required');
    end
    
    if nargin < 2 || isempty(excluded_conds)
        excluded_conds = {};
    end
    
    % Define headers for the results tables
    headers = {'SignificanceLevel', 'comp', 'sovcond1', 'sovcond2', ...
        'Pval', 'Pval_fdrCorrected', 'CorrectedAboveThreshold', ...
        'sigAfterCorrection', 'W', 'N', 'r', 'mdn1', 'mdn2', 'iqr1', 'iqr2'};
    
    % Get list of files matching the pattern
    files = dir(file_pattern);
    
    % Check if any files were found
    if isempty(files)
        warning('No files found matching pattern: %s', file_pattern);
        res_fdrCorrected = table();
        res_fdrComponentwiseCorrected = table();
        return;
    end
    
    % Extract data from files (Phase 1)
    [raw_results, component_map] = extract_data_from_files(files, excluded_conds);
    
    if isempty(raw_results)
        warning('No valid results found in any of the files.');
        res_fdrCorrected = table();
        res_fdrComponentwiseCorrected = table();
        return;
    end
    
    % Apply FDR corrections and create tables (Phase 2)
    [res_fdrCorrected, res_fdrComponentwiseCorrected] = create_result_tables(raw_results, component_map, headers);
end

function [raw_results, component_map] = extract_data_from_files(files, excluded_conds)
    % Initialize storage
    raw_results = {};
    component_map = containers.Map('KeyType', 'char', 'ValueType', 'any');
    rowIdx = 1;
    
    % Process each file
    for file_i = 1:numel(files)
        % Load the data file
        file_path = fullfile(files(file_i).folder, files(file_i).name);
        data = load(file_path);
        
        % Check if the required fields exist
        if ~isfield(data, 'metadata') || ~isfield(data.metadata, 'cfg') || ~isfield(data.metadata.cfg, 'wilcoxon_stats')
            warning('File %s does not contain wilcoxon_stats. Skipping.', files(file_i).name);
            continue;
        end
        
        % Extract component name from filename
        [~, fname, ~] = fileparts(files(file_i).name);
        parts = strsplit(fname, '_');
        comp_part = parts{1};
        comp_name = strsplit(comp_part, '-');
        comp_name = comp_name{2}; % Extract component name
        
        % Get the Wilcoxon stats
        stats = data.metadata.cfg.wilcoxon_stats;
        
        % Process each comparison
        for j = 1:length(stats)
            % Skip excluded conditions
            matches = any(cellfun(@(x) contains(stats(j).sovcond1, x) || contains(stats(j).sovcond2, x), excluded_conds));
            if matches
                continue;
            end
            
            % Store all results
            raw_results{rowIdx}.pval = stats(j).p;
            raw_results{rowIdx}.comp = comp_name;
            raw_results{rowIdx}.sovcond1 = stats(j).sovcond1;
            raw_results{rowIdx}.sovcond2 = stats(j).sovcond2;
            raw_results{rowIdx}.W = stats(j).W;
            raw_results{rowIdx}.N = stats(j).N;
            raw_results{rowIdx}.r = stats(j).r;
            raw_results{rowIdx}.mdn1 = stats(j).mdn1;
            raw_results{rowIdx}.mdn2 = stats(j).mdn2;
            raw_results{rowIdx}.iqr1 = stats(j).iqr1;
            raw_results{rowIdx}.iqr2 = stats(j).iqr2;
            
            % Track component indices for later component-wise FDR
            if ~isKey(component_map, comp_name)
                component_map(comp_name) = [];
            end
            component_map(comp_name) = [component_map(comp_name), rowIdx];
            
            rowIdx = rowIdx + 1;
        end
    end
end

function [res_fdrCorrected, res_fdrComponentwiseCorrected] = create_result_tables(raw_results, component_map, headers)
    % Prepare for FDR corrections
    all_pvals = cellfun(@(x) x.pval, raw_results);
    
    % Global FDR correction
    global_fdr_corrected = mafdr(all_pvals, 'BHFDR', true);
    
    % Prepare result arrays
    global_results = cell(length(raw_results), length(headers));
    comp_results = cell(length(raw_results), length(headers));
    
    % Process component-wise FDR corrections
    comp_names = keys(component_map);
    comp_fdr_values = cell(length(raw_results), 1);
    
    for i = 1:length(comp_names)
        comp_name = comp_names{i};
        indices = component_map(comp_name);
        comp_pvals = all_pvals(indices);
        
        % Component-wise FDR correction
        comp_corrected = mafdr(comp_pvals, 'BHFDR', true);
        
        % Store back in main array
        for j = 1:length(indices)
            comp_fdr_values{indices(j)} = comp_corrected(j);
        end
    end
    
    % Build result rows for both tables in one loop
    for i = 1:length(raw_results)
        % Get values 
        result = raw_results{i};
        pval = result.pval;
        global_fdr = global_fdr_corrected(i);
        comp_fdr = comp_fdr_values{i};
        
        % Global FDR row
        global_results(i,:) = create_result_row(result, pval, global_fdr);
        
        % Component FDR row
        comp_results(i,:) = create_result_row(result, pval, comp_fdr);
    end
    
    % Create the tables
    res_fdrCorrected = cell2table(global_results, 'VariableNames', headers);
    res_fdrComponentwiseCorrected = cell2table(comp_results, 'VariableNames', headers);
end

function row = create_result_row(result, pval, pval_fdr)
    % Determine significance level
    if pval_fdr < 0.001
        sigLevel = '***';
    elseif pval_fdr < 0.01
        sigLevel = '**';
    elseif pval_fdr < 0.05
        sigLevel = '*';
    else
        sigLevel = 'n.s.';
    end
    
    % Significance flags
    correctedAboveThresh = (pval < 0.05) && (pval_fdr >= 0.05);
    sigAfterCorr = pval_fdr < 0.05;
    
    % Create the results row
    row = {sigLevel, result.comp, result.sovcond1, result.sovcond2, ...
        pval, pval_fdr, correctedAboveThresh, sigAfterCorr, ...
        result.W, result.N, result.r, ...
        result.mdn1, result.mdn2, result.iqr1, result.iqr2};
end