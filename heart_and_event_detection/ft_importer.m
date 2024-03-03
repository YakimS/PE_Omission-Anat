classdef ft_importer < handle
    properties (SetAccess = private)
      subs
      input_dir
      output_dir
      baseline_length
      choosenSuffix
      time0_ind
      
      ftRaw
      timlocked
      timlocked_bl
      raw_bl
      grandAvg
      neighbours
    end
    methods(Static)
        % constructor
        function o = ft_importer(subs, input_dir,output_dir, baseline_length,choosenSuffix)
            o.subs = subs;
            o.input_dir = input_dir;
            o.output_dir = output_dir;
            o.baseline_length = baseline_length;
            o.choosenSuffix = choosenSuffix;

            o.ftRaw = {};
            o.timlocked = {};
            o.timlocked_bl = {};
            o.raw_bl = {};
            o.grandAvg = {};
        end

        % get/set

        function s = get_subs(o)
            s = o.subs;
        end
        function s = get_input_dir(o)
            s = o.input_dir;
        end
        function s = get_output_dir(o)
            s = o.output_dir;
        end
        function s = get_baseline_length(o)
            s = o.baseline_length;
        end
        function s = get_choosenSuffix(o)
            s = o.choosenSuffix;
        end
        function s = get_time0_ind(o)
            s = o.time0_ind;
        end

        function neighbours = get_neighbours(o)
            if isempty(o.neighbours)
                cfg = [];
                cfg.method = 'triangulation' ; 
                cfg.feedback    = 'no';
                elec       = ft_read_sens('GSN-HydroCel-257.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'
                cfg.elec=elec;
                o.neighbours = ft_prepare_neighbours(cfg);
            end
            neighbours = o.neighbours;
        end


        function cond_ftRaw = get_rawFt_cond(o,cond)
            if ~isfield(o.ftRaw,cond)
                ft_subs_cond = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    if contains(o.choosenSuffix,'all') % import both wake night and morning
                        file_path_ngt = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},'wake_night',cond);
                        file_path_mng = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},'wake_morning',cond);
                        try
                            sub_data_ngt = load(file_path_ngt);
                            sub_data_mng = load(file_path_mng);

                            cfg = [];
                            ft_data =  ft_appenddata(cfg, sub_data_ngt.ft_data, sub_data_mng.ft_data);
                            ft_subs_cond{sub_i} = ft_data;
                        catch ME
                            sprintf('cant find: %s\n or: %s', file_path_ngt,file_path_mng)
                        end                            
                    else     % import only one cond 
                        file_path = sprintf("%s\\s_%s_%s_%s.mat",o.input_dir,o.subs{sub_i},o.choosenSuffix,cond);
                        try
                            sub_data = load(file_path);
                            ft_subs_cond{sub_i} = sub_data.ft_data;
                        catch ME
                            sprintf('cant find: %s', file_path)
                        end
                    end
                end
                o.ftRaw.(cond) = ft_subs_cond;
            end
            exmp_sub = o.ftRaw.(cond){1};
            time_exmp_sub = exmp_sub.time{1};
            [~, time0_ind] = min(abs(time_exmp_sub));
            o.time0_ind = time0_ind;
            cond_ftRaw = o.ftRaw.(cond);
        end
        
        function cond_timlocked = get_cond_timelocked(o,cond)
            if ~isfield(o.timlocked,cond)
                allsubs_cond_timlocked = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    file_path = sprintf("%s\\timelocked_%s_cond-%s_sub-%s.mat",o.output_dir,o.choosenSuffix,cond,o.subs{sub_i});
                    try
                        loaded = load(file_path);
                        allsubs_cond_timlocked{sub_i} = loaded.timelocked_subcond;
                    catch ME
                        cfg = [];
                        conds_ftraw = o.get_rawFt_cond(o,cond);
                        allsubs_cond_timlocked{sub_i} = ft_timelockanalysis(cfg, conds_ftraw{sub_i});
                        allsubs_cond_timlocked{sub_i}.('trials_timelocked_avg') = numel(conds_ftraw{sub_i}.trial);
                        %save
                        timelocked_subcond = allsubs_cond_timlocked{sub_i};
                        save(file_path,"timelocked_subcond")
                    end
                end
                o.timlocked.(cond) = allsubs_cond_timlocked;
            end
            cond_timlocked = o.timlocked.(cond);
        end
        
        function cond_timlockedBl = get_cond_timelockedBl(o,cond)
            if ~isfield(o.timlocked_bl,cond)
                allsubs_cond_timlockedBl = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    file_path = sprintf("%s//bl%dms-timelocked_%s_cond-%s_sub-%s.mat",o.output_dir,o.baseline_length,o.choosenSuffix,cond,o.subs{sub_i});
                    try
                        loaded = load(file_path);
                        allsubs_cond_timlockedBl{sub_i} = loaded.baseline_subcond;
                    catch ME
                        timlocked = o.get_cond_timelocked(o,cond);
                        [~, time0_ind] = min(abs(timlocked{sub_i}.time));
                        o.time0_ind = time0_ind;
                        tolerance = 1e-10;
                        time_baseline_ind = find(abs( timlocked{sub_i}.time + o.baseline_length*0.001) < tolerance);
                        
                        baseline = timlocked{sub_i}.avg(:,time_baseline_ind:time0_ind);
                        concatenatedArray = repmat(baseline, 1, floor(numel(timlocked{sub_i}.time)/numel(time_baseline_ind:time0_ind)));
                        
                        allsubs_cond_timlockedBl{sub_i} = rmfield(timlocked{sub_i},["dof","var"]);
                        allsubs_cond_timlockedBl{sub_i}.avg(:,1:size(concatenatedArray,2)) = concatenatedArray;
                        allsubs_cond_timlockedBl{sub_i}.avg(:,size(concatenatedArray,2)+1:numel(timlocked{sub_i}.time)) = concatenatedArray(:,1:numel(timlocked{sub_i}.time)-size(concatenatedArray,2));
                        
                        %save
                        baseline_subcond = allsubs_cond_timlockedBl{sub_i};
                        save(file_path,"baseline_subcond")
                    end
                end
                o.timlocked_bl.(cond) = allsubs_cond_timlockedBl;
            end
            cond_timlockedBl = o.timlocked_bl.(cond);
        end

        function cond_rawBl = get_cond_rawBl(o,cond)
            if ~isfield(o.raw_bl,cond)
                allsubs_cond_rawBl = cell(1, size(o.subs,2));
                for sub_i=1:size(o.subs,2)
                    file_path = sprintf("%s//bl%dms-raw_%s_cond-%s_sub-%s.mat",o.output_dir,o.baseline_length,o.choosenSuffix,cond,o.subs{sub_i});
                    try
                        loaded = load(file_path);
                        allsubs_cond_rawBl{sub_i} = loaded.baseline_subcond;
                    catch ME
                        rawFt = o.get_rawFt_cond(o,cond);
                        curr_sub_raw_ft = rawFt{sub_i};
                        time0_ind = find(curr_sub_raw_ft.time{1} == 0, 1);
                        time_baseline_ind = find(curr_sub_raw_ft.time{1} == -o.baseline_length*0.001, 1);
                        allsubs_cond_rawBl{sub_i} = curr_sub_raw_ft;
                        for trial_i=1:size(curr_sub_raw_ft.trial,2)
                            baseline = curr_sub_raw_ft.trial{trial_i}(:,time_baseline_ind:time0_ind);
                            baseline_mean = mean(baseline,2);
                            new_baseline_avg = ones(size(curr_sub_raw_ft.trial{trial_i})) .* baseline_mean;
                            allsubs_cond_rawBl{sub_i}.trial{trial_i} = new_baseline_avg;
                        end
                
                        %save
                        baseline_subcond = allsubs_cond_rawBl{sub_i};
                        save(file_path,"baseline_subcond")
                    end
                end
                o.raw_bl.(cond) = allsubs_cond_rawBl;
            end
            cond_rawBl = o.raw_bl.(cond);
        end

        function cond_grandAvg = get_cond_grandAvg(o,cond)
            if ~isfield(o.grandAvg,cond)
                cfg = [];
                file_path = sprintf("%s//timelock_grandAvg_%s_cond-%s.mat",o.output_dir,o.choosenSuffix,cond);
                try
                    loaded = load(file_path);
                    cond_grandAvg = loaded.timelockGrandavg_cond;
                catch ME
                    timlocked = o.get_cond_timelocked(o,cond);
                    cond_grandAvg  = ft_timelockgrandaverage(cfg, timlocked{:});
        
                    %save
                    timelockGrandavg_cond = cond_grandAvg;
                    save(sprintf("%s/timelocked_cond-%s_sub-avg.mat",o.output_dir,cond),"timelockGrandavg_cond")
                end
            else
                cond_grandAvg = o.grandAvg.(cond);
            end
        end
   end
end