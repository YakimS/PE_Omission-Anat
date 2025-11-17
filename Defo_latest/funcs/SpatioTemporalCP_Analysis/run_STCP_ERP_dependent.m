function run_STCP_ERP_dependent(subs, output_dir, contrast_conds,contrast_sovs, epoch_time,dirs, neighbours, cfg)
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, epoch_time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [epoch_time(1), epoch_time(end)]; end
    if ~isfield(cfg, 'is_plot_topoplot')    cfg.is_plot_topoplot = true; end
    if ~isfield(cfg, 'is_plot_video')       cfg.is_plot_video = false; end

    cond1 = contrast_conds{1};
    cond2 = contrast_conds{2};
    sov_cond1 = contrast_sovs{1};
    sov_cond2 = contrast_sovs{2};

    curr_output_filename = sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg", ...
        output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);

    curr_output_filename_mat = sprintf("%s.mat",curr_output_filename);
    curr_output_filename_png = sprintf("%s.png",curr_output_filename);

    if isfile(curr_output_filename_png) 
        return;
    elseif isfile(curr_output_filename_mat)
      data_to_plot = load(curr_output_filename_mat);
      data_to_plot = data_to_plot.metadata;
    else
        timelockft_cond1 = get_cond_timelocked(subs, cond1,sov_cond1, dirs.ft_cond_input ,  dirs.ft_cond_output);
        timelockft_cond2 = get_cond_timelocked(subs,cond2,sov_cond2, dirs.ft_cond_input ,  dirs.ft_cond_output);

        data_to_plot = STCP_ERP_dependentT(subs,timelockft_cond1, timelockft_cond2,neighbours, cfg);
        data_to_plot = removeLargePrevious(data_to_plot);
        metadata = data_to_plot;
        save(curr_output_filename_mat, "metadata", '-v7.3')
    end
    plot_STCP_ERP_dependentT(data_to_plot, curr_output_filename)
end

function metadata = STCP_ERP_dependentT(subs, cond1_struct, cond2_struct,neighbours,cfg)
    metadata = {};
    Nsub = size(subs,2);
    stat_cfg.numrandomization = 10000;
    stat_cfg.latency = cfg.test_latency;
    
    stat_cfg.neighbours  = neighbours; % defined as above
    stat_cfg.avgovertime = 'no';
    stat_cfg.parameter   = 'avg';
    stat_cfg.method      = 'montecarlo'; 
    stat_cfg.alpha       = 0.05;
    stat_cfg.tail        = 0; % two-sided test
    stat_cfg.correcttail = 'prob'; % cfg.correcttail = correct p-values or alpha-values when doing a two-sided test, 'alpha','prob' or 'no' (default = 'no')
    stat_cfg.statistic   = 'ft_statfun_depsamplesT';
    stat_cfg.correctm    = 'cluster';
    stat_cfg.minnbchan        = 2;      % minimal number of neighbouring channels
    stat_cfg.previous = 'no';
    
    stat_cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    stat_cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    stat_cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    stat_cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    
    stat = ft_timelockstatistics(stat_cfg,cond1_struct{:}, cond2_struct{:});

    curr_cfg = [];
    curr_cfg.channel   = 'all';
    curr_cfg.parameter = 'avg';
    curr_cfg.previous = 'no';
    gradavg_cond1        = ft_timelockgrandaverage(curr_cfg, cond1_struct{:});
    gradavg_cond2         = ft_timelockgrandaverage(curr_cfg, cond2_struct{:});
    curr_cfg = [];
    curr_cfg.operation = 'subtract';
    curr_cfg.parameter = 'avg';
    curr_cfg.previous = 'no';
    subt_conds12    = ft_math(curr_cfg, gradavg_cond1, gradavg_cond2);

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

    cohensd_cfg = [];
    cohensd_cfg.keepindividual = 'yes';
    grandavg_1 = ft_timelockgrandaverage(cohensd_cfg, cond1_struct{:});
    grandavg_2  = ft_timelockgrandaverage(cohensd_cfg, cond2_struct{:});
    negpos_arr = {['pos'],['neg']};
    for negpos_i=1:numel(negpos_arr)
        negpos = negpos_arr{negpos_i};
        if isfield(stat, [negpos 'clusters']) && ~isempty(stat.([negpos 'clusters']))
            for clust_idx = 1:length(stat.([negpos 'clusters']))
                cluster_mask = stat.([negpos 'clusterslabelmat']) == clust_idx;
                time_idx = find(any(cluster_mask, 1));
                time_range = stat.time(time_idx);
                label_idx = find(any(cluster_mask, 2));
                lables_in_clust = {stat.label{label_idx}};

                % get avg cohens d
                cohensd_cfg = [];
                cohensd_cfg.channel = lables_in_clust;
                cohensd_cfg.latency = [time_range(1),time_range(end)];
                cohensd_cfg.avgoverchan = 'yes';  
                cohensd_cfg.avgovertime = 'yes'; 
                grandavg_inclust_1 = ft_selectdata(cohensd_cfg, grandavg_1);
                grandavg_inclust_2  = ft_selectdata(cohensd_cfg, grandavg_2);
                cohensd_cfg = [];
                cohensd_cfg.method = 'analytic';
                cohensd_cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
                cohensd_cfg.ivar = 1;
                cohensd_cfg.uvar = 2;
                cohensd_cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
                cohensd_cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
                effect_roi = ft_timelockstatistics(cohensd_cfg, grandavg_inclust_1, grandavg_inclust_2);
                stat.([negpos 'clusters'])(clust_idx).cohensd_mean = effect_roi.cohensd;

                % get max/min cohens d
                cohensd_cfg = [];
                cohensd_cfg.channel = lables_in_clust;
                cohensd_cfg.latency = [time_range(1),time_range(end)];
                cohensd_cfg.avgoverchan = 'yes';   
                cohensd_cfg.avgovertime = 'no';  
                grandavg_inclust_1 = ft_selectdata(cohensd_cfg, grandavg_1);
                grandavg_inclust_2  = ft_selectdata(cohensd_cfg, grandavg_2);
                cohensd_cfg = [];
                cohensd_cfg.parameter = 'individual';
                cohensd_cfg.method = 'analytic';
                cohensd_cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
                cohensd_cfg.ivar = 1;
                cohensd_cfg.uvar = 2;
                cohensd_cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
                cohensd_cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
                effect_all = ft_timelockstatistics(cohensd_cfg, grandavg_inclust_1, grandavg_inclust_2);
                if strcmp(negpos,'pos')
                    [m, ind] = max(effect_all.cohensd(:));
                else
                    [m, ind] = min(effect_all.cohensd(:));
                end
                [i, j]   = ind2sub(size(effect_all.cohensd), ind);
                stat.([negpos 'clusters'])(clust_idx).cohensd_maxMin = effect_all.cohensd(i,j);
                stat.([negpos 'clusters'])(clust_idx).cohensd_maxMinElec = effect_all.label{i};
                stat.([negpos 'clusters'])(clust_idx).cohensd_maxMinTime = effect_all.time(j);
            end
        end
    end


    %save(sprintf("%s",mat_filename), '-struct', 'stat');
    metadata.stat =  stat;
    metadata.stat_cfg = stat_cfg;
    metadata.cfg = cfg;
    metadata.subt_conds12 = subt_conds12;
end


