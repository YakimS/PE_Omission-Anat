function run_TFCP_TFR_dependent(output_dir, neighbours, subs, contrast_conds,contrast_sovs,timerange_test,freqrange_test,timerange_plot,is_bl_in_band, tfr_algo,dirs)
    cond1 = contrast_conds{1};
    cond2 = contrast_conds{2};
    sov_cond1 = contrast_sovs{1};
    sov_cond2 = contrast_sovs{2};

    curr_output_filename = sprintf("%s\\STCP-TFR_conds-%s+%s_sovs-%s+%s_freq-%.1f-%.1f.mat", ...
        output_dir,cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s,freqrange_test(1),freqrange_test(2));
    if isfile(curr_output_filename) return; end

    tfrFt_cond1 = get_cond_TFR(subs,cond1,sov_cond1,dirs.ft_, tfr_algo);
    tfrFt_cond2 = get_cond_TFR(subs,cond2,sov_cond2,dirs.ft_, tfr_algo);
    
    metadata = TFCP_TFR_dependentT(tfrFt_cond1, tfrFt_cond2,timerange_test,freqrange_test,timerange_plot,curr_output_filename,is_bl_in_band,true,neighbours,subs);
    if ~isempty(metadata)
        metadata = removeLargePrevious(metadata);
        save(curr_output_filename, "metadata", '-v7.3')
    end
end


function metadata = TFCP_TFR_dependentT(cond1_struct_orig, cond2_struct_orig,test_latency,freqrange_test,plot_timerange, mat_filename,is_bl_in_band,is_plot_topoplot,neighbours,subs)
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
    cfg.previous = 'no';
    
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
    cfg.previous = 'no';
    gradavg_cond1        = ft_freqgrandaverage(cfg, cond1_struct{:});
    gradavg_cond2         = ft_freqgrandaverage(cfg, cond2_struct{:});
    cfg = [];
    cfg.operation = 'subtract';
    cfg.parameter = 'powspctrm';
    cfg.previous = 'no';
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
        topo_plot(cfg,subt_conds12);

        if is_cluster_exists
            timediff = ceil(((test_latency(end) - test_latency(1))/16) / rec_fps) * rec_fps;
            toi = test_latency(1): timediff :test_latency(end);
            cfg.toi = toi;
            stat.elec = cond1_struct_orig{i}.elec;
            cfg = rmfield(cfg, 'xlim');
            cluster_plot(stat,cfg); 

            cfg.parameter = 'stat';
            cfg.zlim  = [-5,5];
            cluster_plot(stat,cfg); 

            figures = findall(0, 'Type', 'figure');
            set(figures(1), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
            set(figures(2), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
            set(figures(3), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off');
            
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
%                     saveas(figures(1), sprintf("%s_clust.fig", filename));
%                     saveas(figures(2), sprintf("%s_topo.fig", filename));
%                     saveas(figures(3), sprintf("%s_stat.fig", filename));
        else
            saveas(gcf,sprintf("%s.png",filename));
%                     saveas(gcf,sprintf("%s.fig",filename));
        end

        close 'all';
    end
end
