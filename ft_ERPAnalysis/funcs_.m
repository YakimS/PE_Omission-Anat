classdef funcs_
    properties (SetAccess = private)
        imp
        electrodes
        label
        time
    end
    methods(Static)
        % constructor
        function f = funcs_(imp, label,electrodes, time)
            f.imp = imp;
            f.electrodes = electrodes;
            f.label = label;
            f.time = time;
        end

        % get/set
        function s = get_imp(f)
            s = f.imp;
        end
        function s = get_electrodes(f)
            s = f.electrodes;
        end
        function s = get_label(f)
            s = f.label;
        end
        function s = get_time(f)
            s = f.time;
        end

        %%%%%%%%%%%%%%%%%%%% TFR: spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function run_STCP_TFR_dependent(f,output_dir, contrast_conds,contrast_sovs,timerange_test,freqrange_test,timerange_plot,is_bl_in_band, tfr_algo)
            cond1 = contrast_conds{1};
            cond2 = contrast_conds{2};
            sov_cond1 = contrast_sovs{1};
            sov_cond2 = contrast_sovs{2};

            curr_output_filename = sprintf("%s\\STCP-TFR_conds-%s+%s_condsSovs-%s+%s_freq-%.1f-%.1f_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s,freqrange_test(1),freqrange_test(2));
            if isfile(curr_output_filename) return; end

            if strcmp(tfr_algo,'multitaper')
                tfrFt_cond1 = f.imp.get_cond_TFR_mt(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_mt(f.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'multitaper_zscored')
                tfrFt_cond1 = f.imp.get_cond_TFR_mt_zscored(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_mt_zscored(f.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'hilbert')
                tfrFt_cond1 = f.imp.get_cond_TFR_hilbert(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_hilbert(f.imp,cond2,sov_cond2);
            else
                error('no such tfr algo implemented')
            end
            
            metadata = funcs_.STCP_TFR_dependentT(f,tfrFt_cond1, tfrFt_cond2,timerange_test,freqrange_test,timerange_plot,curr_output_filename,is_bl_in_band,true);
            if ~isempty(metadata)
                save(curr_output_filename, "metadata")
            end
        end

        function run_STCP_TFRMAP_dependent(f,output_dir, tfr_algo,contrast_conds,contrast_sovs,timerange_test,freqrange_test,clusts_struct,timerange_plot)
            cond1 = contrast_conds{1};
            cond2 = contrast_conds{2};
            sov_cond1 = contrast_sovs{1};
            sov_cond2 = contrast_sovs{2};
            metadata = {};
            
            if strcmp(tfr_algo,'multitaper')
                tfrFt_cond1 = f.imp.get_cond_TFR_mt(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_mt(f.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'multitaper_zscored')
                tfrFt_cond1 = f.imp.get_cond_TFR_mt_zscored(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_mt_zscored(f.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'hilbert')
                tfrFt_cond1 = f.imp.get_cond_TFR_hilbert(f.imp,cond1,sov_cond1);
                tfrFt_cond2 = f.imp.get_cond_TFR_hilbert(f.imp,cond2,sov_cond2);
            else
                error('no such tfr algo implemented')
            end
            
            % return if all exists
            clust_struct_fields = fieldnames(clusts_struct);
            for i = 1:numel(clust_struct_fields)
                if strcmp(clust_struct_fields{i},'elec_gen_info') continue; end
                clust_i = clusts_struct.(clust_struct_fields{i});
                curr_output_filename = sprintf("%s\\STCP-TFRMAP-%s-_conds-%s+%s_condsSovs-%s+%s_freq-%.1f-%.1f_clust-%s.mat", ...
                    output_dir,tfr_algo,cond1.short_s,cond2.short_s,sov_cond1.short_s, ...
                    sov_cond2.short_s,freqrange_test(1),freqrange_test(2), ...
                    clust_i.short_s);
                if isfile(curr_output_filename) continue; end
                fig_title = sprintf('conds: %s vs %s, sovs: ',cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
                metadata = funcs_.STCP_TFRMAP_dependentT(f,tfrFt_cond1, tfrFt_cond2,timerange_test,freqrange_test,clust_i,timerange_plot,curr_output_filename,fig_title);
            end

            if ~isempty(metadata)
                save(curr_output_filename, "metadata")
            end
        end

        

        %%%%%%%%%%%%%%%%%%%% ERP: spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function run_STCP_ERP_dependent(f,output_dir, contrast_conds,contrast_sovs,timerange_test,timerange_plot, is_plot_topoplot,is_plot_video)
            cond1 = contrast_conds{1};
            cond2 = contrast_conds{2};
            sov_cond1 = contrast_sovs{1};
            sov_cond2 = contrast_sovs{2};

            curr_output_filename = sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
            if isfile(curr_output_filename) return; end

            timelockft_cond1 = f.imp.get_cond_timelocked(f.imp,cond1,sov_cond1);
            timelockft_cond2 = f.imp.get_cond_timelocked(f.imp,cond2,sov_cond2);
            
            metadata = funcs_.STCP_ERP_dependentT(f,timelockft_cond1, timelockft_cond2,timerange_test,timerange_plot,curr_output_filename,is_plot_topoplot,is_plot_video);
            if ~isempty(metadata)
                save(curr_output_filename, "metadata")
            end
        end

        function plot_erp_per_contrast_and_sov(f,out_dir,conds,conds_sovs,elctrds_clusts,varargin)   
            p = inputParser;
            addRequired(p, 'f'); addRequired(p, 'out_dir'); addRequired(p, 'conds'); addRequired(p, 'conds_sovs'); 
            addRequired(p, 'elctrds_clusts');
            addOptional(p, 'plot_latency', {});
            addOptional(p, 'test_latency', {});
            addOptional(p, 'event_lines', {});
            addOptional(p, 'plot_bp_filter', 'no');
            addOptional(p, 'is_plot_subs', false);
            parse(p,f,out_dir,conds,conds_sovs,elctrds_clusts,varargin{:});
            r = p.Results;
                
            ylim_ = [-3 3];

            if isempty(r.plot_latency)      r.plot_latency = [f.time(1),f.time(end)];    end
            if isempty(r.test_latency)      r.test_latency = [f.time(1),f.time(end)];    end

            curr_colormap = funcs_.get_colormap_for_sovs(conds_sovs,conds);       
            subs = f.imp.get_subs(f.imp); 
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electd = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                if isfield(elctrds_clusts.(fields_elctrds_clusts{ctp_i}),'pval')
                    clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');
                else
                    clust_pval = NaN;
                end

                curr_output_filename = sprintf('%s\\ERP_conds-%s+%s_condsSov-%s+%s_clust-%s', ...
                out_dir,conds{1}.short_s,conds{2}.short_s,conds_sovs{1}.short_s,conds_sovs{2}.short_s, clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
                
                stat = funcs_.cluster_permu_erp(f,conds,conds_sovs,clust_electd,r.test_latency);
    
                % plot sig points
                if ~all(stat.mask ==0)
                    sig_timerange = stat.mask .*stat.time;
                else
                    sig_timerange = 0;
                end
                
                % get mean activity per sub and cond
                % allSubs_conds_AvgActivity average the activity over all electrods and time
                trials_stats_string = "";
                a_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{1},conds_sovs{1}); 
                length_plottime = numel( a_cond_timelock{1}.time(1): 0.004 :  a_cond_timelock{1}.time(end));
                allSubs_conds_AvgActivity = zeros(size(subs,2),length_plottime,size(conds,2)); 
                for cond_sov_j = 1:size(conds,2)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, conds{cond_sov_j}.short_s,conds_sovs{cond_sov_j}.short_s);
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_sov_j},conds_sovs{cond_sov_j}); 
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_sub_cond_struct.cfg.trials_timelocked_avg;
                        allSubs_conds_AvgActivity(sub_i,:,cond_sov_j) = mean(curr_sub_cond_struct.avg(clust_electd,:),1);
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end               
    
                title_ = sprintf('ERP, %s(%s) vs %s(%s), %d subjects', ...
                    conds{1}.short_s,conds_sovs{1}.short_s,conds{2}.short_s,conds_sovs{2}.short_s, size(subs,2));            
                subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);

                funcs_.plot_erps(f.time,conds,allSubs_conds_AvgActivity ...
                ,curr_output_filename, curr_colormap, ...
                'sig_timeranges',{sig_timerange},'sig_timeranges_colormap',{{curr_colormap(1,:),curr_colormap(end,:)}}, ...
                'title_',title_,'subtitle_',subtitle_,'bottom_string',trials_stats_string,'ylim_',ylim_ ...
                ,'clust_electd',{elctrds_clusts.('elec_gen_info'),clust_electd} ...
                , 'plot_latency', r.plot_latency, 'event_lines',r.event_lines, 'plot_bp_filter', r.plot_bp_filter)
            end
        end

        function plot_erp_per_condsSovPairs(f,out_dir,condSovPairs,elctrds_clusts,plot_name,varargin)   
            p = inputParser;
            addRequired(p, 'f'); addRequired(p, 'out_dir'); addRequired(p, 'condSovPairs'); 
            addRequired(p, 'plot_name');  addRequired(p, 'elctrds_clusts');
            addOptional(p, 'plot_latency', {});
            addOptional(p, 'test_latency', {});
            addOptional(p, 'plot_bp_filter', 'no');
            addOptional(p, 'event_lines', {});
            parse(p,f,out_dir,condSovPairs,elctrds_clusts,plot_name,varargin{:});
            r = p.Results;

            if isempty(r.plot_latency)
                r.plot_latency = [f.time(1),f.time(end)];
            end
            if isempty(r.test_latency)
                r.test_latency = [f.time(1),f.time(end)];
            end

            ylim_ = [-1.2 2];


            subs = f.imp.get_subs(f.imp);

            % get colormap
            conds = cell(1, numel(condSovPairs));
            conds_sovs = cell(1, numel(condSovPairs));
            for i = 1:numel(condSovPairs)
                conds{i} = condSovPairs{i}{1}; % Extract the cond struct
                conds_sovs{i} = condSovPairs{i}{2};  % Extract the sov struct
            end
            curr_colormap = funcs_.get_colormap_for_sovs(conds_sovs,conds); 
            
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electd = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');

                curr_output_filename = sprintf('%s\\ERP_name-%s_clust-%s',out_dir,plot_name,clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end

                % get avg data to plot
                trials_stats_string = "";
                allSubs_sovs_AvgActivity = zeros(size(subs,2),size(f.time,2),numel(condSovPairs)); 
                for uniq_i=1:numel(condSovPairs)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, condSovPairs{uniq_i}{1}.short_s,condSovPairs{uniq_i}{2}.short_s);
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,condSovPairs{uniq_i}{1},condSovPairs{uniq_i}{2}); 
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_sub_bl_struct =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_sub_bl_struct.cfg.trials_timelocked_avg;
                        allSubs_sovs_AvgActivity(sub_i,:,uniq_i) = mean(curr_sub_bl_struct.avg(clust_electd,:),1);
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end

                unique_pairs_combo = [];
                for i = 1:numel(condSovPairs)-1
                    for j = i+1:numel(condSovPairs)
                        unique_pairs_combo = [unique_pairs_combo; i j]; % Append the pair to the matrix
                    end
                end

                
                % get siglines data
                sig_timerange = {};
                sig_timerange_colormaps = {};
                for uniq_i=1:size(unique_pairs_combo,1)
                    curr_condsov1 = condSovPairs{unique_pairs_combo(uniq_i,1)};
                    curr_condsov2 = condSovPairs{unique_pairs_combo(uniq_i,2)};
                    stat = funcs_.cluster_permu_erp(f,{curr_condsov1{1},curr_condsov2{1}}, ...
                                                        {curr_condsov1{2},curr_condsov2{2}},clust_electd,r.test_latency);
                    % plot sig points
                    if ~all(stat.mask ==0)
                        sig_timerange{end + 1} = stat.mask .*stat.time;
                    else
                        sig_timerange{end + 1} = {};
                    end

                    curr_colormap_sov1 = curr_colormap(unique_pairs_combo(uniq_i,1),:);
                    curr_colormap_sov2 = curr_colormap(unique_pairs_combo(uniq_i,2),:);
                    sig_timerange_colormaps{end + 1} = {curr_colormap_sov1,curr_colormap_sov2};
                end
                
                title_ = sprintf('ERP, %s, %d subjects', plot_name,size(subs,2)); 
                subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);

                condSovPairsStrings = {};
                for pairs_i = 1:numel(condSovPairs)
                    condSovPairsStrings{end +1} = sprintf('%s',condSovPairs{pairs_i}{1}.long_s);
                end
                
                funcs_.plot_erps(f.time,condSovPairsStrings,allSubs_sovs_AvgActivity ...
                    ,curr_output_filename, curr_colormap, ...
                    'sig_timeranges',sig_timerange, 'sig_timeranges_colormap',sig_timerange_colormaps ...
                    ,'title_',title_,'subtitle_',subtitle_,'bottom_string',trials_stats_string,'ylim_',ylim_ ...
                    ,'clust_electd',{elctrds_clusts.('elec_gen_info'),clust_electd} ...
                    , 'plot_latency', r.plot_latency, 'event_lines',r.event_lines,"plot_bp_filter",r.plot_bp_filter)
            end
        end
       
        % is sovs number of elements is 1, it plots all the subjects line.
        % Else, it plots the standard error
        function plot_erp_per_cond_across_sovs(f,out_dir,cond,sovs,elctrds_clusts,varargin)
            p = inputParser;
            addRequired(p, 'f'); addRequired(p, 'out_dir'); addRequired(p, 'conds'); addRequired(p, 'conds_sovs'); 
            addRequired(p, 'elctrds_clusts');
            addOptional(p, 'plot_latency', [f.time(1),f.time(end)]);
            addOptional(p, 'test_latency', [f.time(1),f.time(end)]);
            addOptional(p, 'event_lines', {});   
            addOptional(p, 'betweenSov_cond_forSigLine', {});  
            addOptional(p, 'withinSov_contrast_forSigLine', {});
            addOptional(p, 'is_plot_subs', false);
            addOptional(p, 'plot_bp_filter', 'no');
            addOptional(p, 'is_plot_ste', true);
            parse(p,f,out_dir,cond,sovs,elctrds_clusts,varargin{:});
            r = p.Results;

            ylim_ = [-1.2 2];

            subs = f.imp.get_subs(f.imp);

            sovs_colormap = zeros([numel(sovs),3]);
            for sov_i=1:numel(sovs)
                cols = funcs_.get_colormap_from_dic(sovs{sov_i}.short_s,2);
                sovs_colormap(sov_i,:) = cols(2,:);
            end
            
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electd = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                if isfield(elctrds_clusts.(fields_elctrds_clusts{ctp_i}),'pval')
                    clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');
                else
                    clust_pval = NaN;
                end

                if numel(sovs)>1
                    sovs_string = "all";
                else
                    sovs_string = sovs{1}.short_s;
                end
                curr_output_filename = sprintf('%s\\ERP_sov-%s_cond-%s_clust-%s',out_dir,sovs_string,cond.short_s,clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
    
                % get avg data to plot
                allSubs_sovs_AvgActivity = zeros(size(subs,2),size(f.time,2),numel(sovs)); 
                
                trials_stats_string = "";
                for sov_i=1:numel(sovs)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, cond.short_s, sovs{sov_i}.short_s);
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,cond,sovs{sov_i});
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_sub_bl_struct =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_sub_bl_struct.cfg.trials_timelocked_avg;
                        allSubs_sovs_AvgActivity(sub_i,:,sov_i) = mean(curr_sub_bl_struct.avg(clust_electd,:),1);
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end
                
                
                % get siglines data
                sig_timerange = {};
                sig_timerange_colormaps = {};
                if ~isempty(r.withinSov_contrast_forSigLine)
                    for sov_i=1:numel(sovs)
                        stat = funcs_.cluster_permu_erp(f,r.withinSov_contrast_forSigLine,{sovs{sov_i},sovs{sov_i}},clust_electd,r.test_latency);
                        % plot sig points
                        if ~all(stat.mask ==0)
                            sig_timerange{end + 1} = stat.mask .*stat.time;
                        else
                            sig_timerange{end + 1} = {};
                        end
                        curr_colormap = funcs_.get_colormap_from_dic(sovs{sov_i}.short_s,2);
                        sig_timerange_colormaps{end + 1} = {curr_colormap(1,:),curr_colormap(end,:)};
                    end
                end
                if ~isempty(r.betweenSov_cond_forSigLine)
                    sovs_pairs = uniquePairs(sovs);
                    for sp_i=1:numel(sovs_pairs)
                        stat = funcs_.cluster_permu_erp(f,{r.betweenSov_cond_forSigLine,r.betweenSov_cond_forSigLine},sovs_pairs{sp_i},clust_electd,r.test_latency);
                        % plot sig points
                        if ~all(stat.mask ==0)
                            sig_timerange{end + 1} = stat.mask .*stat.time;
                        else
                            sig_timerange{end + 1} = {};
                        end
                        curr_colormap_sov1 = funcs_.get_colormap_from_dic(sovs_pairs{sp_i}{1}.short_s,2);
                        curr_colormap_sov2 = funcs_.get_colormap_from_dic(sovs_pairs{sp_i}{2}.short_s,2);
                        sig_timerange_colormaps{end + 1} = {curr_colormap_sov1(2,:),curr_colormap_sov2(2,:)};
                    end
                end
                
                title_ = sprintf('ERP, Condition-%s, %d subjects', cond.short_s,size(subs,2)); 
                subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);                    
                
                funcs_.plot_erps(f.time,sovs,allSubs_sovs_AvgActivity ...
                    ,curr_output_filename, sovs_colormap, ...
                    'sig_timeranges',sig_timerange, 'sig_timeranges_colormap',sig_timerange_colormaps ...
                    ,'title_',title_,'subtitle_',subtitle_,'bottom_string',trials_stats_string,'ylim_',ylim_ ...
                    ,'clust_electd',{elctrds_clusts.('elec_gen_info'),clust_electd} ...
                    , 'plot_latency', r.plot_latency, 'event_lines',r.event_lines, ...
                    'is_plot_subs',r.is_plot_subs,'is_plot_ste',r.is_plot_ste,'plot_bp_filter', r.plot_bp_filter)
            end
        end


        % unionWithinFrontBack_intersectBetweenSovs: 
        % In this function I assume that the positive and negative cluster
        % in REM are oposite in thire location in other sovs
        % conds is a contrast. E.g. {intblkMid, Omi}
        % sovs are not of a contrast. The contrasnt is always within the same sov, but then there is an intersection between the clusters in each sov
        function electd_clusts=get_electdClust(f,type,clust_dir,conds,sovs,maxPval)
            electd_clusts = struct();
            if strcmp(type,'simple_contrast')
                try
                    clusters_res = load(sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg", ...
                        clust_dir,conds{1}.short_s,conds{2}.short_s,sovs{1}.short_s,sovs{2}.short_s));
                catch ME
                    if isequal(ME.identifier,"MATLAB:load:couldNotReadFile")
                        fprintf("%s\n",ME.message);
                        return
                    else
                        throw(ME)
                    end
                end

                clusters_res = clusters_res.metadata.stat;
                for pos_neg_ind=1:2
                    if pos_neg_ind ==1
                        clusters_posneg = {clusters_res.posclusters.prob};
                        clust_mask = clusters_res.posclusterslabelmat;
                        curr_posneg_string = 'pos';
                    else
                        clusters_posneg = {clusters_res.negclusters.prob};
                        clust_mask = clusters_res.negclusterslabelmat;
                        curr_posneg_string= 'neg';
                    end
    
                    % get pos or neg clusters
                    curr_posneg_clusts_toplot = {}; 
                    for clust_ind=1:size(clusters_posneg,2)
                        if clusters_posneg{clust_ind} > maxPval continue;  end
                        % get time-electrode mask for current cluster
                        curr_clust_mask = clust_mask;
                        curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                        curr_clust_mask(curr_clust_mask ~= 0) = 1;
                        temp = mean(curr_clust_mask,2);
                        clust_electd = find(temp>0);
                        
                        if ~isempty(clust_electd)
                            clust = struct();
                            clust.('short_s') =  sprintf("%s+%s-%s+%s-%s-%d",conds{1}.short_s,conds{2}.short_s,sovs{1}.short_s,sovs{2}.short_s,curr_posneg_string,clust_ind);
                            clust.('long_s') =  sprintf("%s+%s-%s+%s-%s-%d",conds{1}.long_s,conds{2}.long_s,sovs{1}.long_s,sovs{2}.long_s,curr_posneg_string,clust_ind);
                            clust.('elect') = clust_electd;
                            clust.('elect_label')  = clusters_res.elec.label(clust_electd);
                            clust.('pval') = clusters_posneg{clust_ind};
                            electd_clusts.(sprintf('%s_%d',curr_posneg_string,clust_ind)) = clust;
                            
                        end
                    end
                    electd_clusts.('elec_gen_info') = clusters_res.elec;
                end                
            elseif strcmp(type,'unionWithinFrontBack_intersectBetweenSovs')
                electd_clusts = struct();
                pos_elct_clust = struct();
                neg_elct_clust = struct();

                % get neg and pos union electrodes clusters
                for sov_i=1:numel(sovs)
                    curr_sov_electd_clusts=f.get_electdClust(f,'simple_contrast',clust_dir,conds,{sovs{sov_i},sovs{sov_i}});

                    union_pos = [];
                    union_neg = [];
                    fields = fieldnames(curr_sov_electd_clusts);
                    for i = 1:length(fields)
                        if contains(fields{i}, 'pos')
                            union_pos = union(union_pos, curr_sov_electd_clusts.(fields{i}).('elect'));
                        elseif contains(fields{i}, 'neg')
                            union_neg = union(union_neg, curr_sov_electd_clusts.(fields{i}).('elect'));
                        end
                    end

                    pos_elct_clust.(sovs{sov_i}.short_s) = union_pos;
                    neg_elct_clust.(sovs{sov_i}.short_s) = union_neg;
                    electd_clusts.('elec_gen_info') = curr_sov_electd_clusts.('elec_gen_info');
                end
                
                % get back cluster electrodes
                back_elct_clust = [];
                front_elct_clust = [];
                fields = fieldnames(neg_elct_clust);
                for i = 1:length(fields)
                    if contains(fields{i}, 'REM') continue;  end
                    if isempty(neg_elct_clust.(fields{i})) continue; end
                    if isempty(back_elct_clust)
                        back_elct_clust = neg_elct_clust.(fields{i});
                    else
                        back_elct_clust = intersect(back_elct_clust, neg_elct_clust.(fields{i}));
                    end
                end
                if isfield(pos_elct_clust,'REM') && ~isempty(pos_elct_clust.('REM'))
                    if isempty(back_elct_clust)
                        back_elct_clust = pos_elct_clust.('REM');
                    else
                        back_elct_clust = intersect(back_elct_clust, pos_elct_clust.('REM'));
                    end
                end

                % get front cluster electrodes
                fields = fieldnames(pos_elct_clust);
                for i = 1:length(fields)
                    if contains(fields{i}, 'REM') continue;  end
                    if isempty(pos_elct_clust.(fields{i})) continue; end
                    if isempty(front_elct_clust)
                        front_elct_clust = pos_elct_clust.(fields{i});
                    else
                        front_elct_clust = intersect(front_elct_clust, pos_elct_clust.(fields{i}));
                    end
                end
                if isfield(neg_elct_clust,'REM') && ~isempty(neg_elct_clust.('REM'))
                    if isempty(front_elct_clust)
                        front_elct_clust = neg_elct_clust.('REM');
                    else
                        front_elct_clust = intersect(front_elct_clust, neg_elct_clust.('REM'));
                    end
                end

                % get sovs_string
                sovs_string = "";
                for s_i=1:numel(sovs)
                    if strcmp(sovs_string,"")
                        sovs_string =sovs{s_i}.short_s;
                    else
                        sovs_string = sprintf("%s+%s",sovs_string,sovs{s_i}.short_s);
                    end
                end

                if ~isempty(back_elct_clust)
                    clust = struct();
                    clust.('short_s') =  sprintf("%s+%s-%s-back",conds{1}.short_s,conds{2}.short_s,sovs_string);
                    clust.('long_s') =  sprintf("%s+%s-%s-back",conds{1}.long_s,conds{2}.long_s,sovs_string);
                    clust.('elect') = back_elct_clust;
                    electd_clusts.('back') = clust;
                end
                if ~isempty(front_elct_clust)
                    clust = struct();
                    clust.('short_s') =  sprintf("%s+%s-%s-front",conds{1}.short_s,conds{2}.short_s,sovs_string);
                    clust.('long_s') =  sprintf("%s+%s-%s-front",conds{1}.long_s,conds{2}.long_s,sovs_string);
                    clust.('elect') = front_elct_clust;
                    electd_clusts.('front') = clust;
                end
            end
        end
    end
    

    methods(Access=private, Static)
        % Electrods Cluster between conditions. per timepoint for one subject
        function metadata = clusterd_independetT(f,cond1_struct, cond2_struct,latency,stat_file_string,is_plot_topoplot)
            neighbours = f.imp.get_neighbours(f.imp);

            metadata = {};
            timelockFC  = cond1_struct;
            timelockFIC = cond2_struct;
            
            % ft_timelockstatistics
            cfg                  = [];
            cfg.method           = 'montecarlo';
            cfg.alpha       = 0.05;
            cfg.tail        = 0; % two-sided test
            cfg.correcttail = 'prob';  % cfg.correcttail = correct p-values or alpha-values when doing a two-sided test, 'alpha','prob' or 'no' (default = 'no')
            cfg.statistic        = 'indepsamplesT';
            cfg.correctm         = 'cluster';
            
            cfg.clusteralpha     = 0.05;  
            cfg.clusterstatistic = 'maxsum';   
            cfg.minnbchan        = 1;          
            cfg.clustertail      = 0;
            cfg.numrandomization = 10000;
            cfg.neighbours    = neighbours; 
            cfg.latency     = latency;
            n_fc  = size(timelockFC.trial, 2);
            n_fic = size(timelockFIC.trial, 2);
            cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
            cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)
            [stat] = ft_timelockstatistics(cfg, timelockFIC, timelockFC);
            save(sprintf("%s",stat_file_string), '-struct', 'stat');
            metadata.ft_timelockstatistics =  stat.cfg;
        
            %plot
            % cfg.toi makes sure to plot also the baseline timeperiod
            timediff = cond1_struct.time{1}(2) - cond1_struct.time{1}(1);
            toi = latency(1): timediff :latency(2);
            if is_plot_topoplot
                cfg = [];
                cfg.toi = toi;
                cfg.parameter = 'stat';
                cfg.saveaspng = erase(stat_file_string,".mat");
                cfg = funcs_.cluster_plot(stat,cfg);
                metadata.cfg_ft_clusterplot =  cfg;
            end
        end
        
        % Electrods Cluster between conditions. per timepoint all subjects
        function metadata = STCP_ERP_dependentT(f,cond1_struct, cond2_struct,test_latency,plot_timerange, mat_filename,is_plot_topoplot,is_plot_video)
            subs = f.imp.get_subs(f.imp);
            neighbours = f.imp.get_neighbours(f.imp);

            metadata = {};
            cfg = [];
            cfg.latency     = test_latency;
            Nsub = size(subs,2);
            cfg.numrandomization = 5000;
            
            cfg.neighbours  = neighbours; % defined as above
            cfg.avgovertime = 'no';
            cfg.parameter   = 'avg';
            cfg.method      = 'montecarlo'; 
            cfg.alpha       = 0.05;
            cfg.tail        = 0; % two-sided test
            cfg.correcttail = 'prob'; % cfg.correcttail = correct p-values or alpha-values when doing a two-sided test, 'alpha','prob' or 'no' (default = 'no')
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.correctm    = 'cluster';
            cfg.minnbchan        = 1;      % minimal number of neighbouring channels
            
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            
            stat = ft_timelockstatistics(cfg,cond1_struct{:}, cond2_struct{:});

            cfg = [];
            cfg.channel   = 'all';
            cfg.latency   = test_latency;
            cfg.parameter = 'avg';
            gradavg_cond1        = ft_timelockgrandaverage(cfg, cond1_struct{:});
            gradavg_cond2         = ft_timelockgrandaverage(cfg, cond2_struct{:});
            cfg = [];
            cfg.operation = 'subtract';
            cfg.parameter = 'avg';
            subt_conds12    = ft_math(cfg, gradavg_cond1, gradavg_cond2);
            stat.subt_conds12 = subt_conds12.avg;

%             cfg = [];
%             cfg.xlim = toi;
%             cfg.zlim = [-1 1];
%             cfg.comment  ='xlim';
%             cfg.commentpos = 'middletop';
%             cfg.colormap = 'parula';
%             cfg.style              = 'straight';      %     colormap only. Defualt - colormap and conture lines
%             cfg.marker             = 'off';
%             cfg.layout = ft_read_sens('GSN-HydroCel-129.sfp');
%             cfg  = ft_topoplotER(cfg,"hi",GA_FICvsFC);
%             
            %save(sprintf("%s",mat_filename), '-struct', 'stat');
            metadata.stat =  stat;

            is_cluster_exists = false;
            if isfield(stat, "posclusters")
                pos_prob = [stat.posclusters.('prob')];
                if  ~isempty(pos_prob) && pos_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end
            if isfield(stat, "negclusters")
                neg_prob = [stat.negclusters.('prob')];
                if  ~isempty(neg_prob) && neg_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end
            
            % plot        
            if is_plot_topoplot
                filename = erase(mat_filename,".mat");
                summary_filename = sprintf("%s_summary",filename);
                sample_rate = 250;
                rec_fps = 1/sample_rate;
                if is_cluster_exists
                    if is_plot_video
                        vid_maximum_fps = 1/60;
                        timediff = floor(vid_maximum_fps/rec_fps) *rec_fps;
                        toi = plot_timerange(1): timediff :plot_timerange(end);
                        funcs_.cluster_plot_video(stat,toi,filename);
                    end
    
                    timediff = ceil(((plot_timerange(end) - plot_timerange(1))/16) / rec_fps) * rec_fps;
                    toi = plot_timerange(1): timediff :plot_timerange(end);
                    cfg = [];
                    cfg.toi = toi;
                    cfg.parameter = 'subt_conds12';
                    cfg.saveaspng = summary_filename;
                    funcs_.cluster_plot(stat,cfg);
                else
                    timediff = ((plot_timerange(end) - plot_timerange(1))/16);
                    toi = plot_timerange(1): timediff :plot_timerange(end);

                    cfg = [];
                    cfg.xlim = toi;
                    cfg.parameter = 'subt_conds12';
                    cfg.saveaspng = summary_filename;
                    funcs_.topo_plot(cfg,stat);
                end
            end
        end
        
        function metadata = STCP_TFRMAP_dependentT(f,cond1_struct, cond2_struct,test_latency,freqrange_test,clust_struct,plot_timerange, mat_filename,fig_title)
            subs = f.imp.get_subs(f.imp);
            metadata = {};

            [~, elec_ind] = ismember(clust_struct.('elect_label'), cond1_struct{1}.('label'));
            powspctrm_diff_avg = zeros([numel(elec_ind), size(cond1_struct{1}.powspctrm,[2,3])]);
            powspctrm_cond1_avg = zeros([numel(elec_ind), size(cond1_struct{1}.powspctrm,[2,3])]);
            powspctrm_cond2_avg = zeros([numel(elec_ind), size(cond1_struct{1}.powspctrm,[2,3])]);
            for i=1:numel(cond1_struct)
                powspctrm_cond1_avg = powspctrm_cond1_avg + cond1_struct{i}.powspctrm(elec_ind,:,:);
                powspctrm_cond2_avg = powspctrm_cond2_avg + cond2_struct{i}.powspctrm(elec_ind,:,:);
                curr_diff = cond1_struct{i}.powspctrm(elec_ind,:,:) - cond2_struct{i}.powspctrm(elec_ind,:,:);
                powspctrm_diff_avg= powspctrm_diff_avg + (curr_diff);
            end
            powspctrm_diff_avg = powspctrm_diff_avg/ numel(cond1_struct);
            powspctrm_cond1_avg = powspctrm_cond1_avg/ numel(cond1_struct);
            powspctrm_cond2_avg = powspctrm_cond2_avg/ numel(cond1_struct);

            cfg = [];
            cfg.channel          = clust_struct.('elect_label');
            cfg.latency          = test_latency;
            cfg.frequency        = freqrange_test;
            cfg.method           = 'montecarlo';
            cfg.statistic        = 'depsamplesT';
            cfg.clusteralpha     = 0.05;
            cfg.clusterstatistic = 'maxsum';
            cfg.tail             = 0;
            cfg.clustertail      = 0;
            cfg.alpha            = 0.025;
            cfg.neighbours       = f.imp.get_neighbours(f.imp);
            cfg.correctm = 'cluster';
            cfg.numrandomization = 1000;
            subj_num = numel(subs);
            design = zeros(2,2*subj_num);
            for i = 1:subj_num
              design(1,i) = i;
            end
            for i = 1:subj_num
              design(1,subj_num+i) = i;
            end
            design(2,1:subj_num)        = 1;
            design(2,subj_num+1:2*subj_num) = 2;
            cfg.design   = design;
            cfg.uvar     = 1;
            cfg.ivar     = 2;
            
            [stat] = ft_freqstatistics(cfg, cond1_struct{:}, cond2_struct{:});
            metadata.stat = stat;

            plot_struct = rmfield(cond1_struct{1}, {'powspctrm','cfg'});
            plot_struct.('data_contrast') = powspctrm_diff_avg;
            plot_struct.('label') = stat.label;
            plot_struct.('stat') = stat.stat;
            mask = zeros(size(powspctrm_diff_avg));
            tolerance = 1e-10;
            test_latency_index_1 = find(abs(plot_struct.time -  test_latency(1)) < tolerance);
            test_latency_index_2 = find(abs(plot_struct.time -  test_latency(2)) < tolerance);
            mask(:,:,test_latency_index_1:test_latency_index_2) = stat.mask;
            plot_struct.('mask') = logical(mask);

            metadata.plot_struct = plot_struct;
            fig = figure('Position', [100, 100, 1000, 650]);

%             plot_struct_cond1 = plot_struct;
%             plot_struct_cond1.('data_contrast') = powspctrm_cond1_avg;
%             plot_struct_cond2 = plot_struct;
%             plot_struct_cond2.('data_contrast') = powspctrm_cond2_avg;
%             cfg = [];
%             cfg.parameter    = 'data_contrast';
%             cfg.operation    = '(x1-x2)/(x1+x2)';
%             plot_struct_diff = ft_math(cfg, plot_struct_cond1, plot_struct_cond2);
%             plot_struct_diff.('mask') = logical(mask);


            %%% cfg data - diff, cond1, cond2
            cfg              = [];
            cfg.baseline     = [-0.2,-0.1];
            cfg.xlim         = plot_timerange;
            cfg.zlim         = [-.1 .1];
            cfg.baselinetype = 'relchange';
            cfg.parameter = 'data_contrast';
            cfg.maskparameter = 'mask'; 
            cfg.maskstyle    = 'outline'; %'opacity', 'saturation', or 'outline'
            cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
            cfg.title = sprintf('Conds diff, %s, bl:[%.f2, %.f2]',cfg.baselinetype,cfg.baseline(1),cfg.baseline(2));
            cfg.figure         = fig;
            subplot(2, 2, 2);
            ft_singleplotTFR(cfg, plot_struct);

            % % cond1
            plot_struct.('data_contrast') = powspctrm_cond1_avg;
            cfg.title = sprintf('Cond 1, %s, bl:[%.f2, %.f2]',cfg.baselinetype,cfg.baseline(1),cfg.baseline(2));
            cfg.xlim         = plot_timerange;
            subplot(2, 2, 1);
            ft_singleplotTFR(cfg, plot_struct);

            % % cond2
            plot_struct.('data_contrast') = powspctrm_cond2_avg;
            cfg.title = sprintf('Cond 2, %s, bl:[%.f2, %.f2]',cfg.baselinetype,cfg.baseline(1),cfg.baseline(2));
            cfg.xlim         = plot_timerange;
            subplot(2, 2, 3);
            ft_singleplotTFR(cfg, plot_struct);

            % 
            % %%% cfg stat
            cfg              = [];
            cfg.baseline     = 'no';
            cfg.parameter = 'stat';
            cfg.maskparameter = 'mask'; 
            cfg.maskstyle    = 'outline';%'opacity', 'saturation', or 'outline'
            cfg.zlim         = [-3. 3];
            cfg.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
            cfg.title = sprintf('Statistic T');
            cfg.figure         = fig;
            subplot(2, 2, 4);
            ft_singleplotTFR(cfg, stat);

            sgtitle(sprintf('%s \n Electodes: %s',fig_title,clust_struct.long_s));

            filename = erase(mat_filename,".mat");
            saveas(gcf,sprintf("%s.png",filename));
            saveas(gcf,sprintf("%s.fig",filename));
            close;
        end

        function metadata = STCP_TFR_dependentT(f,cond1_struct_orig, cond2_struct_orig,test_latency,freqrange_test,plot_timerange, mat_filename,is_bl_in_band,is_plot_topoplot)
            subs = f.imp.get_subs(f.imp);
            neighbours = f.imp.get_neighbours(f.imp);
            metadata = {};

            if is_bl_in_band
                cond1_struct_baselined = {};
                cond2_struct_baselined = {};
                for i=1:numel(cond1_struct_orig)
                    cfg = [];
                    cfg.frequency = freqrange_test;
                    cond1_curr = ft_freqdescriptives(cfg, cond1_struct_orig{i});
                    cond2_curr = ft_freqdescriptives(cfg, cond2_struct_orig{i});
                    cfg = [];
                    cfg.baseline     = [plot_timerange(1),0];
                    cond1_curr = ft_freqbaseline(cfg, cond1_curr);
                    cond2_curr = ft_freqbaseline(cfg, cond2_curr);
    
                    cond1_struct_baselined{end+1} = cond1_curr;
                    cond2_struct_baselined{end+1} = cond2_curr;
                end
                cond1_struct = cond1_struct_baselined;
                cond2_struct = cond2_struct_baselined;
            else
                cond1_struct = cond1_struct_orig;
                cond2_struct = cond2_struct_orig;
            end

            cfg = [];
            cfg.latency          =test_latency;
            cfg.frequency        = freqrange_test;
            cfg.avgoverfreq = 'yes' ;
            cfg.method      = 'montecarlo';
            cfg.alpha       = 0.05;
            cfg.tail        = 0; % two-sided test
            cfg.correcttail = 'prob'; % cfg.correcttail = correct p-values or alpha-values when doing a two-sided test, 'alpha','prob' or 'no' (default = 'no')
            cfg.statistic        = 'ft_statfun_depsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusteralpha     = 0.05;
            cfg.clusterstatistic = 'maxsum';
            cfg.minnbchan        = 2;
            cfg.clustertail      = 0;
            cfg.numrandomization = 1000;
            cfg.neighbours  = neighbours;
            
            subj_num = numel(subs);
            design = zeros(2,2*subj_num);
            for i = 1:subj_num
              design(1,i) = i;
            end
            for i = 1:subj_num
              design(1,subj_num+i) = i;
            end
            design(2,1:subj_num)        = 1;
            design(2,subj_num+1:2*subj_num) = 2;
            
            cfg.design   = design;
            cfg.uvar     = 1;
            cfg.ivar     = 2;

            stat = ft_freqstatistics(cfg,cond1_struct{:}, cond2_struct{:});
            %save(sprintf("%s",mat_filename), '-struct', 'stat');
            metadata.stat =  stat;

            is_cluster_exists = false;
            if isfield(stat, "posclusters")
                pos_prob = [stat.posclusters.('prob')];
                if  ~isempty(pos_prob) && pos_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end
            if isfield(stat, "negclusters")
                neg_prob = [stat.negclusters.('prob')];
                if  ~isempty(neg_prob) && neg_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end

            
            cfg = [];
            cfg.channel   = 'all';
            cfg.parameter = 'powspctrm';
            gradavg_cond1        = ft_freqgrandaverage(cfg, cond1_struct{:});
            gradavg_cond2         = ft_freqgrandaverage(cfg, cond2_struct{:});
            cfg = [];
            cfg.operation = 'subtract';
            cfg.parameter = 'powspctrm';
            subt_conds12    = ft_math(cfg, gradavg_cond1, gradavg_cond2);
            cfg = [];
            cfg.frequency = freqrange_test ;
            subt_conds12 = ft_freqdescriptives(cfg, subt_conds12);
            cfg = [];
            cfg.baseline     = [plot_timerange(1),0];
            subt_conds12 = ft_freqbaseline(cfg, subt_conds12);
            
            % for stat plot
            stat.powspctrm = mean(subt_conds12.powspctrm,2);
            timeind = find(subt_conds12.time>= test_latency(1) & subt_conds12.time<=test_latency(end)+1e-4);
            stat.powspctrm = stat.powspctrm(:,:,timeind(1):timeind(end));

            % plot          
            if is_plot_topoplot
                filename = erase(mat_filename,".mat");
                summary_filename = sprintf("%s_summary",filename);
                sample_rate = 250;
                rec_fps = 1/sample_rate;
                subt_conds12.elec = f.get_electrodes(f);
                
                timediff = ((plot_timerange(end) - plot_timerange(1))/16);
                toi = plot_timerange(1): timediff :plot_timerange(end);
                cfg = [];
                cfg.parameter = 'powspctrm';
                cfg.zlim = [-1 1];
                cfg.saveaspng = summary_filename;
                cfg.baseline = [plot_timerange(1),0];
                cfg.xlim = toi;
                funcs_.topo_plot(cfg,subt_conds12);

                if is_cluster_exists
                    timediff = ceil(((test_latency(end) - test_latency(1))/16) / rec_fps) * rec_fps;
                    toi = test_latency(1): timediff :test_latency(end);
                    cfg.toi = toi;
                    stat.elec = cond1_struct_orig{i}.elec;
                    cfg = rmfield(cfg, 'xlim');
                    funcs_.cluster_plot(stat,cfg); 

                    cfg.parameter = 'stat';
                    cfg.highlightcolorpos =[0.5 0.5 0.5]; 
                    cfg.highlightcolorneg = [0.5 0.5 0.5]; 
                    cfg.zlim  = [-5,5];
                    funcs_.cluster_plot(stat,cfg); 

                    figures = findall(0, 'Type', 'figure');
                    set(figures(1), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 700], 'PaperPositionMode', 'auto');
                    set(figures(2), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 700], 'PaperPositionMode', 'auto');
                    set(figures(3), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 700], 'PaperPositionMode', 'auto');
                    
                    frame1 = getframe(figures(1)); img1 = frame1.cdata;
                    frame2 = getframe(figures(2)); img2 = frame2.cdata;
                    frame3 = getframe(figures(3)); img3 = frame3.cdata;
                    
                    % Ensure all images have the same height by padding the smaller ones
                    [height1, ~, ~] = size(img1);
                    [height2, ~, ~] = size(img2);
                    [height3, ~, ~] = size(img3);
                    
                    max_height = max([height1, height2, height3]);
                    
                    if height1 < max_height
                        img1 = padarray(img1, [max_height-height1, 0, 0], 255, 'post');
                    end
                    if height2 < max_height
                        img2 = padarray(img2, [max_height-height2, 0, 0], 255, 'post');
                    end
                    if height3 < max_height
                        img3 = padarray(img3, [max_height-height3, 0, 0], 255, 'post');
                    end
                    
                    combined_img = [img1, img2, img3];
                    combined_figure = figure;
                    imshow(combined_img);
                    
                    imwrite(combined_img, sprintf("%s.png", filename));
                    saveas(figures(1), sprintf("%s_clust.fig", filename));
                    saveas(figures(2), sprintf("%s_topo.fig", filename));
                    saveas(figures(3), sprintf("%s_stat.fig", filename));
                else
                    saveas(gcf,sprintf("%s.png",filename));
                    saveas(gcf,sprintf("%s.fig",filename));
                end

                close 'all';
            end
        end

        function stat = cluster_permu_erp(f,conds,sovs,clust_mask,latency)
            subs = f.imp.get_subs(f.imp);
            
            all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
            for cond_sov_j = 1:size(conds,2)
                curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_sov_j},sovs{cond_sov_j}); 
                for sub_i = 1:size(subs,2)
                    curr_subcond = curr_cond_timelock{sub_i};
                    curr_subcond = rmfield(curr_subcond,'dof');
                    curr_subcond = rmfield(curr_subcond,'var');
                    curr_subcond.label = {'eletd_avg'};
                    %curr_subcond.var = std(curr_subcond.avg(clust_mask,:),1,1);
                    curr_subcond.avg = mean(curr_subcond.avg(clust_mask,:),1);
                    all_conds_timelocked_currClustElecd{cond_sov_j}{sub_i} = curr_subcond;
                end
            end
        
            % cluster permutation anaslysis 
            % define the parameters for the statistical comparison
            cfg = [];
            cfg.channel     = {'eletd_avg'};
            cfg.latency     = latency;
            cfg.avgovertime = 'no';
            cfg.parameter   = 'avg';
            cfg.method      = 'montecarlo';
            cfg.alpha       = 0.05;
            cfg.tail        = 0; % two-sided test
            cfg.correcttail = 'prob'; % cfg.correcttail = correct p-values or alpha-values when doing a two-sided test, 'alpha','prob' or 'no' (default = 'no')
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.numrandomization = 10000;
            cfg.correctm = 'cluster'; %'no';            
            Nsub = size(subs,2);
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{1}{:}, all_conds_timelocked_currClustElecd{2}{:});   % don't forget the {:}!
        end

        % plotting
        
        function cfg = cluster_plot(stat,cfg)
            if ~isfield(cfg, 'saveaspng')           error('cfg must include saveaspng field with filename'); end
            if ~isfield(cfg, 'parameter')           error('cfg must include parameter field with parameter'); end 
            if ~isfield(cfg, 'toi')                 error('cfg must include parameter toi with time range of intrest'); end 
            if ~isfield(cfg, 'alpha')                       cfg.alpha = 0.05; end                               % This is the max alpha to be plotted. (0.3 is the highst value possible)
            if ~isfield(cfg, 'zlim')                        cfg.zlim = [-1,1]; end
            if ~isfield(cfg, 'subplotsize')                 cfg.subplotsize =[4,4]; end             % better keep it that way, becuase this is the default grid of ft_topoplot
            if ~isfield(cfg, 'visible')                     cfg.visible = 'on'; end
            if ~isfield(cfg, 'highlightsymbolseries')       cfg.highlightsymbolseries = ['.', '.', '.', '.', '.']; end
            if ~isfield(cfg, 'highlightsizeseries')         cfg.highlightsizeseries = [4 4 4 4 4]; end
            if ~isfield(cfg, 'highlightcolorpos')           cfg.highlightcolorpos =[0.5 0 0]; end
            if ~isfield(cfg, 'highlightcolorneg')           cfg.highlightcolorneg = [0 0 0.5]; end
            if ~isfield(cfg, 'style')                       cfg.style = 'straight'; end             %     colormap only. Defualt - colormap and conture lines

            cfg = ft_clusterplot(cfg, stat); 
        end

        % 60 fps is a common maximum of the function so adjust toi
        % accordingly
        function cfg = cluster_plot_video(stat,toi,filepath)
            [parentDir, filename, ~] = fileparts(filepath);
            tempImagesFolder = fullfile(parentDir, filename); %create temp dir
            mkdir(tempImagesFolder);

            tempImagesName = sprintf("%s\\%s",tempImagesFolder,filename);
            cfg = [];
            cfg.zlim = [-5 5];
            cfg.alpha = 0.1; % This is the max alpha to be plotted. (0.3 is the hights value possible)
            cfg.saveaspng = tempImagesName;
            cfg.visible = 'no';
            cfg.toi =toi;
            %cfg.highlightsymbolseries   =[0.01 0.05 0.1 0.2 0.3]; %1x5 vector, highlight marker symbol series (default ['*', 'x', '+', 'o', '.'] for p < [0.01 0.05 0.1 0.2 0.3]
            cfg.highlightsizeseries     = [10 10 10 10 10];
            cfg.subplotsize = [1,1];
            cfg.highlightcolorpos       = [0.3 0 0];
            cfg.highlightcolorneg       = [0 0 0.3];
            cfg.style              = 'straight';      %     colormap only. Defualt - colormap and conture lines
            cfg = ft_clusterplot(cfg, stat); % i added saveas(gcf,sprintf("%s.png",filename)); etc to the function's code.
            %TODO, save all cfg?

            outputVideoFile = sprintf('%s.mp4',filepath);
            v = VideoWriter(outputVideoFile, 'MPEG-4');
            frameRate = min(numel(toi) / (toi(end) - toi(1)), 60);  % 60 fps is a common maximum of the function
            v.FrameRate = frameRate;% 5 frames per second (1 frame every 0.2 seconds)
            
            open(v);
            imageFiles = dir(fullfile(tempImagesFolder, '*.png'));
            for i = 1:length(imageFiles)
                curr_img_fullpath = fullfile(tempImagesFolder, imageFiles(i).name); % Full file name
                curr_img = imread(curr_img_fullpath); % Read image
                writeVideo(v, curr_img); % Write frame to video
            end
            close(v);
            rmdir(tempImagesFolder, 's');
        end

        function cfg = topo_plot(cfg,preVsPoststim_res)
            if ~isfield(cfg, 'saveaspng')           error('cfg must include saveaspng field with filename'); end
            if ~isfield(cfg, 'parameter')           error('cfg must include parameter field with parameter'); end 
            if ~isfield(cfg, 'xlim')                 error('cfg must include parameter toi with time range of intrest'); end 
            if ~isfield(cfg, 'zlim')                cfg.zlim = [-1,1]; end
            if ~isfield(cfg, 'subplotsize')         cfg.subplotsize =[4,4]; end             % better keep it that way, becuase this is the default grid of ft_topoplot
            if ~isfield(cfg, 'style')               cfg.style = 'straight'; end             %     colormap only. Defualt - colormap and conture lines
            if ~isfield(cfg, 'comment')             cfg.comment = 'xlim'; end
            if ~isfield(cfg, 'marker')              cfg.marker = 'off'; end
            if ~isfield(cfg, 'colormap')            cfg.colormap = 'parula'; end
            if ~isfield(cfg, 'commentpos')          cfg.commentpos = 'middletop'; end

            cfg  = ft_topoplotER(cfg,preVsPoststim_res);
        end
    
%         function custom_colormap = get_colormap_for_sovs(sovs, conds)
%             custom_colormap = zeros(numel(sovs),3);
% 
%             for i = 1:numel(sovs)
%                 if conds{i}.isBaseline
%                     custom_colormap(i,:) = funcs_.get_colormap_from_dic('baseline', 1);
%                 else
%                     custom_colormap(i,:) = funcs_.get_colormap_from_dic(sovs{i}.short_s, 1);
%                 end
%             end
%         end

        function custom_colormap = get_colormap_for_sovs(sovs, conds)
            filtered_sovs = sovs(cellfun(@(x) x.isBaseline == 0, conds)); % Filter sovs where isBaseline is equal to 0
            long_s_values = cellfun(@(x) x.long_s, filtered_sovs, 'UniformOutput', false); % Extract long_s values from the filtered list
            long_s_values_flat = cellfun(@(x) x{1}, long_s_values, 'UniformOutput', false);
            [unique_long_s, ~, idx] = unique(long_s_values_flat);
            counts = accumarray(idx, 1)';
            sov_table = table(unique_long_s, counts, zeros(size(unique_long_s)), 'VariableNames', {'long_s', 'count', 'used'});
            
            custom_colormap = zeros(numel(sovs), 3);
            for i = 1:numel(sovs)
                if conds{i}.isBaseline
                    custom_colormap(i,:) = funcs_.get_colormap_from_dic('baseline', 1);
                else
                    current_long_s = sovs{i}.long_s;
                    row = find(strcmp(sov_table.long_s, current_long_s));
                    sov_table.used(row) = sov_table.used(row) + 1;
                    sov_colormap = funcs_.get_colormap_from_dic(sovs{i}.short_s, sov_table.count(row));
                    custom_colormap(i,:) = sov_colormap(sov_table.used(row),:);
                end
            end
        end
        
        function custom_colormap = get_colormap_from_dic(key, num_shades)
            % Define the color dictionary
            color_dict = containers.Map(...
                {'wake', 'wm', 'wn', 'N2', 'N3', 'REM', 'N1', 'baseline','tREM','pREM'}, ...
                {[0.6, 0.9, 1], [0.5, 0.8, 1], [0, 0, 1], [1, 0.7, 0], [0, 1, 0], [1, 0, 0], [1, 0, 1], [0.5, 0.5 ,0.5], [1, 0, 0], [1, 0, 0]} ...
            );
        
            % Get the RGB color from the dictionary
            if isKey(color_dict, key)
                color_ = color_dict(key);
                custom_colormap = funcs_.create_custom_colormap(color_, num_shades);
            else
                error('Invalid sleep stage. Supported sleep stages are: wm, wn, N2, N3, REM, N1,intbk');
            end
        end
        
        function custom_colormap = create_custom_colormap(color_, num_shades)
            num_shades = num_shades+1;  % to skip first color black
            custom_colormap = zeros(num_shades, 3);
            
            for i = 1:3
                custom_colormap(:, i) = linspace(0, color_(i), num_shades);
            end

            custom_colormap(1, :) = []; % to skip first color black
        end
        
        function plot_erps(time_,variables_s,data,output_filename, var_colormap,varargin)
            p = inputParser;
            addRequired(p, 'time_'); addRequired(p, 'variables_s'); addRequired(p, 'data'); 
            addRequired(p, 'output_filename'); addRequired(p, 'var_colormap');

            addOptional(p, 'ylim_', []); addOptional(p, 'clust_electd', []); addOptional(p, 'subtitle_',""); addOptional(p, 'title_', "");
            addOptional(p, 'sig_timeranges',{}); addOptional(p, 'sig_timeranges_colormap',{}); 
            addOptional(p, 'bottom_string',{});
            addOptional(p, 'is_plot_ste', true); addOptional(p, 'is_plot_subs', false);
            addOptional(p,'plot_bp_filter','no')
            addOptional(p, 'plot_latency',  [time_(1),time_(end)]); addOptional(p, 'event_lines',  {});

            parse(p, time_,variables_s,data,output_filename, var_colormap,varargin{:});
            r = p.Results;
            
            if  ~r.is_plot_ste && ...
                (size(variables_s,2)==1 || (isstring(r.variables_s{1}) && numel(r.variables_s)==1))
                r.is_plot_ste = false;
                r.is_plot_subs = true;
            end

            fig = figure('Visible', 'off','Position', [0, 0, 1000, 800], 'Color', 'white');

            subplot('Position', [0.1, 0.35, 0.8, 0.6]);
            % plot variables lines
            one_div_sqrt_samp_size = 1/sqrt(size(r.data,1));
            for val_i=1:numel(r.variables_s)
                if isstring(r.variables_s{val_i}) || ischar(r.variables_s{val_i})
                    curr_var_val_name =r.variables_s{val_i};
                else
                    curr_var_val_name = num2str(r.variables_s{val_i}.long_s);
                end

                curr_plot_data = r.data(:,:,val_i);
                if ~strcmp(r.plot_bp_filter, 'no')
                    bpFilt = designfilt('bandpassfir', 'FilterOrder', 100, ...
                                       'CutoffFrequency1',r.plot_bp_filter(1), ...
                                       'CutoffFrequency2', r.plot_bp_filter(2), ...
                                        'SampleRate', 250);
                    for i = 1:size(data, 1)
                        curr_plot_data(i, :) = filtfilt(bpFilt, curr_plot_data(i, :));
                    end
                end

                
                % r.var_colormap need to keep being N x 3, N=#vars.
                if(r.is_plot_subs)
                    x = squeeze(curr_plot_data);
                    plot(r.time_,x,'color',[r.var_colormap(val_i,:) 0.3], 'HandleVisibility', 'off'); hold on;
                end
                if(r.is_plot_ste)
                    x = squeeze(curr_plot_data);
                    
                    shadedErrorBar2(r.time_,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',r.var_colormap(val_i,:),'DisplayName',curr_var_val_name,'LineWidth', 1.5},'patchSaturation',0.1); hold on;
                else
                    mean_subs = squeeze(mean(curr_plot_data,1));
                    if(r.is_plot_subs)
                        plot(r.time_,mean_subs,'Color','black','DisplayName',curr_var_val_name,'LineWidth', 1.5); hold on;
                    else
                        plot(r.time_,mean_subs,'Color',r.var_colormap(val_i,:),'DisplayName',curr_var_val_name,'LineWidth', 1.5); hold on;
                    end
                end               
            end

            if(r.is_plot_subs)
                r.ylim_ = r.ylim_ * 1.5;
            end

            % plot sig line
            for i=1:numel(r.sig_timeranges)
                if ~isempty(r.sig_timeranges{i})
                    sig_seqs = findNonZeroSequences(r.sig_timeranges{i});
                    for j=1:numel(sig_seqs)
                        sig_line_height =   r.ylim_(1) + ((r.ylim_(2) - r.ylim_(1)) / 7) - ((i-1) * 0.05);
                        curr_colormap = r.sig_timeranges_colormap{i};
                        plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{1},'DisplayName','','HandleVisibility', 'off',LineWidth=1.5);
                        hold on;
                        plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{2},'DisplayName','','HandleVisibility', 'off',LineWidth=1.5,LineStyle='--');
                        hold on;
                    end
                end
            end
           
            axis([r.plot_latency(1) r.plot_latency(end) r.ylim_(1) r.ylim_(2)]) 
            
            legend("Location","northeast","FontSize",12);
            xlabel('Time (s)','FontSize',15)
            ylabel('Amplitude (µV)','FontSize',15)
            ax = gca;
            ax.FontSize = 15;
            
            
%             if r.plot_latency(2)>= 5
%                 set(gcf,'Position',[0 0 1300 400])
%             else
%                 set(gcf,'Position',[0 0 1300 400])
%             end

            % plot event type vertical line
            if ~isempty(r.event_lines)
                for event_i=1:numel(r.event_lines)
                    event_time = r.event_lines{event_i}.('event_time');
                    event_color = r.event_lines{event_i}.('event_color');
                    event_text = r.event_lines{event_i}.('event_text');
                    plot([event_time, event_time], r.ylim_,'Color',event_color, 'LineWidth', 1,'DisplayName','','HandleVisibility', 'off');
                    text(event_time+(r.plot_latency(2)-r.plot_latency(1))/150, 0+(0.5*r.ylim_(2)), event_text,'Color',event_color, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',10,'LineStyle','--');
                end
            end
            
            % plot electrodes topography
            if ~isempty(r.clust_electd)
                axes('Position',[.02 .02 .25 .25])
                cfg = [];
                cfg.feedback    = 'no';
                cfg.elec= r.clust_electd{1};
                layout = ft_prepare_layout(cfg);
                ft_plot_layout(layout,'label','no','box','no','chanindx',r.clust_electd{2},'pointsize',22);
                hold on;
            end


            % plot text details
            try
                fig_text_info = sprintf("%s\n\n ___Electrode cluster details___\n%s\n\n___Trials stats___\n%s", ...
                        r.title_, r.subtitle_,r.bottom_string);
                if ~strcmp(r.plot_bp_filter, 'no')
                    fig_text_info = sprintf("%s\n\nBandpass: %.1f,%.1f",fig_text_info,r.plot_bp_filter(1),r.plot_bp_filter(2));
                end
                annotation('textbox', [0.3, 0, 0.95, 0.25],'String', fig_text_info, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none','Interpreter','none', 'FontSize', 8);
            catch
                % Do nothing if the warning is triggered
            end

            saveas(gcf,sprintf("%s.png",r.output_filename));
%             saveas(gcf,sprintf("%s.svg",r.output_filename));
            saveas(gcf,sprintf("%s.fig",r.output_filename));
            close;
        end

    end
end


function nonZeroSequences = findNonZeroSequences(array)
    nonZeroSequences = {}; % Initialize cell array to hold sequences
    currentSequence = [];  % Initialize an empty array for the current sequence
    
    for i = 1:length(array)
        if array(i) ~= 0
            % Add the number to the current sequence
            currentSequence = [currentSequence, array(i)];
        else
            if ~isempty(currentSequence)
                % Add the current sequence to the cell array and reset it
                nonZeroSequences{end+1} = currentSequence;
                currentSequence = [];
            end
        end
    end
    
    % Check if the last sequence goes until the end of the array
    if ~isempty(currentSequence)
        nonZeroSequences{end+1} = currentSequence;
    end
end

function Y = uniquePairs(X)
    n = numel(X); % Number of elements in X
    Y = {}; % Initialize empty cell array for pairs

    for i = 1:n-1
        for j = i+1:n
            % Create each unique pair and add to Y
            Y{end+1} = {X{i}, X{j}};
        end
    end
end
