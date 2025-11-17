function metadata = TFCP_TFRMAP_dependentT(subs,cond1_struct, cond2_struct,test_latency,freqrange_test,clust_struct,neighbours,plot_timerange)
    metadata = {};
    cfg_test = [];
    cfg_test.channel = clust_struct.('elect_label');
    cfg_test.avgoverchan = 'yes';
    cfg_test.latency = test_latency;
    cfg_test.frequency = freqrange_test;
    cfg_test.method = 'montecarlo';
    cfg_test.statistic = 'depsamplesT';
    cfg_test.clusteralpha = 0.05;
    cfg_test.clusterstatistic = 'maxsum';
    cfg_test.tail = 0; % two-sided test
    cfg_test.clustertail = 0;
    cfg_test.alpha = 0.05;
    cfg_test.correcttail = 'prob'; %https://www.fieldtriptoolbox.org/faq/why_should_i_use_the_cfg.correcttail_option_when_using_statistics_montecarlo/
    cfg_test.neighbours = neighbours;
    cfg_test.correctm = 'cluster';
    cfg_test.numrandomization = 1000;
    cfg_test.previous = 'no';
    subj_num = numel(subs);
    design = zeros(2,2*subj_num);
    if isfield(cond1_struct{1},"powspctrm_zscore")
        cfg_test.parameter = 'powspctrm_zscore';
    else
        cfg_test.parameter = 'powspctrm';
    end
    for i = 1:subj_num
        design(1,i) = i;
    end
    for i = 1:subj_num
        design(1,subj_num+i) = i;
    end
    design(2,1:subj_num) = 1;
    design(2,subj_num+1:2*subj_num) = 2;
    cfg_test.design = design;
    cfg_test.uvar = 1;
    cfg_test.ivar = 2;
    [stat] = ft_freqstatistics(cfg_test, cond1_struct{:}, cond2_struct{:});
    
    % Calculate Cohen's d for clusters
    cohensd_cfg = [];
    cohensd_cfg.keepindividual = 'yes';
    cohensd_cfg.channel = clust_struct.('elect_label');
    cohensd_cfg.foilim = freqrange_test;
    cohensd_cfg.previous = 'no';
    if isfield(cond1_struct{1},"powspctrm_zscore")
        cohensd_cfg.parameter = 'powspctrm_zscore';
    else
        cohensd_cfg.parameter = 'powspctrm';
    end
    grandavg_1 = ft_freqgrandaverage(cohensd_cfg, cond1_struct{:});
    grandavg_2 = ft_freqgrandaverage(cohensd_cfg, cond2_struct{:});
    
    negpos_arr = {['pos'],['neg']};
    for negpos_i=1:numel(negpos_arr)
        negpos = negpos_arr{negpos_i};
        if isfield(stat, [negpos 'clusters']) && ~isempty(stat.([negpos 'clusters']))
            
            for clust_idx = 1:length(stat.([negpos 'clusters']))
                temp_mask = squeeze(stat.([negpos 'clusterslabelmat']));  % Remove singleton dimension
                [freq_indices, time_indices] = find(temp_mask  == clust_idx);

                if isempty(freq_indices) || isempty(time_indices)
                    continue;
                end
                % Get ranges
                freq_range = [min(stat.freq(freq_indices)), max(stat.freq(freq_indices))];
                time_range = [min(stat.time(time_indices)), max(stat.time(time_indices))];
                stat.([negpos 'clusters'])(clust_idx).clust_freqRange = freq_range;
                stat.([negpos 'clusters'])(clust_idx).clust_timeRange = time_range;
                stat.([negpos 'clusters'])(clust_idx).clust_elec =  clust_struct.('elect_label');

                clusts_prob = [stat.([negpos 'clusters']).prob];
                if clusts_prob(clust_idx) > 0.1
                    continue;
                end

                % Calculate mean Cohen's d across the cluster
                cohensd_cfg = [];
                cohensd_cfg.latency = [time_range(1), time_range(2)];
                cohensd_cfg.frequency = [freq_range(1), freq_range(2)];
                cohensd_cfg.avgoverchan = 'yes';  
                cohensd_cfg.avgoverfreq = 'yes';
                cohensd_cfg.avgovertime = 'yes'; 
                cohensd_cfg.parameter = 'powspctrm_zscore';
                grandavg_inclust_1 = ft_selectdata(cohensd_cfg, grandavg_1);
                grandavg_inclust_2 = ft_selectdata(cohensd_cfg, grandavg_2);
                
                cohensd_stat_cfg = [];
                cohensd_stat_cfg.method = 'analytic';
                cohensd_stat_cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
                cohensd_stat_cfg.ivar = 1;
                cohensd_stat_cfg.uvar = 2;
                cohensd_stat_cfg.design(1,1:2*subj_num) = [ones(1,subj_num) 2*ones(1,subj_num)];
                cohensd_stat_cfg.design(2,1:2*subj_num) = [1:subj_num 1:subj_num];
                cohensd_stat_cfg.parameter = 'powspctrm_zscore';
                effect_roi = ft_freqstatistics(cohensd_stat_cfg, grandavg_inclust_1, grandavg_inclust_2);
                stat.([negpos 'clusters'])(clust_idx).cohensd_mean = effect_roi.cohensd;

                % Calculate max/min Cohen's d within the cluster
                cohensd_cfg = [];
                cohensd_cfg.latency = [time_range(1), time_range(2)];
                cohensd_cfg.frequency = [freq_range(1), freq_range(2)];
                cohensd_cfg.avgoverchan = 'yes';   
                cohensd_cfg.avgoverfreq = 'no';
                cohensd_cfg.avgovertime = 'no';  
                grandavg_inclust_1 = ft_selectdata(cohensd_cfg, grandavg_1);
                grandavg_inclust_2 = ft_selectdata(cohensd_cfg, grandavg_2);
                effect_all = ft_freqstatistics(cohensd_stat_cfg, grandavg_inclust_1, grandavg_inclust_2);
                if strcmp(negpos,'pos')
                    [m, ind] = max(effect_all.cohensd(:));
                else
                    [m, ind] = min(effect_all.cohensd(:));
                end
                [i, j, k] = ind2sub(size(effect_all.cohensd), ind);
                stat.([negpos 'clusters'])(clust_idx).cohensd_extremumVal = effect_all.cohensd(i,j,k);
                stat.([negpos 'clusters'])(clust_idx).cohensd_extremumFreq = effect_all.freq(j);
                stat.([negpos 'clusters'])(clust_idx).cohensd_extremumTime = effect_all.time(k);
            end
        end
    end
    


    cfg_avg = [];
    cfg_avg.channel = clust_struct.('elect_label');
    cfg_avg.keepindividual = 'no';
    cfg_avg.foilim = freqrange_test;
    cfg_avg.previous = 'no';
    if isfield(cond1_struct{1},"powspctrm_zscore")
        cfg_avg.parameter = 'powspctrm_zscore';
    else
        cfg_avg.parameter = 'powspctrm';
    end
    [grandavg_cond1] = ft_freqgrandaverage(cfg_avg, cond1_struct{:});
    [grandavg_cond2] = ft_freqgrandaverage(cfg_avg, cond2_struct{:});
    metadata.grandavg_cond1 = grandavg_cond1;
    metadata.grandavg_cond2 = grandavg_cond2;


    metadata.stat = stat;
    metadata.stat_cfg = cfg_test;
    metadata.sub_num = subj_num;
    metadata.cfg_avg_parameter= cfg_avg.parameter;
    metadata.test_latency = test_latency;
    metadata.plot_timerange = plot_timerange;
    metadata.clust_struct = clust_struct;
end