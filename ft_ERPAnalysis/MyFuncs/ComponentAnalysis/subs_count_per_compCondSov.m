function subs_count_per_compCondSov(flat_table, excel_filename)
%SUBS_COUNT_PER_COMPCONDSTOV Count subjects with identifiable peaks per component-condition-SOV combination
%   [excel_filename, num_components] = subs_count_per_compCondSov(flat_table, excel_filename)
%   
%   Inputs:
%   - flat_table: Table with columns 'component', 'name_sov_long', 'name_cond_long', 'is_peak', 'subject'
%   - excel_filename:Output Excel filename. E.g.: 'component_ispeak_subs_counts.xlsx'
%   
%   
%   Creates an Excel file with one tab per component, showing count of subjects
%   with identifiable peaks (is_peak = 1) for each condition-SOV combination.

    
    % Get unique values
    components = unique(flat_table.component);
    sovs_name_long = unique(flat_table.name_sov_long);
    conds_name_long = unique(flat_table.name_cond_long);
    
    % Process each component
    for i = 1:length(components)
        current_component = components{i};
        
        % Filter data for current component and is_peak = 1
        comp_data = flat_table(strcmp(flat_table.component, current_component) & flat_table.is_peak == 1, :);
        
        % Initialize count matrix
        count_matrix = zeros(length(conds_name_long), length(sovs_name_long));
        
        % Count unique subjects for each sov-cond combination
        for j = 1:length(conds_name_long)
            for k = 1:length(sovs_name_long)
                % Find subjects with this specific cond-sov combination
                matching_rows = strcmp(comp_data.name_cond_long, conds_name_long{j}) & ...
                               strcmp(comp_data.name_sov_long, sovs_name_long{k});
                unique_subjects = unique(comp_data.subject(matching_rows));
                count_matrix(j, k) = length(unique_subjects);
            end
        end
        
        % Create table with proper headers
        result_table = array2table(count_matrix, ...
            'VariableNames', sovs_name_long, ...
            'RowNames', conds_name_long);
        
        % Convert row names to a column for Excel compatibility
        result_table = addvars(result_table, conds_name_long, 'Before', 1, 'NewVariableNames', 'Condition');
        
        % Write to Excel sheet
        sheet_name = matlab.lang.makeValidName(current_component); % Ensure valid sheet name
        writetable(result_table, excel_filename, 'Sheet', sheet_name);
    end
    fprintf('Excel file "%s" created with %d component tabs.\n', excel_filename, length(components));
end