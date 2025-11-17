function metadata_comp_string = plot_violin_comp_condSovPairs(epoch_time, subs, dirs,out_dir, condSovPairs, elctrds_clusts, component ,plot_name,cfg)
    if ~isfield(cfg, 'ylim_')                       cfg.ylim_ = [-5 5]; end
    if ~isfield(cfg, 'is_remove_no_peak_outliers')  cfg.is_remove_no_peak_outliers = 0; end

    metadata_comp_string = "";
    % get colormap
    conds = cell(1, numel(condSovPairs));
    conds_sovs = cell(1, numel(condSovPairs));
    for i = 1:numel(condSovPairs)
        conds{i} = condSovPairs{i}{1}; % Extract the cond struct
        conds_sovs{i} = condSovPairs{i}{2};  % Extract the sov struct
    end
    curr_colormap = get_colormap(conds_sovs,conds,'sov'); 
    
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
        
        curr_output_filename = sprintf('%s\\Comp-%s_name-%s_clust-%s',out_dir,component.short_s,plot_name,clust_name);
        if isfile(sprintf("%s.fig",curr_output_filename)) continue; end

        % get avg data to plot
        [~, comps_struct, metadata] = create_component_amplitude_table(subs, conds_sovs,{component} , conds, elctrds_clusts.(fields_elctrds_clusts{ctp_i}), dirs, epoch_time);
        metadata_comp_string = metadata.metadata_comp_string;
        trials_stats_string = "";
        no_peak_outliers_count = 0;
        subs_AvgActivity = zeros(size(subs,2),numel(condSovPairs)); 
        for csp_i=1:numel(condSovPairs)
            trials_stats_string = sprintf("%scond: %s, sov:%s _ ",trials_stats_string, condSovPairs{csp_i}{1}.short_s,condSovPairs{csp_i}{2}.short_s);
            sub_trials_count = zeros(1,(numel(subs)));
            for sub_i = 1:size(subs,2)
                curr = comps_struct.(component.short_s).(condSovPairs{csp_i}{2}.short_s).(condSovPairs{csp_i}{1}.short_s).(sprintf("s_%s",subs{sub_i}));
                if curr.is_peak || ~cfg.is_remove_no_peak_outliers
                    sub_trials_count(sub_i) = curr.('trials_timelocked_avg');
                    subs_AvgActivity(sub_i,csp_i) =curr.('amplitude');
                else
                    sub_trials_count(sub_i) = NaN;
                    subs_AvgActivity(sub_i,csp_i) = NaN;
                    no_peak_outliers_count = no_peak_outliers_count+1;
                end
            end
            trials_stats_string = sprintf("%s Avg:%.1f Std:%.1f Min:%d Max:%d \n",trials_stats_string, nanmean(sub_trials_count), nanstd(sub_trials_count), nanmin(sub_trials_count),nanmax(sub_trials_count));
        end

        if cfg.is_remove_no_peak_outliers
            trials_stats_string = sprintf("%s, removed %d no peak outliers\n",trials_stats_string,no_peak_outliers_count);
        end
        
        condSovPairsStrings = {};
        for pairs_i = 1:numel(condSovPairs)
            condSovPairsStrings{end +1} = sprintf('%s',condSovPairs{pairs_i}{1}.long_s);
        end

        cfg.parametric_stats = struct();
        cfg.wilcoxon_stats = struct();
        for sc_i = 2:numel(condSovPairs)
           % Get the paired data
           data1 = subs_AvgActivity(:,sc_i-1);
           data2 = subs_AvgActivity(:,sc_i);
           
           % Remove NaN pairs
           valid_idx = ~isnan(data1) & ~isnan(data2);
           data1_clean = data1(valid_idx);
           data2_clean = data2(valid_idx);
           n_valid = sum(valid_idx);
        
           % Wilcoxon test
           [p, h, stats] = signrank(data1_clean - data2_clean);
           cfg.wilcoxon_stats(sc_i-1).p = p;
           cfg.wilcoxon_stats(sc_i-1).W = stats.signedrank;
           cfg.wilcoxon_stats(sc_i-1).z = stats.zval;
           cfg.wilcoxon_stats(sc_i-1).N = n_valid;
           cfg.wilcoxon_stats(sc_i-1).r = abs(stats.zval)/sqrt(n_valid);
           cfg.wilcoxon_stats(sc_i-1).mdn1 = median(data1_clean);
           cfg.wilcoxon_stats(sc_i-1).mdn2 = median(data2_clean);
           cfg.wilcoxon_stats(sc_i-1).iqr1 = [prctile(data1_clean, 25),prctile(data1_clean, 75)];
           cfg.wilcoxon_stats(sc_i-1).iqr2 = [prctile(data2_clean, 25),prctile(data2_clean, 75)];
           cfg.wilcoxon_stats(sc_i-1).sovcond1 = [condSovPairs{sc_i-1}{1}.short_s,'__',condSovPairs{sc_i-1}{2}.short_s];
           cfg.wilcoxon_stats(sc_i-1).sovcond2 =  [condSovPairs{sc_i}{1}.short_s,'__',condSovPairs{sc_i}{2}.short_s];

           % Parametric tests
           [h, p_t, ci, t_stats] = ttest(data1_clean, data2_clean);
           d = computeCohensD(data1_clean, data2_clean);
           cfg.parametric_stats(sc_i-1).p = p_t;
           cfg.parametric_stats(sc_i-1).t = t_stats.tstat;
           cfg.parametric_stats(sc_i-1).df = t_stats.df;
           cfg.parametric_stats(sc_i-1).cohensD = d;
           cfg.parametric_stats(sc_i-1).ci = ci;
           cfg.parametric_stats(sc_i-1).mean1 = mean(data1_clean);
           cfg.parametric_stats(sc_i-1).mean2 = mean(data2_clean);
           cfg.parametric_stats(sc_i-1).sd1 = std(data1_clean);
           cfg.parametric_stats(sc_i-1).sd2 = std(data2_clean);
           cfg.parametric_stats(sc_i-1).N = n_valid;
           cfg.parametric_stats(sc_i-1).sovcond1 = [condSovPairs{sc_i-1}{1}.short_s,'__',condSovPairs{sc_i-1}{2}.short_s];
           cfg.parametric_stats(sc_i-1).sovcond2 =  [condSovPairs{sc_i}{1}.short_s,'__',condSovPairs{sc_i}{2}.short_s];
           [h_norm, p_norm] = lillietest(data1_clean - data2_clean);
           cfg.parametric_stats(sc_i-1).normality_p = p_norm;
           [bf10, ~] = bf.ttest(data1_clean - data2_clean);
           cfg.parametric_stats(sc_i-1).BF10 = bf10;
        end
        cfg.wilcoxon_report = arrayfun(@(x) sprintf('w=%.1f, p=%.3f, r=%.2f, n=%d', ...
            x.W, x.p, x.r, x.N), cfg.wilcoxon_stats, 'UniformOutput', false);
        cfg.parametric_report = arrayfun(@(x) sprintf('NormP=%.2f, t(%d)=%.2f, p=%.3f, bf10=%.2f, d=%.2f, n=%d', ...
           x.normality_p, x.df, x.t, x.p, x.BF10, x.cohensD, x.N), cfg.parametric_stats, 'UniformOutput', false);

        cfg.data_stats =struct();
        for sc_i = 1:numel(condSovPairs)
            cfg.data_stats(sc_i).sov = condSovPairs{sc_i}{2}.short_s;
            cfg.data_stats(sc_i).cond = condSovPairs{sc_i}{1}.short_s;
            cfg.data_stats(sc_i).mdn1 = nanmedian(subs_AvgActivity(:,sc_i));
            cfg.data_stats(sc_i).iqr1 = iqr(subs_AvgActivity(:,sc_i));
            cfg.data_stats(sc_i).n = sum(~isnan(subs_AvgActivity(:,sc_i)));
            cfg.data_stats(sc_i).q1_1 = prctile(subs_AvgActivity(:,sc_i), 25);
            cfg.data_stats(sc_i).q3_1 = prctile(subs_AvgActivity(:,sc_i), 75);
        end

        cfg.bfstats =struct();
        [bf10, ~] = bf.ttest(data1_clean, data2_clean);
        cfg.parametric_stats(sc_i-1).BF10 = bf10;
        
        cfg.descriptive_report = arrayfun(@(x) sprintf('%s,%s: Mdn=%.2f, IQR:%.2f-%.2f, n=%d',x.sov,x.cond,x.mdn1, x.q1_1, x.q3_1,x.n), cfg.data_stats, 'UniformOutput', false);
        
        cfg.title_ = sprintf('ERP, %s, %d subjects', plot_name,size(subs,2)); 
        cfg.subtitle_ = sprintf("Elect Clust: %s. Pval=%.2f", clust_name ,clust_pval);
        cfg.elctrds_clusts = {elctrds_clusts.('elec_gen_info'),clust_electdLabel};
        cfg.bottom_string =sprintf("%s\n%s",trials_stats_string,metadata_comp_string);

        plot_violins(condSovPairsStrings,subs_AvgActivity,curr_output_filename, curr_colormap,subs,cfg)
    end
end
