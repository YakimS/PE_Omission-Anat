function subs_raw_sovcond = get_rawFt_cond(subs, cond, sov, input_dir)
    % Load raw FieldTrip data for specific subjects, condition, and SOV
    % 
    % Inputs:
    %   subs - cell array of subject IDs
    %   cond - condition struct with import_s field
    %   sov - SOV struct with import_s and short_s fields  
    %   input_dir - directory containing input files
    %
    % Output:
    %   subs_raw_sovcond - cell array of raw FieldTrip data for each subject
    
    subs_raw_sovcond = cell(1, size(subs,2));
    for sub_i=1:size(subs,2)
        if contains(sov.short_s,'WAll') % import both wake night and morning
            file_path_ngt = sprintf("%s\\s_%s_%s_%s.mat",input_dir,subs{sub_i},'wake_night',cond.import_s);
            file_path_mng = sprintf("%s\\s_%s_%s_%s.mat",input_dir,subs{sub_i},'wake_morning',cond.import_s);
            try
                sub_data_ngt = load(file_path_ngt);
                sub_data_mng = load(file_path_mng);

                cfg = [];
                ft_data =  ft_appenddata(cfg, sub_data_ngt.ft_data, sub_data_mng.ft_data);
                ft_data.elec = sub_data_ngt.ft_data.elec;
                subs_raw_sovcond{sub_i} = ft_data;
            catch ME
                sprintf('cant find: %s\n or: %s', file_path_ngt,file_path_mng)
            end                            
        else     % import only one cond 
            file_path = sprintf("%s\\s_%s_%s_%s.mat",input_dir,subs{sub_i},sov.import_s,cond.import_s);
            try
                sub_data = load(file_path);
                subs_raw_sovcond{sub_i} = sub_data.ft_data;
            catch ME
                sprintf('cant find: %s', file_path)
            end
        end
    end
end 