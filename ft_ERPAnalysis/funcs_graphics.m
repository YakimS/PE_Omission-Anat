classdef funcs_graphics
    properties (SetAccess = private)
        imp
        electrodes
        label
        time
    end
    methods(Static)
        % constructor
        function fg = funcs_graphics(imp, label,electrodes, time)
            fg.imp = imp;
            fg.electrodes = electrodes;
            fg.label = label;
            fg.time = time;
        end

        % get/set
        function s = get_imp(fg)
            s = fg.imp;
        end
        function s = get_electrodes(fg)
            s = fg.electrodes;
        end
        function s = get_label(fg)
            s = fg.label;
        end
        function s = get_time(fg)
            s = fg.time;
        end

        %%%%%%%%%%%%%%%%%%%% Componenets Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function metadata_comp_string = plot_violin_comp_condSovPairs(f,out_dir, condSovPairs, elctrds_clusts, component ,plot_name,cfg)
            subs = f.imp.get_subs(f.imp);
            metadata_comp_string = "";
            % get colormap
            conds = cell(1, numel(condSovPairs));
            conds_sovs = cell(1, numel(condSovPairs));
            for i = 1:numel(condSovPairs)
                conds{i} = condSovPairs{i}{1}; % Extract the cond struct
                conds_sovs{i} = condSovPairs{i}{2};  % Extract the sov struct
            end
            curr_colormap = funcs_.get_colormap(conds_sovs,conds,'sov'); 
            
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electdLabel = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect_label');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                if isfield(elctrds_clusts.(fields_elctrds_clusts{ctp_i}),'pval')
                    clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');
                else
                    clust_pval = NaN;
                end
                
                curr_output_filename = sprintf('%s\\Vio_Comp-%s_name-%s_clust-%s',out_dir,component.short_s,plot_name,clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
                
                [comps,metadata_comp_string] = f.get_comp_plot(f, conds_sovs, subs,conds, {component},clust_electdLabel); %%% TODO: get data from fa

                trials_stats_string = "";
                subs_AvgActivity = zeros(size(subs,2),numel(condSovPairs)); 
                for csp_i=1:numel(condSovPairs)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, condSovPairs{csp_i}{1}.short_s,condSovPairs{csp_i}{2}.short_s);
                    sub_trials_count = zeros(1,(numel(subs)));
                    for sub_i = 1:size(subs,2)
                        curr = comps.(component.short_s).(condSovPairs{csp_i}{2}.short_s).(condSovPairs{csp_i}{1}.short_s).(sprintf("s_%s",subs{sub_i}));
                        sub_trials_count(sub_i) = curr.('trials_timelocked_avg');
                        subs_AvgActivity(sub_i,csp_i) =curr.('amplitude');
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end
                
                condSovPairsStrings = {};
                for pairs_i = 1:numel(condSovPairs)
                    condSovPairsStrings{end +1} = sprintf('%s',condSovPairs{pairs_i}{1}.long_s);
                end

                cfg.difference_res = [];
                cfg.difference_cohensD = [];
                for sc_i=2:numel(condSovPairs)
                    [cfg.difference_res(end+1),~,~] = signrank(subs_AvgActivity(:,sc_i-1) - subs_AvgActivity(:,sc_i));
                    cfg.difference_cohensD(end+1) = computeCohensD(subs_AvgActivity(:,sc_i-1) , subs_AvgActivity(:,sc_i));
                end
                
                cfg.title_ = sprintf('ERP, %s, %d subjects', plot_name,size(subs,2)); 
                cfg.subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);
                cfg.elctrds_clusts = {elctrds_clusts.('elec_gen_info'),clust_electdLabel};
                cfg.bottom_string =sprintf("%s\n%s",trials_stats_string,metadata_comp_string);

                funcs_.plot_violins(condSovPairsStrings, subs_AvgActivity, curr_colormap, curr_output_filename, cfg)
            end
        end

        %%%%%%%%%%%%%%%%%%%% ERP: spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function plot_erp_per_contrast_and_sov(f,out_dir,conds,conds_sovs,elctrds_clusts,cfg)   
            if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end

            curr_colormap = funcs_.get_colormap(conds_sovs,conds,'sov');       
            subs = f.imp.get_subs(f.imp); 
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electdLabel = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect_label');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                if isfield(elctrds_clusts.(fields_elctrds_clusts{ctp_i}),'pval')
                    clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');
                else
                    clust_pval = NaN;
                end

                curr_output_filename = sprintf('%s\\ERP_conds-%s+%s_condsSov-%s+%s_clust-%s', ...
                out_dir,conds{1}.short_s,conds{2}.short_s,conds_sovs{1}.short_s,conds_sovs{2}.short_s, clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
                
                stat = funcs_.cluster_permu_erp(f,conds,conds_sovs,clust_electdLabel,cfg.test_latency);
    
                % plot sig points
                if ~all(stat.mask ==0)
                    sig_timeranges = stat.mask .*stat.time;
                else
                    sig_timeranges = 0;
                end
                
                % get mean activity per sub and cond
                % allSubs_conds_AvgActivity average the activity over all electrods and time
                trials_stats_string = "";
                a_cond_timelock = f.imp.get_cond_timelocked(f.imp,f.imp.subs,conds{1},conds_sovs{1}); 
                length_plottime = numel( a_cond_timelock{1}.time(1): 0.004 :  a_cond_timelock{1}.time(end));
                allSubs_conds_AvgActivity = zeros(size(subs,2),length_plottime,size(conds,2)); 
                for cond_sov_j = 1:size(conds,2)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, conds{cond_sov_j}.short_s,conds_sovs{cond_sov_j}.short_s);
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,f.imp.subs,conds{cond_sov_j},conds_sovs{cond_sov_j}); 
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_sub_cond_struct.cfg.trials_timelocked_avg;
                        currcfg = [];
                        currcfg.channel = clust_electdLabel;
                        currcfg.avgoverchan = 'yes';
                        curr_sub_cond_struct = ft_selectdata(currcfg, curr_sub_cond_struct);
                        allSubs_conds_AvgActivity(sub_i,:,cond_sov_j) = curr_sub_cond_struct.avg;
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end               
    
                cfg.title_ = sprintf('ERP, %s(%s) vs %s(%s), %d subjects', conds{1}.short_s,conds_sovs{1}.short_s,conds{2}.short_s,conds_sovs{2}.short_s, size(subs,2));            
                cfg.subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);
                cfg.sig_timeranges = {sig_timeranges};
                cfg.sig_timeranges_colormaps = {{curr_colormap(1,:),curr_colormap(end,:)}};
                cfg.elctrds_clusts = {elctrds_clusts.('elec_gen_info'),clust_electdLabel};
                cfg.bottom_string = trials_stats_string;

                funcs_.plot_erps(f.time,conds,allSubs_conds_AvgActivity,curr_output_filename, curr_colormap, cfg)
            end
        end

        function plot_erp_per_condsSovPairs(f,out_dir,condSovPairs,elctrds_clusts,plot_name,cfg)   
            if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end
            if ~isfield(cfg, 'color_by_cond_or_sov')        cfg.color_by_cond_or_sov ='sov'; end

            subs = f.imp.get_subs(f.imp);

            conds = cell(1, numel(condSovPairs));
            conds_sovs = cell(1, numel(condSovPairs));
            for i = 1:numel(condSovPairs)
                conds{i} = condSovPairs{i}{1}; % Extract the cond struct
                conds_sovs{i} = condSovPairs{i}{2};  % Extract the sov struct
            end
            curr_colormap = funcs_.get_colormap(conds_sovs,conds,cfg.color_by_cond_or_sov); 

            
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electdLabel = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect_label');
                clust_name = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('short_s');
                if isfield(elctrds_clusts.(fields_elctrds_clusts{ctp_i}),'pval')
                    clust_pval = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('pval');
                else
                    clust_pval = NaN;
                end
                

                curr_output_filename = sprintf('%s\\ERP_name-%s_clust-%s',out_dir,plot_name,clust_name);
                if isfile(sprintf("%s.fig",curr_output_filename)) continue; end

                % get avg data to plot
                trials_stats_string = "";
                allSubs_sovs_AvgActivity = zeros(size(subs,2),size(f.time,2),numel(condSovPairs)); 
                for csp_i=1:numel(condSovPairs)
                    trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, condSovPairs{csp_i}{1}.short_s,condSovPairs{csp_i}{2}.short_s);
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,f.imp.subs,condSovPairs{csp_i}{1},condSovPairs{csp_i}{2}); 
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_subCondSov =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_subCondSov.cfg.trials_timelocked_avg;

                        currcfg = [];
                        currcfg.channel = clust_electdLabel;
                        currcfg.avgoverchan = 'yes';
                        curr_cond_timelocked = ft_selectdata(currcfg, curr_subCondSov);
                        allSubs_sovs_AvgActivity(sub_i,:,csp_i) = curr_cond_timelocked.avg;
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
                sig_timeranges = {};
                sig_timeranges_colormaps = {};
                for csp_i=1:size(unique_pairs_combo,1)
                    curr_condsov1 = condSovPairs{unique_pairs_combo(csp_i,1)};
                    curr_condsov2 = condSovPairs{unique_pairs_combo(csp_i,2)};
                    stat = funcs_.cluster_permu_erp(f,{curr_condsov1{1},curr_condsov2{1}}, ...
                                                        {curr_condsov1{2},curr_condsov2{2}},clust_electdLabel,cfg.test_latency);
                    % plot sig points
                    if ~all(stat.mask ==0)
                        sig_timeranges{end + 1} = stat.mask .*stat.time;
                    else
                        sig_timeranges{end + 1} = {};
                    end

                    curr_colormap_sov1 = curr_colormap(unique_pairs_combo(csp_i,1),:);
                    curr_colormap_sov2 = curr_colormap(unique_pairs_combo(csp_i,2),:);
                    sig_timeranges_colormaps{end + 1} = {curr_colormap_sov1,curr_colormap_sov2};
                end
                
                condSovPairsStrings = {};
                for pairs_i = 1:numel(condSovPairs)
                    condSovPairsStrings{end +1} = sprintf('%s, %s',condSovPairs{pairs_i}{1}.long_s,condSovPairs{pairs_i}{2}.long_s);
                end
                
                cfg.title_ = sprintf('ERP, %s, %d subjects', plot_name,size(subs,2)); 
                cfg.subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);
                cfg.elctrds_clusts = {elctrds_clusts.('elec_gen_info'),clust_electdLabel};
                cfg.sig_timeranges = sig_timeranges;
                cfg.sig_timeranges_colormaps = sig_timeranges_colormaps;
                cfg.bottom_string = sprintf("%s",trials_stats_string);

                funcs_.plot_erps(f.time,condSovPairsStrings,allSubs_sovs_AvgActivity, curr_output_filename, curr_colormap, cfg)
            end
        end
       
        % is sovs number of elements is 1, it plots all the subjects line.
        % Else, it plots the standard error
        function plot_erp_per_cond_across_sovs(f,out_dir,cond,sovs,elctrds_clusts,cfg)
            if ~isfield(cfg, 'test_latency')                    cfg.test_latency = [0, f.time(end)]; end
            if ~isfield(cfg, 'plot_latency')                    cfg.plot_latency = [f.time(1), f.time(end)]; end
            if ~isfield(cfg, 'event_lines')                     cfg.event_lines = {}; end 
            if ~isfield(cfg, 'is_plot_subs')                    cfg.is_plot_subs = false; end  
            if ~isfield(cfg, 'is_plot_ste')                     cfg.is_plot_ste = true; end  
            if ~isfield(cfg, 'plot_bp_filter')                  cfg.plot_bp_filter = 'no'; end
            if ~isfield(cfg, 'betweenSov_cond_forSigLine')      cfg.betweenSov_cond_forSigLine = {}; end
            if ~isfield(cfg, 'withinSov_contrast_forSigLine')   cfg.withinSov_contrast_forSigLine = {}; end
            if ~isfield(cfg, 'plot_bp_filter')                  cfg.plot_bp_filter = 'no'; end
            if ~isfield(cfg, 'ylim_')                           cfg.ylim_ =  [-1.2 2]; end

            
            subs = f.imp.get_subs(f.imp);
            bottom_string = "";

            sovs_colormap = zeros([numel(sovs),3]);
            for sov_i=1:numel(sovs)
                cols = funcs_.create_custom_colormap(sovs{sov_i}.color, 2);
                sovs_colormap(sov_i,:) = cols(2,:);
            end
            
            fields_elctrds_clusts = fieldnames(elctrds_clusts);
            for ctp_i=1:numel(fields_elctrds_clusts)
                if strcmp(fields_elctrds_clusts{ctp_i},'elec_gen_info') continue; end
                clust_electdLabel = elctrds_clusts.(fields_elctrds_clusts{ctp_i}).('elect_label');
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
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,f.imp.subs,cond,sovs{sov_i});
                    sub_trials_count = [];
                    for sub_i = 1:size(subs,2)
                        curr_sub_bl_struct =  curr_cond_timelock{sub_i};
                        sub_trials_count(end+1) = curr_sub_bl_struct.cfg.trials_timelocked_avg;
                        currcfg = [];
                        currcfg.channel = clust_electdLabel;
                        currcfg.avgoverchan = 'yes';
                        curr_cond_timelocked = ft_selectdata(currcfg, curr_sub_bl_struct);
                        allSubs_sovs_AvgActivity(sub_i,:,sov_i) = curr_cond_timelocked.avg;
                    end
                    trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, mean(sub_trials_count), std(sub_trials_count), min(sub_trials_count),max(sub_trials_count));
                end
                bottom_string = sprintf("%s%s\n",bottom_string,trials_stats_string);

                if isfield(cfg, 'plot_comp')
%                     [cfg.plot_comp, comp_metadata_string] = f.get_comp_plot(f, sovs, subs, {cond} ,cfg.plot_comp,cfg.plot_comp_mean_over_conds,clust_electdLabel);
                    [cfg.plot_comp, comp_metadata_string] = f.get_comp_plot(f, sovs, subs, {cond} ,cfg.plot_comp,clust_electdLabel);
                    bottom_string = sprintf("%s%s\n",bottom_string,comp_metadata_string);
                end
                
                % get siglines data
                sig_timeranges = {};
                sig_timeranges_colormaps = {};
                if ~isempty(cfg.withinSov_contrast_forSigLine)
                    for sov_i=1:numel(sovs)
                        stat = funcs_.cluster_permu_erp(f,cfg.withinSov_contrast_forSigLine,{sovs{sov_i},sovs{sov_i}},clust_electd,cfg.test_latency);
                        % plot sig points
                        if ~all(stat.mask ==0)
                            sig_timeranges{end + 1} = stat.mask .*stat.time;
                        else
                            sig_timeranges{end + 1} = {};
                        end
                        curr_colormap = funcs_.create_custom_colormap(sovs{sov_i}.color, 2);
                        sig_timeranges_colormaps{end + 1} = {curr_colormap(1,:),curr_colormap(end,:)};
                    end
                end
                if ~isempty(cfg.betweenSov_cond_forSigLine)
                    sovs_pairs = uniquePairs(sovs);
                    for sp_i=1:numel(sovs_pairs)
                        stat = funcs_.cluster_permu_erp(f,{cfg.betweenSov_cond_forSigLine,cfg.betweenSov_cond_forSigLine},sovs_pairs{sp_i},clust_electd,cfg.test_latency);
                        % plot sig points
                        if ~all(stat.mask ==0)
                            sig_timeranges{end + 1} = stat.mask .*stat.time;
                        else
                            sig_timeranges{end + 1} = {};
                        end
                        curr_colormap_sov1 = funcs_.create_custom_colormap(sovs_pairs{sp_i}{1}{sov_i}.color, 2);
                        curr_colormap_sov2 = funcs_.create_custom_colormap(sovs_pairs{sp_i}{2}{sov_i}.color, 2);
                        sig_timeranges_colormaps{end + 1} = {curr_colormap_sov1(2,:),curr_colormap_sov2(2,:)};
                    end
                end
                
                cfg.title_ = sprintf('ERP, Condition-%s, %d subjects', cond.short_s,size(subs,2)); 
                cfg.subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);  
                cfg.elctrds_clusts = {elctrds_clusts.('elec_gen_info'),clust_electdLabel};
                cfg.sig_timeranges = sig_timeranges;
                cfg.sig_timerange_colormaps = sig_timeranges_colormaps;
                cfg.bottom_string = bottom_string;
                funcs_.plot_erps(f.time, sovs,allSubs_sovs_AvgActivity, curr_output_filename, sovs_colormap, cfg)
            end
        end

        function plot_violins(variables_s, data, var_colormap, output_filename, cfg)
            if ~isfield(cfg, 'is_plot_box')                 cfg.is_plot_box = true; end 
            if ~isfield(cfg, 'ylim_')                       cfg.ylim_ =  [-8 8]; end
            if ~isfield(cfg, 'elctrds_clusts')              cfg.elctrds_clusts = []; end 
            if ~isfield(cfg, 'subtitle_')                   cfg.subtitle_ = ""; end 
            if ~isfield(cfg, 'title_')                      cfg.title_ = {}; end 
            if ~isfield(cfg, 'bottom_string')               cfg.bottom_string = ""; end 
            if ~isfield(cfg, 'sig_timeranges')              cfg.sig_timeranges = {}; end 
            if ~isfield(cfg, 'sig_timeranges_colormaps')    cfg.sig_timeranges_colormaps = {}; end
            if ~isfield(cfg, 'difference_res')              cfg.difference_res = {}; end
            if ~isfield(cfg, 'difference_cohensD')          cfg.difference_cohensD = {}; end

            
            % create a main figure
             fig = figure('Visible', 'off','Position', [0, 0, 1000, 1000], 'Color', 'white');
%             fig = figure('Position', [0, 0, 1000, 800], 'Color', 'white');
            subplot('Position', [0.2, 0.4, 0.4, 0.4]);

            % inject main fig
            oneline_data = data(:);
            [rows, cols] = size(data);
            column_indices_matrix = repmat(1:cols, rows, 1);
            column_indices_vector = column_indices_matrix(:);
            daviolinplot(oneline_data,'groups', column_indices_vector, ...
                'color',var_colormap,'scatter',1, ...
                'legend',variables_s,'xtlabels', variables_s,'violinwidth',1.2,'boxwidth',1.2);
            config_main_fig('Repitition','Amplitude (µV)',cfg)

            % inject topography
            % plot electrodes topography
            if ~isempty(cfg.elctrds_clusts)
                axes('Position',[.02 .02 .25 .25])
                plot_electrode_topography(cfg.elctrds_clusts{1},cfg.elctrds_clusts{2});
                hold on;
            end

            % inject text          
            plot_text_fig_details([0.3, 0, 0.35, 0.29], [0.65, 0, 0.35, 0.29],cfg)
            % plot text details


            % save
            meta= {};
            meta.cfg = cfg;
            meta.variables_s = variables_s;
            meta.data = data;
            save(sprintf("%s.mat",output_filename),"meta");
            saveas(gcf,sprintf("%s.png",output_filename));
            saveas(gcf,sprintf("%s.fig",output_filename));
            close;
        end
       
        % if event_lines.time is single number it creates a line, if 2, it creates a transparent rectangle
        function plot_TCP_res(data, elctrds_clusts, cfg)
            if ~isfield(cfg, 'is_plot_subs')                cfg.is_plot_subs = false; end  
            if ~isfield(cfg, 'is_plot_ste')                 cfg.is_plot_ste = true; end 
            if ~isfield(cfg, 'plot_bp_filter')              cfg.plot_bp_filter = 'no'; end
            if ~isfield(cfg, 'ylim_')                       cfg.ylim_ =  [-3 3]; end
            if ~isfield(cfg, 'plot_latency')                cfg.plot_latency = [f.time(1), f.time(end)]; end
            if ~isfield(cfg, 'event_lines')                 cfg.event_lines = {}; end 

            if ~isfield(cfg, 'elctrds_clusts')              cfg.elctrds_clusts = []; end 
            if ~isfield(cfg, 'subtitle_')                   cfg.subtitle_ = ""; end 
            if ~isfield(cfg, 'title_')                      cfg.title_ = {}; end 
            if ~isfield(cfg, 'bottom_string')               cfg.bottom_string = ""; end 
            if ~isfield(cfg, 'sig_timeranges')              cfg.sig_timeranges = {}; end 
            if ~isfield(cfg, 'sig_timeranges_colormaps')     cfg.sig_timeranges_colormaps = {}; end 

            if ~isfield(cfg, 'ticksX')                      cfg.ticksX = []; end
            if ~isfield(cfg, 'ticksY')                      cfg.ticksY = []; end
            if ~isfield(cfg, 'axisFontSize')                cfg.axisFontSize = 15; end
            if ~isfield(cfg, 'LineWidth')                   cfg.LineWidth = (cfg.ylim_(2) - cfg.ylim_(1))*0.3; end

            if ~isfield(cfg, 'is_plot_comp')        cfg.is_plot_comp ='no'; end

            if  ~cfg.is_plot_ste && ...
                (size(variables_s,2)==1 || (isstring(variables_s{1}) && numel(variables_s)==1))
                cfg.is_plot_ste = false;
                cfg.is_plot_subs = true;
            end

            fig = figure('Visible', 'off','Position', [0, 0, 1000, 1000], 'Color', 'white');
            subplot('Position', [0.1, 0.4, 0.8, 0.55]);
            
            if ~strcmp(cfg.plot_bp_filter, 'no')    data = bandpass_filter_data(data, cfg.plot_bp_filter);   end

            % plot variables lines
            for var_i=1:numel(variables_s)
                if isstring(variables_s{var_i}) || ischar(variables_s{var_i})
                    curr_var_name =variables_s{var_i};
                else
                    curr_var_name = num2str(variables_s{var_i}.long_s);
                end                
                % r.var_colormap need to keep being N x 3, N=#vars.
                if(cfg.is_plot_subs)
                    x = squeeze(curr_plot_data);
                    var_colormap = lines(size(x,1));
                    for x_i = 1:size(x,1)
                        plot(time_, x(x_i,:), 'color', [var_colormap(x_i, :)], 'HandleVisibility', 'off', 'LineWidth', 1); % Use color with transparency
                        hold on;
                    end
%                     plot(time_,x,'color',[var_colormap(val_i,:) 0.3], 'HandleVisibility', 'off'); hold on;
                    if isfield(cfg, 'plot_comp')    plot_component_dot_per_subject(cfg.plot_comp);   end
                end
                if(cfg.is_plot_ste)
                    x = squeeze(curr_plot_data);
                    shadedErrorBar2(time_,x,{@mean, @(x) 1/sqrt(size(data,1))*std(x)},'lineprops',{'Color',var_colormap(var_i,:),'DisplayName',curr_var_name,'LineWidth', 1.5},'patchSaturation',0.1); hold on;
                else
                    mean_subs = squeeze(mean(curr_plot_data,1));
                    if(cfg.is_plot_subs)  color_ = 'black';
                    else                  color_ =var_colormap(var_i,:); end
                    plot(time_,mean_subs,'Color',color_,'DisplayName',curr_var_name,'LineWidth', 1.5); hold on;
                end               
            end

            % plot event type vertical line/rect
            if ~isempty(cfg.event_lines)
                text_pos_factor = 0.8;
                add_event_vertical_line(text_pos_factor,cfg.event_lines,cfg.ylim_,cfg.plot_latency)
            end

            % plot sig line
            general_sig_line_height_factor = 11;
            distance_between_lines_factor = 0.2;
            plot_sig_line(cfg.sig_timeranges,cfg.sig_timeranges_colormaps,cfg.ylim_,cfg.LineWidth,general_sig_line_height_factor,distance_between_lines_factor)  
           
            % set general fig params
            config_main_fig('Time (s)','Amplitude (µV)',cfg)

            % plot electrodes topography
            axes('Position',[.02 .02 .25 .25])
            plot_electrode_topography(elctrds_clusts{1},  elctrds_clusts{2});
            hold on;

            plot_text_fig_details([0.3, 0, 0.35, 0.29], [0.65, 0, 0.35, 0.29],cfg)

            meta= {};
            meta.cfg = cfg;
            meta.variables_s = variables_s;
            meta.data = data;
            meta.time_ = time_;
            save(sprintf("%s.mat",output_filename),"meta");
            saveas(gcf,sprintf("%s.png",output_filename));
%             saveas(gcf,sprintf("%s.svg",r.output_filename));
            saveas(gcf,sprintf("%s.fig",output_filename));
            close;
        end
    end


    methods(Access=private, Static)
        function plot_text_fig_details(loc1, loc2,cfg)
            try
                % Construct the full text string with headers and information
                fig_text_info = sprintf('%s\n\n ___Electrode cluster details___\n%s',  cfg.title_, cfg.subtitle_);
                if cfg.difference_res
                    for t_i=1:numel(cfg.difference_res)
                        difference_res_string = sprintf("%s\n%s ~= %s = %.5f",difference_res_string,variables_s{t_i},variables_s{t_i+1},cfg.difference_res(t_i));
                    end
                    fig_text_info = sprintf('%s\n___Difference-sigrank results___%s', fig_text_info, difference_res_string);
                end
                if cfg.difference_cohensD
                    for t_i=1:numel(cfg.difference_cohensD)
                        difference_cohensD_string = sprintf("%s\n%s ~= %s = %.5f",difference_cohensD_string,variables_s{t_i},variables_s{t_i+1},cfg.difference_cohensD(t_i));
                    end
                    fig_text_info = sprintf('%s\n___Difference-CohensD results___%s', fig_text_info, difference_cohensD_string);
                end
                if ~strcmp(cfg.plot_bp_filter, 'no')
                    fig_text_info = sprintf("%s\n\nBandpass: %.1f,%.1f",fig_text_info,cfg.plot_bp_filter(1),cfg.plot_bp_filter(2));
                end
                fig_text_info =  sprintf('%s\n___Trials stats___\n%s', fig_text_info, cfg.bottom_string);
                fig_text_info = char(fig_text_info);
            
                header_indices = regexp(fig_text_info, '___.*?___');
                num_letters = sum(isletter(fig_text_info));

                % Find the middle of the letter count
                mid_letter_index = floor(num_letters / 2);
                letter_count = 0;
                split_index = 0; 
                % Traverse the characters in the string and count letters
                for i = 1:numel(fig_text_info)
                    if isletter(fig_text_info(i))
                        letter_count = letter_count + 1;  % Count the letters
                    end
                    if letter_count >= mid_letter_index
                        split_index = i;  % Store the character index where the letter count reaches the midpoint
                        break;
                    end
                end

                % Now split the text at the closest header to the midpoint
                if numel(header_indices) > 2
                    [~, closest_header_index] = min(abs(header_indices - split_index));
                    part1 = fig_text_info(1:header_indices(closest_header_index) - 1);
                    part2 = fig_text_info(header_indices(closest_header_index):end);
                else
                    % If there's only one header or no headers, display the text in one box
                    part1 = fig_text_info;
                    part2 = '';
                end

                % Place two textboxes in the figure
                annotation('textbox',loc1, 'String', part1, ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none', ...
                    'Interpreter', 'none', 'FontSize', 7);
                if ~isempty(part2)
                    annotation('textbox', loc2, 'String', part2, ...
                        'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none', ...
                        'Interpreter', 'none', 'FontSize', 7);
                end
            catch
                % Handle errors gracefully
            end
        end

        function plot_component_dot_per_subject(subj_comp_details)
            structfun(@(curr_comp) ...
                            structfun(@(curr_sov) ...
                                structfun(@(curr_sub) ...
                                    structfun(@(curr_cond) ...
                                        plot(curr_cond.latency, curr_cond.amplitude, ...
                                        'bo', 'MarkerSize', 3, 'MarkerFaceColor', curr_cond.color, ...
                                        'HandleVisibility', 'off'), ...
                                    curr_sub, 'UniformOutput', false), ...
                                curr_sov, 'UniformOutput', false), ...
                            curr_comp, 'UniformOutput', false), ...
                        subj_comp_details, 'UniformOutput', false);
        end
        
        function plot_electrode_topography(elec, labels)
            cfg_ftplot = [];
            cfg_ftplot.feedback    = 'no';
            cfg_ftplot.elec= elec;
            layout = ft_prepare_layout(cfg_ftplot);
            layout_chanindx = match_str(layout.label,labels);
            ft_plot_layout(layout,'label','no','box','no','chanindx',layout_chanindx,'pointsize',30,'pointcolor','black');
        end

        % data structure: sub,time,variable
        function data = bandpass_filter_data(data, bp_filter_range)
            bpFilt = designfilt('bandpassfir', 'FilterOrder', 100, ...
                               'CutoffFrequency1',bp_filter_range(1), ...
                               'CutoffFrequency2', bp_filter_range(2), ...
                                'SampleRate', 250);
            for val_i=1:numel(variables_s)
                for sub_i = 1:size(data, 1)
                    data(sub_i,:,val_i) = filtfilt(bpFilt, data(sub_i,:,val_i));
                end
            end
        end

        function plot_event_vertical_line(text_pos_factor,event_lines,ylim_,plot_latency)
            for event_i=1:numel(event_lines)
                event_time = event_lines{event_i}.('event_time');
                event_color = event_lines{event_i}.('event_color');
                event_text = event_lines{event_i}.('event_text');
                if numel(event_time)==1
                    plot([event_time, event_time], ylim_,'Color',event_color, 'LineWidth', 1,'DisplayName','','HandleVisibility', 'off');
                    text(event_time+(plot_latency(2)-plot_latency(1))/150, text_pos_factor*ylim_(2), event_text,'Color',event_color, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',20,'LineStyle','--');
                else
                    rect_position = [event_time(1), ylim_(1), (event_time(2)-event_time(1)), abs(ylim_(1))+abs(ylim_(2))]; % [x, y, width, height] cfg.ylim_(2)
                    hRect = rectangle('Position', rect_position, 'FaceColor', event_color, 'EdgeColor', [.2, .2 ,.2, 0.2]);
                    uistack(hRect, 'bottom');
                    text(event_time(1)+(plot_latency(2)-plot_latency(1))/150, text_pos_factor*ylim_(2), event_text,'Color',event_color, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',20,'LineStyle','--');
                end
            end
        end

        function plot_sig_line(sig_timeranges,sig_timeranges_colormaps,ylim_,LineWidth,general_sig_line_height_factor,distance_between_lines_factor)
            for i=1:numel(sig_timeranges)
                if ~isempty(sig_timeranges{i})
                    sig_seqs = findNonZeroSequences(sig_timeranges{i});
                    for j=1:numel(sig_seqs)
                        sig_line_height =   ylim_(1) + ((ylim_(2) - ylim_(1)) / general_sig_line_height_factor) - ((i-1) * (ylim_(2) - ylim_(1))*distance_between_lines_factor);
                        curr_colormap = sig_timeranges_colormaps{i};
                        plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{1},'DisplayName','','HandleVisibility', 'off','LineWidth',LineWidth);
                        hold on;
                        plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{2},'DisplayName','','HandleVisibility', 'off','LineWidth',LineWidth,LineStyle='--');
                        hold on;
                    end
                end
            end
        end
  
        function config_main_fig(xlabel_string,ylabel_string,cfg)
            if isfield(cfg,plot_latency) && isfield(cfg,ylim_)
                axis([cfg.plot_latency(1) cfg.plot_latency(end) cfg.ylim_(1) cfg.ylim_(2)]) ;
                ylim(cfg.ylim_);
                legend("Location","northeast","FontSize",cfg.axisFontSize);
            end
            
            if numel(cfg.ticksX) > 0     
                xticks(cfg.ticksX)       
            end
            if numel(cfg.ticksY) > 0     
                yticks(cfg.ticksY)        
            end

            ylabel(xlabel_string,'FontSize',cfg.axisFontSize)
            xlabel(ylabel_string,'FontSize',cfg.axisFontSize)
            ax = gca;
            ax.FontSize = cfg.axisFontSize;
        end

        function plot_STCP_res(fa,STCP_res,plot_latency,test_latency,STCP_res_filename,subt_conds12)
            is_cluster_exists = false;
            if isfield(STCP_res, "posclusters")
                pos_prob = [STCP_res.posclusters.('prob')];
                if  ~isempty(pos_prob) && pos_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end
            if isfield(STCP_res, "negclusters")
                neg_prob = [STCP_res.negclusters.('prob')];
                if  ~isempty(neg_prob) && neg_prob(1)<=0.05
                    is_cluster_exists = true;
                end
            end
            
            filename = erase(STCP_res_filename,".mat");
            sample_rate = 250;
            rec_fps = 1/sample_rate;
            STCP_res.elec = fa.get_electrodes(fa);
            
            timediff = ((plot_latency(end) - plot_latency(1))/16);
            toi = plot_latency(1): timediff :plot_latency(end);
            cfg_topoplot = [];
            cfg_topoplot.parameter = 'avg';
            cfg_topoplot.xlim = toi;
            funcs_graphics.topo_plot(cfg_topoplot,subt_conds12);

            if is_cluster_exists
                cfg_clustplot = rmfield(cfg_topoplot, 'xlim');
                timediff = ceil(((test_latency(end) - test_latency(1))/16) / rec_fps) * rec_fps;
                toi = cfg.test_latency(1): timediff :cfg.test_latency(end);
                cfg_clustplot.toi = toi;
                STCP_res.elec = cond1_struct{1}.elec;   % TODO: get electrodes from somewhere else
                cfg_clustplot.parameter = 'subt_conds12';
                funcs_graphics.cluster_plot(STCP_res,cfg_clustplot); 

                cfg_clustplot.parameter = 'stat';
                cfg_clustplot.highlightcolorpos =[0.5 0.5 0.5]; 
                cfg_clustplot.highlightcolorneg = [0.5 0.5 0.5]; 
                cfg_clustplot.zlim  = [-5,5];
                funcs_graphics.cluster_plot(STCP_res,cfg_clustplot); 

                figures = findall(0, 'Type', 'figure');
                set(figures(1), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 600], 'PaperPositionMode', 'auto');
                set(figures(2), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 600], 'PaperPositionMode', 'auto');
                set(figures(3), 'Units', 'pixels', 'Position', [0.05, 0.05, 900, 600], 'PaperPositionMode', 'auto');
                
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
%                     saveas(combined_figure, sprintf("%s.fig", filename));
            else
                saveas(gcf,sprintf("%s.png",filename));
%                     saveas(gcf,sprintf("%s.fig",filename),'-v7.3');
            end
            close 'all';
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

            tolerance = 1e-10;
            plot_struct = rmfield(cond1_struct{1}, {'powspctrm','cfg'});
            test_freq_index_1 = find(abs(plot_struct.freq -  cfg.frequency(1)) < tolerance);
            test_freq_index_2 = find(abs(plot_struct.freq -  cfg.frequency(2)) < tolerance);
            plot_struct.('data_contrast') = powspctrm_diff_avg(:,test_freq_index_1:test_freq_index_2,:);
            plot_struct.('label') = stat.label;
            plot_struct.('stat') = stat.stat;
            plot_struct.('freq') = stat.freq;
            mask_ = zeros(size(plot_struct.('data_contrast')));
            test_latency_index_1 = find(abs(plot_struct.time -  test_latency(1)) < tolerance);
            test_latency_index_2 = find(abs(plot_struct.time -  test_latency(2)) < tolerance);
            mask_(:,:,test_latency_index_1:test_latency_index_2) = stat.mask();
            plot_struct.('mask') = logical(mask_);

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
            cfg_fig              = [];
            cfg_fig.zlim         = [-1 1];
            cfg_fig.baseline     = [-0.2,-0.1];
            cfg_fig.xlim         = plot_timerange;
            cfg_fig.baselinetype = 'relchange';
            cfg_fig.parameter = 'data_contrast';
            cfg_fig.maskparameter = 'mask'; 
            cfg_fig.maskstyle    = 'outline'; %'opacity', 'saturation', or 'outline'
            cfg_fig.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
            cfg_fig.title = sprintf('Conds diff, %s, bl:[%.2f, %.2f]',cfg_fig.baselinetype,cfg_fig.baseline(1),cfg_fig.baseline(2));
            cfg_fig.figure         = fig;
            subplot(2, 2, 2);
            ft_singleplotTFR(cfg_fig, plot_struct);

            % % cond1
            cfg_fig.zlim         = [-.1 .1];
            plot_struct.('data_contrast') = powspctrm_cond1_avg(:,test_freq_index_1:test_freq_index_2,:);
            cfg_fig.title = sprintf('Cond 1, %s, bl:[%.2f, %.2f]',cfg_fig.baselinetype,cfg_fig.baseline(1),cfg_fig.baseline(2));
            cfg_fig.xlim         = plot_timerange;
            subplot(2, 2, 1);
            ft_singleplotTFR(cfg_fig, plot_struct);

            % % cond2
            plot_struct.('data_contrast') = powspctrm_cond2_avg(:,test_freq_index_1:test_freq_index_2,:);
            cfg_fig.title = sprintf('Cond 2, %s, bl:[%.2f, %.2f]',cfg_fig.baselinetype,cfg_fig.baseline(1),cfg_fig.baseline(2));
            cfg_fig.xlim         = plot_timerange;
            subplot(2, 2, 3);
            ft_singleplotTFR(cfg_fig, plot_struct);

            % 
            % %%% cfg stat
            cfg_fig              = [];
            cfg_fig.baseline     = 'no';
            cfg_fig.parameter = 'stat';
            cfg_fig.maskparameter = 'mask'; 
            cfg_fig.maskstyle    = 'outline';%'opacity', 'saturation', or 'outline'
            cfg_fig.zlim         = [-3. 3];
            cfg_fig.layout =  ft_read_sens('GSN-HydroCel-129.sfp');
            cfg_fig.title = sprintf('Statistic T');
            cfg_fig.figure         = fig;
            subplot(2, 2, 4);
            ft_singleplotTFR(cfg_fig, stat);

            sgtitle(sprintf('%s \n Electrodes: %s',fig_title,clust_struct.short_s));

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
            cfg.numrandomization = 10000;
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

        function stat = cluster_permu_erp(f,conds,sovs,clust_electdLabel,latency)
            subs = f.imp.get_subs(f.imp);
            
            all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
            for cond_sov_j = 1:size(conds,2)
                curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,f.imp.subs,conds{cond_sov_j},sovs{cond_sov_j}); 
                for sub_i = 1:size(subs,2)
                    curr_subcond = curr_cond_timelock{sub_i};
%                     curr_subcond = rmfield(curr_subcond,'dof');
%                     curr_subcond = rmfield(curr_subcond,'var');
%                     curr_subcond.label = {'eletd_avg'};
%                     %curr_subcond.var = std(curr_subcond.avg(clust_mask,:),1,1);
%                     curr_subcond.avg = mean(curr_subcond.avg(clust_mask,:),1);
                    all_conds_timelocked_currClustElecd{cond_sov_j}{sub_i} = curr_subcond;
                end
            end
        
            % cluster permutation anaslysis 
            % define the parameters for the statistical comparison
            cfg = [];
            cfg.channel     = clust_electdLabel;
            cfg.latency     = latency;
            cfg.avgovertime = 'no';
            cfg.avgoverchan = 'yes';
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
%             if ~isfield(cfg, 'saveaspng')           error('cfg must include saveaspng field with filename'); end
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
            if ~isfield(cfg, 'parameter')           error('cfg must include parameter field with parameter'); end 
            if ~isfield(cfg, 'xlim')                 error('cfg must include parameter toi with time range of intrest'); end 
            if ~isfield(cfg, 'zlim')                cfg.zlim = [-1,1]; end
            if ~isfield(cfg, 'subplotsize')         cfg.subplotsize =[4,4]; end             % better keep it that way, becuase this is the default grid of ft_topoplot
            if ~isfield(cfg, 'style')               cfg.style = 'straight'; end             %     colormap only. Defualt - colormap and conture lines
            if ~isfield(cfg, 'comment')             cfg.comment = 'xlim'; end
            if ~isfield(cfg, 'marker')              cfg.marker = 'off'; end
            if ~isfield(cfg, 'colormap')            cfg.colormap = 'parula'; end
            if ~isfield(cfg, 'commentpos')          cfg.commentpos = 'middletop'; end

            cfg.layout = preVsPoststim_res.elec;
            cfg.interactive = 'no';
            cfg.rotate = 0;

            cfg  = ft_topoplotER(cfg,preVsPoststim_res);
            
        end
    
        % each cond have to corresponde to sov. Such that they are cond-sov
        % pairs
        function custom_colormap = get_colormap(sovs, conds,by_cond_or_sov)
            filtered_sovs = sovs(cellfun(@(x) x.isBaseline == 0, conds)); % Filter sovs where isBaseline is equal to 0
            if strcmp(by_cond_or_sov,'cond')
                var = conds;
            elseif strcmp(by_cond_or_sov,'sov')
                var = filtered_sovs;
            end

            long_s_values = cellfun(@(x) x.long_s, var, 'UniformOutput', false); 
            long_s_values = cellfun(@(x) x{1}, long_s_values, 'UniformOutput', false);
            [unique_long_s, ~, idx] = unique(long_s_values);
            counts = accumarray(idx, 1)';
            var_table = table(unique_long_s, counts, zeros(size(unique_long_s)), 'VariableNames', {'long_s', 'count', 'used'});
            
            custom_colormap = zeros(numel(sovs), 3);
            var_i = 1;
            for i = 1:numel(sovs)
                if conds{i}.isBaseline
                    custom_colormap(i,:) = funcs_.create_custom_colormap([0.5, 0.5 ,0.5], 1);
                else
                    current_long_s = var{var_i}.long_s;
                    row = find(strcmp(var_table.long_s, current_long_s));
                    var_table.used(row) = var_table.used(row) + 1;
                    var_colormap = funcs_.create_custom_colormap(var{var_i}.color, var_table.count(row));
                    custom_colormap(i,:) = var_colormap(var_table.used(row),:);
                    var_i = var_i+1;
                end
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

function cohens_d = computeCohensD(group1_array, group2_array)
    % Means and standard deviations
    mean1 = mean(group1_array);
    mean2 = mean(group2_array);
    std1 = std(group1_array);
    std2 = std(group2_array);
    
    % Pooled standard deviation
    n1 = length(group1_array);
    n2 = length(group2_array);
    sd_pooled = sqrt(((n1 - 1)*std1^2 + (n2 - 1)*std2^2) / (n1 + n2 - 2));
    
    % Cohen's d
    cohens_d = (mean1 - mean2) / sd_pooled;
end
