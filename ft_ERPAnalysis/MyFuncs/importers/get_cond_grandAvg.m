function cond_grandAvg = get_cond_grandAvg(subs, cond, sov, input_dir, output_dir)
    % Compute or load grand average across subjects for specific condition and SOV
    % 
    % Inputs:
    %   subs - cell array of subject IDs
    %   cond - condition struct with short_s field
    %   sov - SOV struct with short_s field
    %   input_dir - directory containing raw input files
    %   output_dir - directory for cached output files
    %
    % Output:
    %   cond_grandAvg - grand average FieldTrip structure
    
    cfg = [];
    file_path = sprintf("%s//timelock_grandAvg_%s_cond-%s.mat",output_dir,sov.short_s,cond.short_s);
    try
        loaded = load(file_path);
        cond_grandAvg = loaded.timelockGrandavg_cond;
    catch ME
        timlocked = get_cond_timelocked(subs,cond,sov,input_dir,output_dir);
        cond_grandAvg  = ft_timelockgrandaverage(cfg, timlocked{:});

        %save
        timelockGrandavg_cond = cond_grandAvg;
        save(sprintf("%s/timelocked_cond-%s_sub-avg.mat",output_dir,cond.short_s),"timelockGrandavg_cond")
    end
end 