function change_ft_to_ADAM_format(contrast, sovs, latency, subs, dirs, is_loo)

    output_adamformat_dir = dirs.output_adamformat;
    sovs_string = cellfun(@(x) x.import_s{1}, sovs, 'UniformOutput', false);
    cont_string = cellfun(@(x) x.import_s{1}, contrast, 'UniformOutput', false);
    
    if is_loo
        % LOO design
        symbol_table = create_symbol_table(numel(contrast), numel(subs));
        symbol_factorArray = array2table(symbol_table', 'RowNames', subs, 'VariableNames', cont_string);
        
        for sov_i = 1:numel(sovs)
            curr_sov = sovs{sov_i};
            mat_file_output_name = sprintf('loo_%s.mat', curr_sov.short_s);
            if isOutputFile(mat_file_output_name, output_adamformat_dir); continue; end
            
            subs_conds_ft = cell(1, numel(cont_string) * numel(subs));
            iter = 1;
            
            for row = 1:size(symbol_factorArray, 1)
                for col = 1:size(symbol_factorArray, 2)
                    curr_sub = symbol_factorArray.Properties.RowNames{row};
                    curr_cond = symbol_factorArray.Properties.VariableNames{col};
                    curr_symbol = symbol_factorArray{row, col};
                    
                    ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat', dirs.ft_cond_input, curr_sub, curr_sov.import_s, curr_cond);
                    ft_mat = load(ft_mat_path);
                    ft_mat = ft_mat.ft_data;
                    ft_mat.trialinfo = ones(size(ft_mat.trial, 2), 1) * curr_symbol;
                    
                    subs_conds_ft{iter} = ft_mat;
                    iter = iter + 1;
                end
            end
            
            merge_trim_and_save_data(subs_conds_ft, latency, output_adamformat_dir, mat_file_output_name);
        end
        
    else
        % No-LOO design
        symbol_table = create_symbol_table(numel(contrast), numel(sovs));
        symbol_factorArray = array2table(symbol_table, 'RowNames', cont_string, 'VariableNames', sovs_string);
        
        for sub_ind = 1:numel(subs)
            mat_file_output_name = sprintf('s-%d_allSovs.mat', sub_ind);
            if isOutputFile(mat_file_output_name, output_adamformat_dir); continue; end
            
            subs_conds_ft = cell(1, numel(cont_string) * numel(sovs));
            iter = 1;
            
            for sov_i = 1:numel(sovs)
                for cond_ind = 1:numel(cont_string)
                    ft_mat_path = sprintf('%s\\s_%s_%s_%s.mat', dirs.ft_cond_input, subs{sub_ind}, sovs{sov_i}.import_s, cont_string{cond_ind});
                    ft_mat = load(ft_mat_path);
                    ft_mat = ft_mat.ft_data;
                    curr_symbol = symbol_factorArray{cond_ind, sov_i};
                    ft_mat.trialinfo = ones(size(ft_mat.trial, 2), 1) * curr_symbol;
                    
                    subs_conds_ft{iter} = ft_mat;
                    iter = iter + 1;
                end
            end
            
            merge_trim_and_save_data(subs_conds_ft, latency, output_adamformat_dir, mat_file_output_name);
        end
        
        save_subject_indexes(subs, output_adamformat_dir);
    end
end

function merge_trim_and_save_data(subs_conds_ft, latency, output_dir, filename)
    if all(cellfun(@isempty, subs_conds_ft)); return; end
    
    merged_data = subs_conds_ft{1};
    for s = 2:numel(subs_conds_ft)
        cfg = [];
        cfg.keepsampleinfo = 'no';
        merged_data = ft_appenddata(cfg, merged_data, subs_conds_ft{s});
    end
    
    cfg = [];
    cfg.toilim = latency;
    merged_data = ft_redefinetrial(cfg, merged_data);
    
    parsave(sprintf("%s\\%s", output_dir, filename), merged_data);
end

function save_subject_indexes(subs, output_dir)
    outputFile = sprintf("%s\\subjects_indexes.txt", output_dir);
    fid = fopen(outputFile, 'w');
    if fid == -1; error('Cannot open file for writing: %s', outputFile); end
    fprintf(fid, 'Index\tString\n');
    for i = 1:length(subs)
        fprintf(fid, '%d\t%s\n', i, subs{i});
    end
    fclose(fid);
    fprintf('File saved successfully: %s\n', outputFile);
end

function isAlreadyExist = isOutputFile(output_file, output_dir)
    fullpath = sprintf("%s\\%s", output_dir, output_file);
    if isfile(fullpath)
        fprintf("%s already exists in path: %s\n", output_file, fullpath)
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end

function parsave(fname, merged_data)
    save(fname, 'merged_data', '-v7.3')
end