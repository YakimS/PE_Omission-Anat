% is sovs number of elements is 1, it plots all the subjects line.
% Else, it plots the standard error
function plot_erp_per_cond_across_sovs(dirs,out_dir,epoch_time,subs,cond,sovs,elctrds_clusts,cfg)
    if ~isfield(cfg, 'test_latency')                    cfg.test_latency = [0, epoch_time(end)]; end
    if ~isfield(cfg, 'plot_latency')                    cfg.plot_latency = [epoch_time(1), epoch_time(end)]; end
    if ~isfield(cfg, 'event_lines')                     cfg.event_lines = {}; end 
    if ~isfield(cfg, 'is_plot_subs')                    cfg.is_plot_subs = false; end  
    if ~isfield(cfg, 'is_plot_ste')                     cfg.is_plot_ste = true; end  
    if ~isfield(cfg, 'plot_bp_filter')                  cfg.plot_bp_filter = 'no'; end
    if ~isfield(cfg, 'betweenSov_cond_forSigLine')      cfg.betweenSov_cond_forSigLine = {}; end
    if ~isfield(cfg, 'withinSov_contrast_forSigLine')   cfg.withinSov_contrast_forSigLine = {}; end
    if ~isfield(cfg, 'plot_bp_filter')                  cfg.plot_bp_filter = 'no'; end
    if ~isfield(cfg, 'ylim_')                           cfg.ylim_ =  [-1.2 2]; end
    if ~isfield(cfg, 'sov_group_name')                  cfg.sov_group_name = 'multi'; end

    
    bottom_string = "";

    sovs_colormap = get_colormap(sovs,{cond},'sov'); 
    
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
            sovs_string = cfg.sov_group_name;
        else
            sovs_string = sovs{1}.short_s;
        end
        curr_output_filename = sprintf('%s\\ERP_sov-%s_cond-%s_clust-%s',out_dir,sovs_string,cond.short_s,clust_name);
        if isfile(sprintf("%s.fig",curr_output_filename)) continue; end

        % get avg data to plot
        allSubs_sovs_AvgActivity = zeros(size(subs,2),size(epoch_time,2),numel(sovs)); 
        
        trials_stats_string = "";
        for sov_i=1:numel(sovs)
            trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, cond.short_s, sovs{sov_i}.short_s);
            curr_cond_timelock = get_cond_timelocked(subs,cond,sovs{sov_i},dirs.ft_cond_input,dirs.ft_cond_output);
            sub_trials_count = [];
            for sub_i = 1:numel(subs)
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

        if isfield(cfg, 'plot_each_sub_comp_latency')
            components = cfg.plot_each_sub_comp_latency;
            [~, cfg.plot_each_sub_comp_latency, metadata] = create_component_amplitude_table(subs, sovs, components, {cond}, elctrds_clusts.(fields_elctrds_clusts{ctp_i}), dirs, epoch_time);
            metadata_comp_string = metadata.metadata_comp_string;
            bottom_string = sprintf("%s%s\n",bottom_string,metadata_comp_string);
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
                stat = cluster_permu_erp(subs,{cfg.betweenSov_cond_forSigLine,cfg.betweenSov_cond_forSigLine},sovs_pairs{sp_i},clust_electd,cfg.test_latency,dirs);
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
        plot_erps(epoch_time, sovs,allSubs_sovs_AvgActivity, curr_output_filename, sovs_colormap, cfg)
    end
end
