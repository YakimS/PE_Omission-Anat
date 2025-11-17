
function plot_erp_per_condsSovPairs(out_dir,subs, epoch_time, condSovPairs,elctrds_clusts,plot_name,dirs, cfg)  
    if ~isfield(cfg, 'is_test')             cfg.is_test = true; end
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, epoch_time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [epoch_time(1), epoch_time(end)]; end
    if ~isfield(cfg, 'event_lines')         cfg.event_lines = {}; end
    if ~isfield(cfg, 'plot_bp_filter')      cfg.plot_bp_filter = 'no'; end
    if ~isfield(cfg, 'ylim_')               cfg.ylim_ = [-1.2 2]; end
    if ~isfield(cfg, 'is_plot_comp')        cfg.is_plot_comp ='no'; end
    if ~isfield(cfg, 'color_by_cond_or_sov')        cfg.color_by_cond_or_sov ='sov'; end
    if ~isfield(cfg, 'test_successive_conds')        cfg.test_successive_conds =0; end

    conds = cell(1, numel(condSovPairs));
    conds_sovs = cell(1, numel(condSovPairs));
    for i = 1:numel(condSovPairs)
        conds{i} = condSovPairs{i}{1}; % Extract the cond struct
        conds_sovs{i} = condSovPairs{i}{2};  % Extract the sov struct
    end
    curr_colormap = get_colormap(conds_sovs,conds,cfg.color_by_cond_or_sov); 

    
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
        allSubs_sovs_AvgActivity = zeros(size(subs,2),size(epoch_time,2),numel(condSovPairs)); 
        for csp_i=1:numel(condSovPairs)
            trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, condSovPairs{csp_i}{1}.short_s,condSovPairs{csp_i}{2}.short_s);
            curr_cond_timelock = get_cond_timelocked(subs,condSovPairs{csp_i}{1},condSovPairs{csp_i}{2},dirs.ft_cond_input,dirs.ft_cond_output); 
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

        test_cond_pairs = [];
        if cfg.test_successive_conds
            for i = 1:numel(condSovPairs)-1
                test_cond_pairs = [test_cond_pairs; i i+1];
            end
        else
            for i = 1:numel(condSovPairs)-1
                for j = i+1:numel(condSovPairs)
                    test_cond_pairs = [test_cond_pairs; i j]; % Append the pair to the matrix
                end
            end
        end


        % get siglines data
        sig_timeranges = {};
        sig_timeranges_colormaps = {};
        if cfg.is_test
            for csp_i=1:size(test_cond_pairs,1)
                curr_condsov1 = condSovPairs{test_cond_pairs(csp_i,1)};
                curr_condsov2 = condSovPairs{test_cond_pairs(csp_i,2)};
                stat = cluster_permu_erp(subs,{curr_condsov1{1},curr_condsov2{1}}, ...
                                                    {curr_condsov1{2},curr_condsov2{2}},clust_electdLabel,cfg.test_latency,dirs);
                
                contrast_string = sprintf("%s_%s__vs__%s_%s",curr_condsov1{1}.short_s,curr_condsov1{2}.short_s,curr_condsov2{1}.short_s,curr_condsov2{2}.short_s);
                save_stat = stat;
                save_stat.cfg = rmfield(stat.cfg,'previous');
                cfg.stats.(contrast_string) = save_stat;
                
                % plot sig points
                if ~all(stat.mask ==0)
                    sig_timeranges{end + 1} = stat.mask .*stat.time;
                else
                    sig_timeranges{end + 1} = {};
                end

                curr_colormap_sov1 = curr_colormap(test_cond_pairs(csp_i,1),:);
                curr_colormap_sov2 = curr_colormap(test_cond_pairs(csp_i,2),:);
                sig_timeranges_colormaps{end + 1} = {curr_colormap_sov1,curr_colormap_sov2};
            end
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

        plot_erps(epoch_time,condSovPairsStrings,allSubs_sovs_AvgActivity, curr_output_filename, curr_colormap, cfg)
    end
end


