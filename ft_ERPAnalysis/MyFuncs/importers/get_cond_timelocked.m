function subs_cond_timlocked = get_cond_timelocked(subs, cond, sov, input_dir, output_dir)
    % Load or compute timelocked data for specific subjects, condition, and SOV
    % 
    % Inputs:
    %   subs - cell array of subject IDs
    %   cond - condition struct with import_s and short_s fields
    %   sov - SOV struct with import_s and short_s fields
    %   input_dir - directory containing raw input files
    %   output_dir - directory for cached output files
    %
    % Output:
    %   subs_cond_timlocked - cell array of timelocked data for each subject
    
    subs_cond_timlocked = cell(1, size(subs,2));
    for sub_i=1:size(subs,2)
        file_path = sprintf("%s\\timelocked_sov-%s_cond-%s_sub-%s.mat",output_dir,sov.short_s,cond.short_s,subs{sub_i});
        try
            loaded = load(file_path);
            subs_cond_timlocked{sub_i} = loaded.timelocked_subcond;
            error_if_less_than_5_trials(subs{sub_i},cond, sov, subs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg'))
        catch ME
            cfg = [];
            cfg.feedback = 'no';
            conds_ftraw = get_rawFt_cond(subs,cond,sov,input_dir);
            subs_cond_timlocked{sub_i} = ft_timelockanalysis(cfg, conds_ftraw{sub_i});
            subs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg') = numel(conds_ftraw{sub_i}.trial);
            error_if_less_than_5_trials(subs{sub_i},cond, sov, subs_cond_timlocked{sub_i}.cfg.('trials_timelocked_avg'))
            %save
            timelocked_subcond = subs_cond_timlocked{sub_i};
            save(file_path,"timelocked_subcond")
        end
    end
end 