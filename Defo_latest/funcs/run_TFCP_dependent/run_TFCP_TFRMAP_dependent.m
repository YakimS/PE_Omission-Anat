
function run_TFCP_TFRMAP_dependent(subs, output_dir, tfr_algo,contrast_conds,contrast_sovs,timerange_test,freqrange_test,clusts_struct,timerange_plot,neighbours,event_lines,dirs)
    cond1 = contrast_conds{1};
    cond2 = contrast_conds{2};
    sov_cond1 = contrast_sovs{1};
    sov_cond2 = contrast_sovs{2};
    metadata = {};
    
    tfrFt_cond1 = [];
    tfrFt_cond2 = [];

    % return if all exists
    clust_struct_fields = fieldnames(clusts_struct);
    for i = 1:numel(clust_struct_fields)
        if strcmp(clust_struct_fields{i},'elec_gen_info') continue; end
        clust_i = clusts_struct.(clust_struct_fields{i});
        curr_output_filename = sprintf("%s\\TFCP-%s_conds-%s+%s_condsSovs-%s+%s_freq-%.1f-%.0f_clust-%s", ...
            output_dir,tfr_algo,cond1.short_s,cond2.short_s,sov_cond1.short_s, ...
            sov_cond2.short_s,freqrange_test(1),freqrange_test(2), ...
            clust_i.short_s);
        
        curr_output_filename_mat = sprintf("%s.mat",curr_output_filename);
        curr_output_filename_png = sprintf("%s.png",curr_output_filename);

         if isfile(curr_output_filename_png) 
            continue;
         elseif isfile(curr_output_filename_mat)
          data_to_plot = load(curr_output_filename_mat);
          data_to_plot = data_to_plot.metadata;
         else
             if isempty(tfrFt_cond1)
                 tfrFt_cond1 = get_cond_TFR(subs,cond1,sov_cond1,tfr_algo,dirs);
                 tfrFt_cond2 = get_cond_TFR(subs,cond2,sov_cond2,tfr_algo,dirs);
             end

             tfrFt_cond1_bl = {};
             % Apply FieldTrip baseline correction
            cfg_bl = [];
            cfg_bl.baseline = [-0.1, 0];
            cfg_bl.baselinetype = 'absolute';  % or 'relative', 'db', 'zscore'
            cfg_bl.parameter = 'powspctrm_zscore';
            
            % Apply to each subject
            for subj_i = 1:length(tfrFt_cond1)
                tfrFt_cond1_bl{subj_i} = ft_freqbaseline(cfg_bl, tfrFt_cond1{subj_i});
                tfrFt_cond2_bl{subj_i} = ft_freqbaseline(cfg_bl, tfrFt_cond2{subj_i});
            end

             
            data_to_plot = TFCP_TFRMAP_dependentT(subs,tfrFt_cond1_bl, tfrFt_cond2_bl,timerange_test,freqrange_test,clust_i,neighbours,timerange_plot);
            data_to_plot = removeLargePrevious(data_to_plot);
            metadata = data_to_plot;
            save(curr_output_filename_mat, "metadata", '-v7.3')
        end
    
        fig_title = sprintf('conds: %s vs %s, sovs: ',cond1.short_s,cond2.short_s,sov_cond1.short_s,sov_cond2.short_s);
        plot_TFCP_TFRMAP_dependentT(data_to_plot,curr_output_filename_png,fig_title,contrast_conds,event_lines)
    end
end
