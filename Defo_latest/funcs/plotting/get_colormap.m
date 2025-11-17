function custom_colormap = get_colormap(sovs, conds, by_cond_or_sov)
    if strcmp(by_cond_or_sov, 'cond')
        var = conds;
    elseif strcmp(by_cond_or_sov, 'sov')
        var = sovs;
    end

    color_values = cellfun(@(x) x.color, var, 'UniformOutput', false);
    color_strings = cellfun(@(x) num2str(x(:)'), color_values, 'UniformOutput', false);
    [unique_colors, ~, idx] = unique(color_strings);
    counts = accumarray(idx, 1)';
    
    var_table = table(unique_colors, counts, zeros(size(unique_colors)), ...
        'VariableNames', {'color_str', 'count', 'used'});
    
    custom_colormap = zeros(numel(sovs), 3);
    
    for i = 1:numel(sovs)
        current_color = var{i}.color;
        current_color_str = num2str(current_color(:)');
        row = find(strcmp(var_table.color_str, current_color_str));
        var_table.used(row) = var_table.used(row) + 1;
        var_colormap = create_custom_colormap(current_color, var_table.count(row));
        custom_colormap(i,:) = var_colormap(var_table.used(row),:);
    end
end



                