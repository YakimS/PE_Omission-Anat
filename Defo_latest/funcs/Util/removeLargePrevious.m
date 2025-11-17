function s = removeLargePrevious(s)
    SIZE_LIMIT = 2 * 1024 * 1024;
    
    if nargin ~= 1 || ~isstruct(s)
        return
    end
    
    fields = fieldnames(s);
    for i = 1:length(fields)
        field = fields{i};
        
        if contains(lower(field), 'previous')
            temp = whos('s', field); % Check size of specific field
            if temp(1).bytes > SIZE_LIMIT
                s = rmfield(s, field);
                continue;
            end
        end
        
        if isfield(s, field) % Still in struct
            try
                fieldVal = s.(field);
                if isstruct(fieldVal)
                    s.(field) = removeLargePrevious(fieldVal);
                end
            catch
                continue
            end
        end
    end
end