
function stat = cluster_permu_erp(subs, conds,sovs,clust_electdLabel,latency,dirs)
    all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
    for cond_sov_j = 1:size(conds,2)
        curr_cond_timelock = get_cond_timelocked(subs,conds{cond_sov_j},sovs{cond_sov_j},dirs.ft_cond_input,dirs.ft_cond_output); 
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
    cfg.previous = 'no';
    Nsub = size(subs,2);
    cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
    cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
    cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
    cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
    stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{1}{:}, all_conds_timelocked_currClustElecd{2}{:});   % don't forget the {:}!

    cfg = [];
    cfg.keepindividual = 'yes';
    grandavg_1 = ft_timelockgrandaverage(cfg, all_conds_timelocked_currClustElecd{1}{:});
    grandavg_2  = ft_timelockgrandaverage(cfg, all_conds_timelocked_currClustElecd{2}{:});
    negpos_arr = {['pos'],['neg']};
    for negpos_i=1:numel(negpos_arr)
        negpos = negpos_arr{negpos_i};
        if isfield(stat, [negpos 'clusters']) && ~isempty(stat.([negpos 'clusters']))
            for clust_idx = 1:length(stat.([negpos 'clusters']))
                cluster_mask = stat.([negpos 'clusterslabelmat']) == clust_idx;
                time_idx = find(any(cluster_mask, 1));
                time_range = stat.time(time_idx);

                % get avg cohens d
                cfg = [];
                cfg.channel = clust_electdLabel;
                cfg.latency = [time_range(1),time_range(end)];
                cfg.avgoverchan = 'yes';  
                cfg.avgovertime = 'yes'; 
                grandavg_inclust_1 = ft_selectdata(cfg, grandavg_1);
                grandavg_inclust_2  = ft_selectdata(cfg, grandavg_2);
                cfg = [];
                cfg.method = 'analytic';
                cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
                cfg.ivar = 1;
                cfg.uvar = 2;
                cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
                cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
                effect_roi = ft_timelockstatistics(cfg, grandavg_inclust_1, grandavg_inclust_2);
                stat.([negpos 'clusters'])(clust_idx).cohensd_mean = effect_roi.cohensd;

                % get max/min cohens d
                cfg = [];
                cfg.channel = clust_electdLabel;
                cfg.latency = [time_range(1),time_range(end)];
                cfg.avgoverchan = 'yes';   
                cfg.avgovertime = 'no';  
                grandavg_inclust_1 = ft_selectdata(cfg, grandavg_1);
                grandavg_inclust_2  = ft_selectdata(cfg, grandavg_2);
                cfg = [];
                cfg.parameter = 'individual';
                cfg.method = 'analytic';
                cfg.statistic = 'cohensd'; % see FT_STATFUN_COHENSD
                cfg.ivar = 1;
                cfg.uvar = 2;
                cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
                cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
                effect_all = ft_timelockstatistics(cfg, grandavg_inclust_1, grandavg_inclust_2);
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
end
