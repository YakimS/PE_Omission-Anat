classdef ft_importer
    methods(Static)
        function neighbours = get_neighbours()
            % get neighbours
            cfg = [];
            cfg.method = 'triangulation' ; 
            cfg.feedback    = 'no';
            elec       = ft_read_sens('GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'
            cfg.elec=elec;
            neighbours = ft_prepare_neighbours(cfg);
        end
        
        % get the sub struct arrays for each condition
        function allConds_rawft=get_rawFt_conds(dir,conds_string,choosenSuffix,subs)
            allConds_rawft = cell(1, size(conds_string,2));
            for cond_ind = 1:size(conds_string,2)
                subs_cond = cell(1, size(subs,2));
                for sub_i=1:size(subs,2)
                    if contains(choosenSuffix,'all') % import both wake night and morning
                        file_path_ngt = sprintf("%s\\%s\\s_%s_%s_%s.mat",dir,'wake_night_referenced',subs{sub_i},'wake_night_referenced',conds_string{cond_ind});
                        file_path_mng = sprintf("%s\\%s\\s_%s_%s_%s.mat",dir,'wake_morning_referenced',subs{sub_i},'wake_morning_referenced',conds_string{cond_ind});
                        try
                            sub_data_ngt = load(file_path_ngt);
                            sub_data_mng = load(file_path_mng);

                            cfg = [];
                            ft_data =  ft_appenddata(cfg, sub_data_ngt.ft_data, sub_data_mng.ft_data);
                            subs_cond{sub_i} = ft_data;
                        catch ME
                            sprintf('cant find: %s\n or: %s', file_path_ngt,file_path_mng)
                        end                            
                    else     % import only one cond 
                        file_path = sprintf("%s\\s_%s_%s_%s.mat",dir,subs{sub_i},choosenSuffix,conds_string{cond_ind});
                        try
                            sub_data = load(file_path);
                            subs_cond{sub_i} = sub_data.ft_data;
                        catch ME
                            sprintf('cant find: %s', file_path)
                        end
                    end
                end
                allConds_rawft{cond_ind} = subs_cond;
            end
        end
        
        function allConds_timlocked = get_allConds_timelocked(all_conds,dir,conds_string,subs)
            allConds_timlocked = cell(1, size(conds_string,2));
            for cond_ind = 1:size(conds_string,2)
                for sub_i=1:size(subs,2)
                    file_path = sprintf("%s/timelocked_cond-%s_sub-%s.mat",dir,conds_string{cond_ind},subs{sub_i});
                    try
                        loaded = load(file_path);
                        allConds_timlocked{cond_ind}{sub_i} = loaded.timelocked_subcond;
                    catch ME
                        cfg = [];
                        allConds_timlocked{cond_ind}{sub_i} = ft_timelockanalysis(cfg, all_conds{cond_ind}{sub_i});
        
                        %save
                        timelocked_subcond = allConds_timlocked{cond_ind}{sub_i};
                        save(file_path,"timelocked_subcond")
                    end
                end
            end
        end
        
        function allConds_timlocked_bl = get_allConds_timelocked_baseline(allConds_timlocked,dir,conds_string,subs,baseline_length)
            % create baseline-per-electrode structs
            allConds_timlocked = [allConds_timlocked];
            allConds_timlocked_bl = allConds_timlocked;
            for cond_ind = 1:size(conds_string,2)
                for sub_i=1:size(subs,2)
                    file_path = sprintf("%s/baseline%dms_cond-%s_sub-%s.mat",dir,baseline_length,conds_string{cond_ind},subs{sub_i});
                    try
                        loaded = load(file_path);
                        allConds_timlocked_bl{cond_ind}{sub_i} = loaded.baseline_subcond;
                    catch ME
                        curr_sub_cond_struct = allConds_timlocked{cond_ind}{sub_i};
                        time0_ind = find(curr_sub_cond_struct.time == 0, 1);
                        time_baseline_ind = find(curr_sub_cond_struct.time == -baseline_length*0.001, 1);
                
                        baseline = curr_sub_cond_struct.avg(:,time_baseline_ind:time0_ind);
                        baseline_mean = mean(baseline,2);
                        new_baseline_avg = ones(size(curr_sub_cond_struct.avg)) .* baseline_mean;
                        % TODO: REMOVE ALL OTHER FILEDS (variance etc.)
                        allConds_timlocked_bl{cond_ind}{sub_i}.avg = new_baseline_avg; 
                        
                        %save
                        baseline_subcond = allConds_timlocked_bl{cond_ind}{sub_i};
                        save(file_path,"baseline_subcond")
                    end
                end
            end
        end

        function allConds_grandAvg = get_allConds_grandAvg(allConds_timlocked,dir,conds_string)
            allConds_grandAvg = cell(1, size(conds_string,2));
            cfg = [];
            for cond_ind = 1:size(conds_string,2)
                file_path = sprintf("%s/timelock_grandAvg_cond-%s.mat",dir,conds_string{cond_ind});
                try
                    loaded = load(file_path);
                    allConds_grandAvg{cond_ind} = loaded.timelockGrandavg_cond;
                catch ME
                    allConds_grandAvg{cond_ind}  = ft_timelockgrandaverage(cfg, allConds_timlocked{cond_ind}{:});
        
                    %save
                    timelockGrandavg_cond = allConds_grandAvg{cond_ind};
                    save(sprintf("%s/timelocked_cond-%s_sub-avg.mat",dir,conds_string{cond_ind}),"timelockGrandavg_cond")
                end
            end
        end

   end
end