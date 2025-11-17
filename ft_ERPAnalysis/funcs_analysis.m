classdef funcs_analysis
    properties (SetAccess = private)
        imp
        electrodes
        label
        time
    end
    methods(Static)
        % constructor
        function fa = funcs_analysis(imp, label,electrodes, time)
            fa.imp = imp;
            fa.electrodes = electrodes;
            fa.label = label;
            fa.time = time;
        end

        % get/set
        function s = get_imp(fa)
            s = fa.imp;
        end
        function s = get_electrodes(fa)
            s = fa.electrodes;
        end
        function s = get_label(fa)
            s = fa.label;
        end
        function s = get_time(fa)
            s = fa.time;
        end

        function resultTable = get_fdrcorrected_component_succesiveConds(fa,sovs,conds,comps,elect_label)
            condSovPairs = {};
            for sov_i=1:numel(sovs)
                for cond_i=1:numel(conds)
                    condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}}; 
                end
            end
            
            [comp_data,~] = fa.get_comp_plot(fa, sovs, fa.imp.subs,conds, comps,elect_label);
            
            subs_AvgActivity = zeros(size(fa.imp.subs,2),numel(comps),numel(condSovPairs)); 
            for comp_i=1:numel(comps)
                for csp_i=1:numel(condSovPairs)
                    for sub_i = 1:size(fa.imp.subs,2)
                        curr = comp_data.(comps{comp_i}.short_s).(condSovPairs{csp_i}{2}.short_s).(condSovPairs{csp_i}{1}.short_s).(sprintf("s_%s",fa.imp.subs{sub_i}));
                        subs_AvgActivity(sub_i,comp_i,csp_i) =curr.('amplitude');
                    end
                end
            end
            
            resultTable = table([], [], [], [], 'VariableNames', {'Comp', 'Sov', 'CondContrast', 'Pval'});
            for comp_i=1:numel(comps)
                for csp_i=2:numel(condSovPairs)
                    if strcmp(condSovPairs{csp_i-1}{2}.short_s,condSovPairs{csp_i}{2}.short_s)
                        [curr_pval,~,~] = signrank(subs_AvgActivity(:,comp_i,csp_i-1) - subs_AvgActivity(:,comp_i,csp_i));
                        condContrastString = sprintf("%s_%s",condSovPairs{csp_i-1}{1}.short_s,condSovPairs{csp_i}{1}.short_s);
                        newRow = {comps{comp_i}.short_s, condSovPairs{csp_i}{2}.short_s, condContrastString, curr_pval};
                        resultTable = [resultTable; newRow];
                    end
                end
            end
            fdr_corrected_pvals = mafdr( resultTable.Pval, 'BHFDR', true);
            resultTable.Pval_fdrCorrected = fdr_corrected_pvals;
            resultTable.CorrectedAboveThreshold = (resultTable.Pval < 0.05) & (fdr_corrected_pvals >= 0.05);
            resultTable.CorrectedAboveThreshold = double(resultTable.CorrectedAboveThreshold);
            resultTable.sigAfterCorrection = double(fdr_corrected_pvals < 0.05);
        end
      
        function electd_clusts=get_electdClust_tfrband(fa,clust_dir,conds,sovs,band_string,maxPval)
            electd_clusts = struct();
            try
                clusters_res = load(sprintf("%s\\STCP-TFR_conds-%s+%s_condsSovs-%s+%s_freq-%s_subAvg", ...
                    clust_dir,conds{1}.short_s,conds{2}.short_s,sovs{1}.short_s,sovs{2}.short_s,band_string));
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
        end
        
        % unionWithinFrontBack_intersectBetweenSovs: 
        % In this function I assume that the positive and negative cluster
        % in REM are oposite in thire location in other sovs
        % conds is a contrast. E.g. {intblkMid, Omi}
        % sovs are not of a contrast. The contrasnt is always within the same sov, but then there is an intersection between the clusters in each sov
        function electd_clusts=get_electdClust(fa,type,clust_dir,conds,sovs,maxPval)
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
                    curr_sov_electd_clusts=fa.get_electdClust(fa,'simple_contrast',clust_dir,conds,{sovs{sov_i},sovs{sov_i}});

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
                    % clust.('elect_label') = ADD!
                    electd_clusts.('back') = clust;
                end
                if ~isempty(front_elct_clust)
                    clust = struct();
                    clust.('short_s') =  sprintf("%s+%s-%s-front",conds{1}.short_s,conds{2}.short_s,sovs_string);
                    clust.('long_s') =  sprintf("%s+%s-%s-front",conds{1}.long_s,conds{2}.long_s,sovs_string);
                    % clust.('elect_label') = ADD!
                    electd_clusts.('front') = clust;
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%% TFR: spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function run_STCP_TFR_dependent(fa,output_dir, tfr_algo, contrast_conds,contrast_sovs,test_latency,test_freqrange,is_bl_in_band)
            cond1 = contrast_conds{1};
            cond2 = contrast_conds{2};
            sov_cond1 = contrast_sovs{1};
            sov_cond2 = contrast_sovs{2};

            curr_output_filename = sprintf("%s\\STCP-TFR_conds-%s+%s_condsSovs-%s+%s_freq-%.1f-%.1f_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s,test_freqrange(1),test_freqrange(2));
            if isfile(curr_output_filename) return; end

            if strcmp(tfr_algo,'multitaper')
                tfrFt_cond1 = fa.imp.get_cond_TFR_mt(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_mt(fa.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'multitaper_zscored')
                tfrFt_cond1 = fa.imp.get_cond_TFR_mt_zscored(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_mt_zscored(fa.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'hilbert')
                tfrFt_cond1 = fa.imp.get_cond_TFR_hilbert(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_hilbert(fa.imp,cond2,sov_cond2);
            else
                error('no such tfr algo implemented')
            end
            
            subs = fa.imp.get_subs(fa.imp);
            neighbours = fa.imp.get_neighbours(fa.imp);
            res = {};
            if is_bl_in_band
                cond1_struct_baselined = {};
                cond2_struct_baselined = {};
                for i=1:numel(tfrFt_cond1)
                    cfg = [];
                    cfg.frequency = test_freqrange;
                    cond1_curr = ft_freqdescriptives(cfg, tfrFt_cond1{i});
                    cond2_curr = ft_freqdescriptives(cfg, tfrFt_cond2{i});
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
                cond1_struct = tfrFt_cond1;
                cond2_struct = tfrFt_cond2;
            end

            cfg = [];
            cfg.latency          =test_latency;
            cfg.frequency        = test_freqrange;
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
            res.stat =  stat;
            save(curr_output_filename, "res")
        end

        function run_STCP_TFRMAP_dependent(fa,output_dir, tfr_algo,contrast_conds,contrast_sovs,test_latency,test_freqrange,clusts_struct)
            cond1 = contrast_conds{1};
            cond2 = contrast_conds{2};
            sov_cond1 = contrast_sovs{1};
            sov_cond2 = contrast_sovs{2};

            if strcmp(tfr_algo,'multitaper')
                tfrFt_cond1 = fa.imp.get_cond_TFR_mt(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_mt(fa.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'multitaper_zscored')
                tfrFt_cond1 = fa.imp.get_cond_TFR_mt_zscored(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_mt_zscored(fa.imp,cond2,sov_cond2);
            elseif strcmp(tfr_algo,'hilbert')
                tfrFt_cond1 = fa.imp.get_cond_TFR_hilbert(fa.imp,cond1,sov_cond1);
                tfrFt_cond2 = fa.imp.get_cond_TFR_hilbert(fa.imp,cond2,sov_cond2);
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
                    sov_cond2.short_s,test_freqrange(1),test_freqrange(2), ...
                    clust_i.short_s);
                if isfile(curr_output_filename) continue; end

                subs = fa.imp.get_subs(fa.imp);
                res = {};
    
                [~, elec_ind] = ismember(clust_struct.('elect_label'), tfrFt_cond1{1}.('label'));
                powspctrm_diff_avg = zeros([numel(elec_ind), size(tfrFt_cond1{1}.powspctrm,[2,3])]);
                powspctrm_cond1_avg = zeros([numel(elec_ind), size(tfrFt_cond1{1}.powspctrm,[2,3])]);
                powspctrm_cond2_avg = zeros([numel(elec_ind), size(tfrFt_cond1{1}.powspctrm,[2,3])]);
                for i=1:numel(tfrFt_cond1)
                    powspctrm_cond1_avg = powspctrm_cond1_avg + tfrFt_cond1{i}.powspctrm(elec_ind,:,:);
                    powspctrm_cond2_avg = powspctrm_cond2_avg + tfrFt_cond2{i}.powspctrm(elec_ind,:,:);
                    curr_diff = tfrFt_cond1{i}.powspctrm(elec_ind,:,:) - tfrFt_cond2{i}.powspctrm(elec_ind,:,:);
                    powspctrm_diff_avg= powspctrm_diff_avg + (curr_diff);
                end
                powspctrm_diff_avg = powspctrm_diff_avg/ numel(tfrFt_cond1);
    
                cfg = [];
                cfg.channel          = clust_i.('elect_label');
                cfg.latency          = test_latency;
                cfg.frequency        = test_freqrange;
                cfg.method           = 'montecarlo';
                cfg.statistic        = 'depsamplesT';
                cfg.clusteralpha     = 0.05;
                cfg.clusterstatistic = 'maxsum';
                cfg.tail             = 0;
                cfg.clustertail      = 0;
                cfg.alpha            = 0.025;
                cfg.neighbours       = fa.imp.get_neighbours(fa.imp);
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
                
                [stat] = ft_freqstatistics(cfg, tfrFt_cond1{:}, tfrFt_cond2{:});
                res.stat = stat;
    
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

                save(curr_output_filename, "res")
            end
        end

        %%%%%%%%%%%%%%%%%%%% ERP: spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Electrods Cluster between conditions. per timepoint all subjects
        function run_STCP_ERP_dependent(fa,output_dir, cond1,cond2,sov_cond1,sov_cond2, cfg)
            if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, fa.time(end)]; end

            curr_output_filename = sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
            if isfile(curr_output_filename) return; end

            timelockft_cond1 = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond1,sov_cond1);
            timelockft_cond2 = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond2,sov_cond2);
            
            subs = fa.imp.get_subs(fa.imp);
            neighbours = fa.imp.get_neighbours(fa.imp);

            res = {};
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
            stat_cfg.minnbchan        = 0;      % minimal number of neighbouring channels
            
            stat_cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            stat_cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            stat_cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            stat_cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            
            stat = ft_timelockstatistics(stat_cfg,timelockft_cond1{:}, timelockft_cond2{:});
            stat.cfg = rmfield(stat.cfg, "previous");

            curr_cfg = [];
            curr_cfg.channel   = 'all';
            curr_cfg.parameter = 'avg';
            gradavg_cond1        = ft_timelockgrandaverage(curr_cfg, timelockft_cond1{:});
            gradavg_cond2         = ft_timelockgrandaverage(curr_cfg, timelockft_cond2{:});
            curr_cfg = [];
            curr_cfg.operation = 'subtract';
            curr_cfg.parameter = 'avg';
            subt_conds12    = ft_math(curr_cfg, gradavg_cond1, gradavg_cond2);
            subt_conds12.elec = timelockft_cond1{1}.elec;

            timeind = find(subt_conds12.time>= cfg.test_latency(1) & subt_conds12.time<=cfg.test_latency(end)+1e-4);
            res.subt_conds12 = subt_conds12.avg(:,timeind(1):timeind(end));
            res.stat =  stat;
            res.stat_cfg = stat_cfg;
            save(curr_output_filename, "res")
        end
    
        function run_STCP_ERP_independent(fa,output_dir,cond1,cond2,sov_cond1,sov_cond2, cfg)
            if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, fa.time(end)]; end

            curr_output_filename = sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
            if isfile(curr_output_filename) return; end

            timelockft_cond1 = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond1,sov_cond1);
            timelockft_cond2 = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond2,sov_cond2);
            
            neighbours = fa.imp.get_neighbours(fa.imp);
            res = {};
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
            [stat] = ft_timelockstatistics(cfg, timelockft_cond1, timelockft_cond2);
            
            res.stat =  stat;
            res.stat_cfg = cfg;
            save(curr_output_filename, "res")
        end
    
        function run_TCP_ERP(fa,cond1,cond2,sov_cond1,sov_cond2,clust_electdLabel,latency)
            curr_output_filename = sprintf("%s\\TCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg.mat", ...
                output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
            if isfile(curr_output_filename) return; end

           subs = fa.imp.get_subs(fa.imp);
            
           %%% TODO: the next part is terribly written
            all_conds_timelocked_currClustElecd = cell(1, 2);
            curr_cond_timelock = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond1,sov_cond1); 
            for sub_i = 1:size(subs,2)
                curr_subcond = curr_cond_timelock{sub_i};
                all_conds_timelocked_currClustElecd{1}{sub_i} = curr_subcond;
            end
            curr_cond_timelock = fa.imp.get_cond_timelocked(fa.imp,fa.imp.subs,cond2,sov_cond2); 
            for sub_i = 1:size(subs,2)
                curr_subcond = curr_cond_timelock{sub_i};
                all_conds_timelocked_currClustElecd{2}{sub_i} = curr_subcond;
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

            res.stat =  stat;
            res.stat_cfg = stat_cfg;
            save(curr_output_filename, "res")
        end

        function [new_comps,metadata_string] = run_ERP_comp(fa, sovs, subs,conds, comp2plot,clust_electdLabel)
            samples_around_extre = 0;
            metadata_string = '';

            % find min time
            new_comps = {};
            for comp_i = 1:numel(comp2plot)
                curr_comp = comp2plot{comp_i};
                for sov_i=1:numel(sovs)       
                    for sub_i = 1:numel(subs)
                        for cond_i = 1:numel(conds)
                            curr_compSubSovCond = {};
                            curr_cond_timelocked = fa.imp.get_cond_timelocked(fa.imp,{subs{sub_i}},conds{cond_i},sovs{sov_i}); 
                            curr_cond_timelocked = curr_cond_timelocked{1};
                            curr_compSubSovCond.('trials_timelocked_avg') = curr_cond_timelocked.cfg.trials_timelocked_avg;

                            currcfg = [];
                            currcfg.channel = clust_electdLabel;
                            currcfg.avgoverchan = 'yes';
                            curr_cond_timelocked = ft_selectdata(currcfg, curr_cond_timelocked);
                            curr_sovSubCond_trialMean = mean(curr_cond_timelocked.avg,1);

                            
                            comp_time_idx = fa.imp.epoch_time >= curr_comp.latency(1) & fa.imp.epoch_time <= curr_comp.latency(2);
                            time_idxes = 1:numel(fa.imp.epoch_time);
                            comp_time_idx = time_idxes(comp_time_idx);
    
                             cols = funcs_.create_custom_colormap(sovs{sov_i}.color, 2);
                             curr_compSubSovCond.('color') = cols(2,:);
                        
                            is_peak = true;
                            if curr_comp.isPositive
                                [~, extreme_idx] = findpeaks(squeeze(curr_sovSubCond_trialMean(comp_time_idx)),'NPeaks', 1, 'SortStr', 'descend');
                                if isempty(extreme_idx)
                                    is_peak = false;
                                    [~, extreme_idx] = max(curr_sovSubCond_trialMean(comp_time_idx));
                                end
                            else
                                [~,extreme_idx] = findpeaks(-squeeze(curr_sovSubCond_trialMean(comp_time_idx)),'NPeaks', 1, 'SortStr', 'descend');
                                if isempty(extreme_idx)
                                    is_peak = false;
                                    [~, extreme_idx] = min(curr_sovSubCond_trialMean(comp_time_idx));
                                end
                            end
                            if ~is_peak
                                if numel(metadata_string) ==0
                                    metadata_string = char(sprintf('___Missing peaks-troughs___\n'));
                                end
                                sss = sprintf('Sub:%s, Sov:%s, Cond:%s, Comp:%s',subs{sub_i},sovs{sov_i}.short_s,conds{cond_i}.short_s,curr_comp.short_s);
                                metadata_string = char(metadata_string);
                                sss = char(sss); 
                                if ~contains(metadata_string, sss)
                                    metadata_string = char(sprintf('%s%s\n',metadata_string,sss));
                                end
                                curr_compSubSovCond.('color') = [0,0,0];
                            end
                            
                            curr_compSubSovCond.('latency') = fa.imp.epoch_time(extreme_idx+ comp_time_idx(1)-1);
                            
                            tolerance = 1e-6;
                            ind_time_to_avg_around = find(abs(curr_cond_timelocked.time - curr_compSubSovCond.('latency')) < tolerance);
                            curr_compSubSovCond.('amplitude') = mean(curr_cond_timelocked.avg(ind_time_to_avg_around-samples_around_extre :ind_time_to_avg_around+samples_around_extre));


                            new_comps.(comp2plot{comp_i}.short_s).(sovs{sov_i}.short_s).(conds{cond_i}.short_s).(sprintf('s_%s',subs{sub_i})) = curr_compSubSovCond;
                        end
                    end
                end
            end
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


