classdef funcs_spatioTemporalAnalysis
    properties (SetAccess = private)
        imp
        electrodes
        time
    end
    methods(Static)
        % constructor
        function f = funcs_spatioTemporalAnalysis(imp, electrodes,time)
            f.imp = imp;
            f.electrodes = electrodes;
            f.time = time;
        end

        % get/set
        function s = get_imp(f)
            s = f.imp;
        end
        function s = get_bl(f)
            s = f.bl;
        end
        function s = get_electrodes(f)
            s = f.electrodes;
        end
        function s = get_time(f)
            s = f.time;
        end

        %%%%%%%%%%%%%%%%%%%% intra subject analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function tempoClustPerm_cond1VsCond2_perSub(f,contrasts, persub_output_dir)
            subs = f.imp.get_subs(f.imp);
            neig = f.imp.get_neighbours(f.imp);

            cfg                  = [];
            cfg.method           = 'montecarlo';
            cfg.statistic        = 'indepsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusterstatistic = 'maxsum';   
            cfg.minnbchan        = 0;     
            cfg.tail             = 0;         
            cfg.clustertail      = 0;
            cfg.alpha            = 0.025;
            cfg.clusteralpha     = 0.05;  
            cfg.numrandomization = 10000;
            cfg.neighbours    = neig;
            cfg.latency     = [0,0.45];
            cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)
            
            for contrast_ind=1:size(contrasts,2)
                cond1_name = contrasts{contrast_ind}{1};
                cond2_name = contrasts{contrast_ind}{2};
                raw_cond1 = f.imp.get_rawFt_cond(f.imp,cond1_name);
                raw_cond2 = f.imp.get_rawFt_cond(f.imp,cond2_name);
                
                contrast_files = dir(sprintf('%s\\%svs%s_*.mat',persub_output_dir,cond1_name,cond2_name));
                if size(contrast_files,1) >0
                    continue;
                end

                for sub_i =1:size(subs,2)
                    curr_sub_cond1 = raw_cond1{sub_i};
                    curr_sub_cond2 = raw_cond2{sub_i};
                    n_fc  = size(curr_sub_cond1.trial, 2);
                    n_fic = size(curr_sub_cond2.trial, 2);
                    cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
                    for electd_i =1:size(f.electrodes,1)
                        curr_output_filename = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},f.electrodes{electd_i});
                        if isfile(curr_output_filename) continue; end

                        cfg.channel     = {f.electrodes{electd_i}};
                        [stat] = ft_timelockstatistics(cfg, curr_sub_cond1, curr_sub_cond2);
                        if all(stat.mask == 0)
                            continue;
                        else
                            save(curr_output_filename, '-struct', 'stat');
                        end
                    end
                end
            end
        end
        
        function plot_allSubs_electrodes_sig_range(f,contrasrs,persub_output_dir)
            subs = f.imp.get_subs(f.imp);

            time0_ind = find(f.time == 0, 1);
            for contrast_ind=1:size(contrasrs,2)
                cond1_name = contrasrs{contrast_ind}{1};
                cond2_name = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd",persub_output_dir,cond1_name,cond2_name);
                if isfile(sprintf("%s.png",curr_output_filename)) continue; end

                num_of_subs_with_clust = 0;
                num_of_sig_electrodes = 0;
                plot_counter = 1;
                one_times = ones(size(f.time,2),1);
                figure;
                for sub_i =1:size(subs,2)
                    was_in_sub = false;
                    curr_color = [rand,rand,rand];
                    for electd_i =1:size(f.electrodes,1)      
                        file_path = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},f.electrodes{electd_i});
                        if isfile(file_path)
                            num_of_sig_electrodes = num_of_sig_electrodes+1;
                            was_in_sub = true;
                            test_stat = load(file_path);
                            mask_in_trial = zeros(size(f.time,2),1);
                            mask_in_trial(time0_ind:size(f.time,2)) = test_stat.mask;
                            plot(f.time(find(mask_in_trial)),plot_counter*one_times(find(mask_in_trial)),'.', 'DisplayName','Oe',"Color",curr_color,"MarkerSize",8)
                            hold on;
                            plot_counter = plot_counter+1;
                        end
                    end
                    if was_in_sub
                        num_of_subs_with_clust=num_of_subs_with_clust+1;
                    end
                end
                title('Timeranges of significant clusters',sprintf("Any significant electrode \n #subs= %d. Percent from allElectrodes = %.2f",num_of_subs_with_clust,num_of_sig_electrodes/((size(f.electrodes,1))*size(subs,2))))
                xlabel('Time (s)')
                ylim([0,plot_counter])
                xlim([f.time(1),f.time(end)])
                hold off
                saveas(gcf,sprintf("%s.png",curr_output_filename));
                saveas(gcf,sprintf("%s.svg",curr_output_filename));
                saveas(gcf,sprintf("%s.fig",curr_output_filename));
            end
        end
        
        function plot_allSubs_electrodes_sig_range_omissionPerSubElect(f,contrasrs,persub_output_dir,pre_vs_poststim_dir)
           subs = f.imp.get_subs(f.imp);
           bl = f.imp.get_baseline_length(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1_name = contrasrs{contrast_ind}{1};
                cond2_name = contrasrs{contrast_ind}{2};
        
                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd_omissionAvgElect",persub_output_dir,cond1_name,cond2_name);
                if isfile(sprintf("%s.png",curr_output_filename)) continue; end
        
                time0_ind = find(f.time == 0, 1);
                num_of_subs_with_clust = 0;
                num_of_sig_electrodes = 0;
                plot_counter = 1;
                one_times = ones(size(f.time,2),1);
                figure;
                for sub_i=1:size(subs,2)
                    was_in_sub = false;
                    curr_color = [rand + 0.1,rand+ 0.1,rand+ 0.1] * 0.7;
                    currsub_preVsPoststim.("O") = load(sprintf("%s\\preVsPoststim_bl-%d_O_sub-%s.mat",pre_vs_poststim_dir, bl,subs{sub_i}));
                    for pos_neg_ind=1:2
                        if pos_neg_ind ==1
                            clusters = {currsub_preVsPoststim.("O").posclusters.prob};
                            clust_mask = currsub_preVsPoststim.("O").posclusterslabelmat;
                            title_text = sprintf("PreVsPoststim %s - positive clusters","O");
                            pos_or_neg_text = 'pos';
                        else
                            clusters = {currsub_preVsPoststim.("O").negclusters.prob};
                            clust_mask = currsub_preVsPoststim.("O").negclusterslabelmat;
                            title_text = sprintf("PreVsPoststim %s - negative clusters","O");
                            pos_or_neg_text = 'neg';
                        end
                    
                        for clust_ind=1:size(clusters,2)
                            % get time-electrode mask for current cluster
                            curr_clust_mask = clust_mask;
                            curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                            curr_clust_mask(curr_clust_mask ~= 0) = 1;
                            temp = mean(curr_clust_mask,2);
                            clust_electd = find(temp>0);
                
                            if clusters{clust_ind} > 0.05
                                continue;
                            end
                
                            for clustElect_i=1:size(clust_electd,2)
                                sub_electrode_T_stats_filename = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},f.electrodes{clust_electd(clustElect_i)});
                                if isfile(sub_electrode_T_stats_filename)
                                    was_in_sub = true; 
                                    sub_electrode_T_stats = load(sub_electrode_T_stats_filename);
                                    mask_in_trial = zeros(size(f.time,2),1);
                                    mask_in_trial(time0_ind:size(f.time,2)) = sub_electrode_T_stats.prob<0.025;
                
                                    bl_mask_in_trial = curr_clust_mask(clust_electd(clustElect_i),:).';
                                    
                                    plot(f.time(find(bl_mask_in_trial)),plot_counter*one_times(find(bl_mask_in_trial)),'.', 'DisplayName','Oe',"Color",'#cccccc',"MarkerSize",15)
                                    hold on;
                                    plot(f.time(find(mask_in_trial)),plot_counter*one_times(find(mask_in_trial)),'.', 'DisplayName','Oe',"Color",curr_color,"MarkerSize",8)
                                    hold on;
                                    plot_counter = plot_counter+1;
                                end
                            end
                        end
                    end
                    if was_in_sub
                        num_of_subs_with_clust=num_of_subs_with_clust+1;
                    end
                end
                title('Timeranges of significant clusters' ,sprintf("Contrast: %s-vs-%s\nElectrodes are part of the the subject's Omission-vs-Baseline cluster \n #subs= %d. Percent from allElectrodes = %.2f",cond1_name,cond2_name,num_of_subs_with_clust,num_of_sig_electrodes/((size(f.electrodes,1))*size(subs,2))))
                xlabel('Time (s)')
                xlim([f.time(1),f.time(end)])
                ylim([0,plot_counter])
                hold off
                saveas(gcf,sprintf("%s.png",curr_output_filename));
                saveas(gcf,sprintf("%s.svg",curr_output_filename));
                saveas(gcf,sprintf("%s.fig",curr_output_filename));
            end
        end

        function plot_allSubs_electrodes_sig_range_omissionAvgElect(f,contrasrs,persub_output_dir,pre_vs_poststim_dir)
            subs = f.imp.get_subs(f.imp);
            bl = f.imp.get_baseline_length(f.imp);
            time0_ind = find(f.time == 0, 1);
            for contrast_ind=1:size(contrasrs,2)
                cond1_name = contrasrs{contrast_ind}{1};
                cond2_name = contrasrs{contrast_ind}{2};
        
                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd_omissionPerSubElect",persub_output_dir,cond1_name,cond2_name);
                if isfile(sprintf("%s.png",curr_output_filename)) continue; end
            
                currsub_preVsPoststim.("O") = load(sprintf("%s\\preVsPoststim_bl-%d_O_avg.mat",pre_vs_poststim_dir, bl));
                num_of_subs_with_clust = 0;
                num_of_sig_electrodes = 0;
                plot_counter = 1;
                one_times = ones(size(f.time,2),1);
                figure;
                
                for sub_i=1:size(subs,2)
                    was_in_sub = false;
                    curr_color = [rand + 0.1,rand+ 0.1,rand+ 0.1] * 0.7;
                    for pos_neg_ind=1:2
                        if pos_neg_ind ==1
                            clusters = {currsub_preVsPoststim.("O").posclusters.prob};
                            clust_mask = currsub_preVsPoststim.("O").posclusterslabelmat;
                            title_text = sprintf("PreVsPoststim %s - positive clusters","O");
                            pos_or_neg_text = 'pos';
                        else
                            clusters = {currsub_preVsPoststim.("O").negclusters.prob};
                            clust_mask = currsub_preVsPoststim.("O").negclusterslabelmat;
                            title_text = sprintf("PreVsPoststim %s - negative clusters","O");
                            pos_or_neg_text = 'neg';
                        end
                    
                        for clust_ind=1:size(clusters,2)
                            % get time-electrode mask for current cluster
                            curr_clust_mask = clust_mask;
                            curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                            curr_clust_mask(curr_clust_mask ~= 0) = 1;
                            temp = mean(curr_clust_mask,2);
                            clust_electd = find(temp>0);
                
                            if clusters{clust_ind} > 0.05
                                continue;
                            end
                
                            for clustElect_i=1:size(clust_electd,2)
                                sub_electrode_T_stats_filename = sprintf("%s\\%svs%s_sub-%s_elctd-%s.mat",persub_output_dir,cond1_name,cond2_name,subs{sub_i},f.electrodes{clust_electd(clustElect_i)});
                                if isfile(sub_electrode_T_stats_filename) 
                                    num_of_sig_electrodes = num_of_sig_electrodes+1;
                                    was_in_sub = true;
                                    sub_electrode_T_stats = load(sub_electrode_T_stats_filename);
                                    mask_in_trial = zeros(size(f.time,2),1);
                                    mask_in_trial(time0_ind:size(f.time,2)) = sub_electrode_T_stats.prob<0.025;
                                    bl_mask_in_trial = curr_clust_mask(clust_electd(clustElect_i),:).';
                                    
                                    plot(f.time(find(bl_mask_in_trial)),plot_counter*one_times(find(bl_mask_in_trial)),'.', 'DisplayName','Oe',"Color",'#cccccc',"MarkerSize",15)
                                    hold on;
                                    plot(f.time(find(mask_in_trial)),plot_counter*one_times(find(mask_in_trial)),'.', 'DisplayName','Oe',"Color",curr_color,"MarkerSize",8)
                                    hold on;
                                    plot_counter = plot_counter+1;
                                end
                            end
                        end
                    end
                    if was_in_sub
                        num_of_subs_with_clust=num_of_subs_with_clust+1;
                    end
                end
                title('Timeranges of significant clusters',sprintf("Contrast: %s-vs-%s\nElectrodes are part of the average Omission-vs-Baseline cluster \n #subs= %d. Percent from allElectrodes = %.2f",cond1_name,cond2_name,num_of_subs_with_clust,num_of_sig_electrodes/((size(f.electrodes,1))*size(subs,2))))
                xlabel('Time (s)')
                xlim([f.time(1),f.time(end)])
                ylim([0,plot_counter])
                hold off
                saveas(gcf,sprintf("%s.png",curr_output_filename));
                saveas(gcf,sprintf("%s.svg",curr_output_filename));
                saveas(gcf,sprintf("%s.fig",curr_output_filename));
                
            end
        end

        % Plot one fig per sig cluster of preVsPost of bl_cond_text. Each
        % plot for each subject it's ERP over the electrode of the sig
        % cluster
        function plotErp_perSub_electrodesPerSigBlCluster(f,bl_cond_text, contrasts, pre_vs_poststim_dir)
            subs = f.imp.get_subs(f.imp);
            bl = f.imp.get_baseline_length(f.imp);
            for contrast_ind=1:size(contrasts,2)
                cond1_text = contrasts{contrast_ind}{1};
                cond2_text = contrasts{contrast_ind}{2};
            
                blCond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%d_%s_avg",pre_vs_poststim_dir, bl,bl_cond_text));
                
                for pos_neg_ind=1:2
                    if pos_neg_ind ==1
                        clusters = {blCond_preVsPoststim.posclusters.prob};
                        clust_mask = blCond_preVsPoststim.posclusterslabelmat;
                        pos_or_neg_text = 'pos';
                    else
                        clusters = {blCond_preVsPoststim.negclusters.prob};
                        clust_mask = blCond_preVsPoststim.negclusterslabelmat;
                        pos_or_neg_text = 'neg';
                    end
                    for clust_ind=1:size(clusters,2)
                        curr_output_filename = sprintf("%s//clustCond-%s_contrast-%svs%s_bl-%d_clustInd-%d%s_PerSub",pre_vs_poststim_dir,bl_cond_text,cond1_text,cond2_text,bl,clust_ind,pos_or_neg_text);
                        if isfile(sprintf("%s.png",curr_output_filename)) continue; end
                        if clusters{clust_ind} > 0.05   continue; end
                        
                        % get time-electrode mask for current cluster
                        curr_clust_mask = clust_mask;
                        curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                        curr_clust_mask(curr_clust_mask ~= 0) = 1;
                        temp = mean(curr_clust_mask,2);
                        clust_electd = find(temp>0);
                        temp = mean(curr_clust_mask,1);
                        clust_times = find(temp>0);
                
                        % Scaling of the vertical axis for the plots below
                        grandavg_cond1 = f.imp.get_cond_timelocked(f.imp,cond1_text);
                        grandavg_cond2 = f.imp.get_cond_timelocked(f.imp,cond2_text);
                        grandavg_cond3 = f.imp.get_cond_timelocked(f.imp,bl_cond_text);
                        % grandavg_cond4 = f.imp.get_cond_timelocked(f.imp,cond4);
                        fig = figure('Position', [10 10 1100 900]);
                        sgtitle(sprintf("Contrast: %s vs. %s \n Only electrodes from %s %s cluster. Start:  %.2f,  End:  %.2f\n",cond1_text,cond2_text,bl_cond_text,pos_or_neg_text,f.time(clust_times(1)),f.time(clust_times(end))));
                        for isub = 1:size(subs,2)
                            subplot(5,6,isub)
                            hold on;
                            
                            y1 = grandavg_cond1{isub}.avg(clust_electd,:);
                            y2 = grandavg_cond2{isub}.avg(clust_electd,:);
                            y3 = mean(grandavg_cond3{isub}.avg(clust_electd,:),1);
                            x = grandavg_cond1{isub}.time;
                            shadedErrorBar2(x,y1,{@mean,@std},'lineprops','-b','patchSaturation',0.2); 
                            shadedErrorBar2(x,y2,{@mean,@std},'lineprops','-r','patchSaturation',0.2); 
                            plot(grandavg_cond1{isub}.time,y3, 'g');
            
                            title(strcat('subject ',subs{isub}))
                             ylim([-2 2])
                             xlim([-0.1 0.45])
                        end
                        subplot(5,6,size(subs,2)+1);
                        axis off
                        text(0.5,0.7,cond1_text,'Color','b')
                        text(0.5,0.5,cond2_text,'Color','r')
                        text(0.5,0.2,'O','Color','g')
                        saveas(fig,sprintf("%s.png",curr_output_filename));
                        saveas(fig,sprintf("%s.svg",curr_output_filename));
                        saveas(fig,sprintf("%s.fig",curr_output_filename));
                    end
                end
            end
        end

        function spatiotempoClustPerm_baselineVsActivity_perSub(f,output_dir, conds_names,is_plot_topoplot)   
            bl = f.imp.get_baseline_length(f.imp);
            subs = f.imp.get_subs(f.imp);
            for cond_i = 1:size(conds_names,2)
                rawft_cond1 = f.imp.get_rawFt_cond(f.imp,conds_names{cond_i});
                rawBl_cond1 = f.imp.get_cond_rawBl(f.imp,conds_names{cond_i});
                for sub_i=1:size(subs,2)
                    curr_output_filename = sprintf("%s\\preVsPoststim_bl-%d_%s_sub-%s.mat",output_dir,bl,conds_names{cond_i},subs{sub_i});
                    if isfile(curr_output_filename) continue; end
                    try
                        metadata = funcs_spatioTemporalAnalysis.cluster_independetT(f,rawft_cond1{sub_i},rawBl_cond1{sub_i},[-0.1,0.45],curr_output_filename,is_plot_topoplot);
                    catch ME
                        if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
                            sprintf("contrast: [%s, baseline]: %s",conds_names{cond_i},ME.message)
                        else
                            ME.message
                        end
                    end
                end
            end
            if exist("metadata","var")
                save(sprintf("%s//preVsPoststim-rawbl-%d_metadata.mat",output_dir,bl), "metadata")
            end
        end

        %%%%%%%%%%%%%%%%%%%% spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function spatiotempoClustPerm_BlPreStimVsActivity_subAvg(f,output_dir, conds_names,plot_topoplot)   
            bl = f.imp.get_baseline_length(f.imp);
            for cond_i = 1:size(conds_names,2)
                curr_output_filename = sprintf("%s\\preVsPoststim_bl-%d_%s_avg.mat",output_dir,bl,conds_names{cond_i});
                if isfile(curr_output_filename) continue; end
                timelock_cond = f.imp.get_cond_timelocked(f.imp,conds_names{cond_i});
                timelockBl_cond = f.imp.get_cond_timelockedBl_preStim(f.imp,conds_names{cond_i});
                metadata = funcs_spatioTemporalAnalysis.cluster_dependentT(f,timelockBl_cond, timelock_cond,[-0.1,0.45],curr_output_filename,plot_topoplot);
            end
            if exist("metadata","var")
                save(sprintf("%s//preVsPoststim-bl-%d_metadata",output_dir,bl), "metadata")
            end
        end

        function spatiotempoClustPerm_BlInterblockVsActivity_subAvg(f,output_dir, conds_names,sov,plot_topoplot)   
            for cond_i = 1:size(conds_names,2)
                curr_output_filename = sprintf("%s\\preVsPoststim_bl-interblock_%s_avg.mat",output_dir,conds_names{cond_i});
                if isfile(curr_output_filename) continue; end
                timelock_cond = f.imp.get_cond_timelocked(f.imp,conds_names{cond_i},sov);
                timelockBl_cond = f.imp.get_cond_timelockedBl_interblock(f.imp,sov);
                metadata = funcs_spatioTemporalAnalysis.cluster_dependentT(f,timelockBl_cond, timelock_cond,[-0.1,0.448],curr_output_filename,plot_topoplot);
            end
            if exist("metadata","var")
                save(sprintf("%s//preVsPoststim-bl-interblock_metadata",output_dir), "metadata")
            end
        end

        function spatiotempoClustPerm_cond1VsCond2_subAvg(f,output_dir, contrasrs,is_plot_topoplot)
            for contrast_ind=1:size(contrasrs,2)
                cond1 = contrasrs{contrast_ind}{1};
                cond2 = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s//%sVs%s_avg.mat",output_dir,cond1,cond2);
                if isfile(curr_output_filename) continue; end
                
                try
                    rawft_cond1 = f.imp.get_cond_timelocked(f.imp,cond1);
                    rawft_cond2 = f.imp.get_cond_timelocked(f.imp,cond2);
                    
                    metadata = funcs_spatioTemporalAnalysis.cluster_dependentT(f,rawft_cond1, rawft_cond2,[-0.1,0.45],curr_output_filename,is_plot_topoplot);
                    %save(sprintf("%s/SpatioTempSubAvg_metadata.mat",image_output_dir), "metadata")
                catch ME
                    if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
                        sprintf("contrast: [%s, %s]: %s",cond1,cond2,ME.message)
                    else
                        ME.message
                    end
                end
            end
        end
        
        function spatiotempoClustPerm_cond1VsCond2_perSub(f,output_dir, contrasrs,is_plot_topoplot)
            subs = f.imp.get_subs(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1 = contrasrs{contrast_ind}{1};
                cond2 = contrasrs{contrast_ind}{2};
                rawft_cond1 = f.imp.get_rawFt_cond(f.imp,cond1);
                rawft_cond2 = f.imp.get_rawFt_cond(f.imp,cond2);
                for sub_ind=1:size(subs,2)
                   curr_output_filename = sprintf("%s//%sVs%s_sub-%s.mat",output_dir,cond1,cond2, subs{sub_ind});
                   if isfile(curr_output_filename) continue; end

                   try
                        metadata = funcs_spatioTemporalAnalysis.cluster_independetT(f,rawft_cond1{sub_ind},rawft_cond2{sub_ind},[-0.1,0.45],curr_output_filename,is_plot_topoplot);
                   catch ME
                        if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
                            sprintf("contrast: [%s, %s]: %s",cond1,cond2,ME.message)
                        else
                            ME.message
                        end
                    end
                end
            end
        end

        function plot_erp_per_contrast_and_sov2(f,sov,contrast,contrast_strings,output_main_dir,electr_cluster_sov,bl_string,cond_preVsPoststim_name)
            curr_colormap = funcs_spatioTemporalAnalysis.get_colormap_for_sov(sov,numel(contrast));
        
            cond1_Vs_cond2_dir = sprintf('%s\\%s\\cond1_Vs_cond2',output_main_dir,sov);
        
            pre_vs_poststim_cluster_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,electr_cluster_sov);
            cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%s_%s_avg",pre_vs_poststim_cluster_dir,bl_string,cond_preVsPoststim_name));
            subs = f.imp.get_subs(f.imp);
            
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {cond_preVsPoststim.posclusters.prob};
                    clust_mask = cond_preVsPoststim.posclusterslabelmat;
                    pos_or_neg_text = 'pos';
                    ylim_ = [-0.8 0.3];
                    ylim_ = [-1 1];
                else
                    clusters = {cond_preVsPoststim.negclusters.prob};
                    clust_mask = cond_preVsPoststim.negclusterslabelmat;
                    pos_or_neg_text = 'neg';
                    ylim_ = [-0.3 0.8];
                    ylim_ = [-1 1];
                end
                if strcmp(sov,'N3')
                    ylim_ = [-1.3 1.3];
                end
                for clust_ind=1:size(clusters,2)
                    % a cluter will be drawn only if: it is the first and p<0.1, or it is p<0.05
                    if (clust_ind == 1 && clusters{clust_ind} > 0.1) ||  (clust_ind ~= 1 && clusters{clust_ind} > 0.05)
                        continue;
                    end
        
                    curr_output_filename = sprintf('%s\\ERP_bl-%s_sov-%s_cond-%s_clust-%s-%s-%s',cond1_Vs_cond2_dir,bl_string,sov,['{' strjoin(contrast, ',') '}'],cond_preVsPoststim_name,pos_or_neg_text,electr_cluster_sov);
                    if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
        
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);
                    
                    stat = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,contrast,clust_electd,[f.time(1),f.time(end)],sov);
        
                    % plot sig points
                    if ~all(stat.mask ==0)
                        sig_timerange = stat.mask;
                    else
                        sig_timerange = 0;
                    end
        
                    % get mean activity per sub and cond
                    % allSubs_conds_AvgActivity average the activity over all electrods and time
                    allSubs_conds_AvgActivity = zeros(size(subs,2),size(f.time,2),size(contrast,2)); 
                    for cond_j = 1:size(contrast,2)
                        curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,contrast{cond_j},sov); 
                        for sub_i = 1:size(subs,2)
                            curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                            allSubs_conds_AvgActivity(sub_i,:,cond_j) = mean(curr_sub_cond_struct.avg(clust_electd,:),1);
                        end
                    end
        
                    title_ = sprintf('ERP, %s, %d subjects', sov, size(subs,2));
                    subtitle_ = sprintf('Electrodes from per-vs-post stim cluster: %s, %s, %s. Bl - %s',cond_preVsPoststim_name, electr_cluster_sov ,pos_or_neg_text,bl_string);

                    funcs_spatioTemporalAnalysis.plot_erps(f.time,contrast_strings,allSubs_conds_AvgActivity ...
                    ,curr_output_filename, curr_colormap, ...
                    'sig_timeranges',{sig_timerange},'sig_timeranges_colormap',{{curr_colormap(1,:),curr_colormap(end,:)}}, ...
                    'title_',title_,'subtitle_',subtitle_,'ylim_',ylim_ ...
                    ,'clust_electd',{cond_preVsPoststim.elec,clust_electd})
                end
            end
        end
   
        function plot_erp_per_contrast_and_sov(f,sov,contrast,contrast_strings,output_main_dir,electr_cluster_sov,bl_string,cond_preVsPoststim_name)
            curr_colormap = funcs_spatioTemporalAnalysis.get_colormap_for_sov(sov,numel(contrast));
        
            cond1_Vs_cond2_dir = sprintf('%s\\%s\\cond1_Vs_cond2',output_main_dir,sov);
        
            pre_vs_poststim_cluster_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,electr_cluster_sov);
            cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%s_%s_avg",pre_vs_poststim_cluster_dir,bl_string,cond_preVsPoststim_name));
            subs = f.imp.get_subs(f.imp);
            
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {cond_preVsPoststim.posclusters.prob};
                    clust_mask = cond_preVsPoststim.posclusterslabelmat;
                    pos_or_neg_text = 'pos';
                    ylim_ = [-0.8 0.3];
                    ylim_ = [-1 1];
                else
                    clusters = {cond_preVsPoststim.negclusters.prob};
                    clust_mask = cond_preVsPoststim.negclusterslabelmat;
                    pos_or_neg_text = 'neg';
                    ylim_ = [-0.3 0.8];
                    ylim_ = [-1 1];
                end
                if strcmp(sov,'N3')
                    ylim_ = [-1.3 1.3];
                end
                for clust_ind=1:size(clusters,2)
                    % a cluter will be drawn only if: it is the first and p<0.1, or it is p<0.05
                    if (clust_ind == 1 && clusters{clust_ind} > 0.1) ||  (clust_ind ~= 1 && clusters{clust_ind} > 0.05)
                        continue;
                    end
        
                    curr_output_filename = sprintf('%s\\ERP_bl-%s_sov-%s_cond-%s_clust-%s-%s-%s',cond1_Vs_cond2_dir,bl_string,sov,['{' strjoin(contrast, ',') '}'],cond_preVsPoststim_name,pos_or_neg_text,electr_cluster_sov);
                    if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
        
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);
                    
                    stat = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,contrast,clust_electd,[f.time(1),f.time(end)],sov);
        
                    % plot sig points
                    if ~all(stat.mask ==0)
                        sig_timerange = stat.mask;
                    else
                        sig_timerange = 0;
                    end
        
                    % get mean activity per sub and cond
                    % allSubs_conds_AvgActivity average the activity over all electrods and time
                    allSubs_conds_AvgActivity = zeros(size(subs,2),size(f.time,2),size(contrast,2)); 
                    for cond_j = 1:size(contrast,2)
                        curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,contrast{cond_j},sov); 
                        for sub_i = 1:size(subs,2)
                            curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                            allSubs_conds_AvgActivity(sub_i,:,cond_j) = mean(curr_sub_cond_struct.avg(clust_electd,:),1);
                        end
                    end
        
                    title_ = sprintf('ERP, %s, %d subjects', sov, size(subs,2));
                    subtitle_ = sprintf('Electrodes from per-vs-post stim cluster: %s, %s, %s. Bl - %s',cond_preVsPoststim_name, electr_cluster_sov ,pos_or_neg_text,bl_string);

                    funcs_spatioTemporalAnalysis.plot_erps(f.time,contrast_strings,allSubs_conds_AvgActivity ...
                    ,curr_output_filename, curr_colormap, ...
                    'sig_timeranges',{sig_timerange},'sig_timeranges_colormap',{{curr_colormap(1,:),curr_colormap(end,:)}}, ...
                    'title_',title_,'subtitle_',subtitle_,'ylim_',ylim_ ...
                    ,'clust_electd',{cond_preVsPoststim.elec,clust_electd})
                end
            end
        end
    
        function plot_erp_baseline_vs_cond_per_sov(f,sov,cluster_sov,cond_preVsPoststim_name,bl,bl_string,pre_vs_post_cond_string,output_main_dir)
            curr_colormap = funcs_spatioTemporalAnalysis.get_colormap_for_sov(sov,2);
        
            clust_pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,cluster_sov);
            save_pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,sov);
            clust_cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%s_%s_avg",clust_pre_vs_poststim_dir,bl,cond_preVsPoststim_name));
            subs = f.imp.get_subs(f.imp);
            
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {clust_cond_preVsPoststim.posclusters.prob};
                    clust_mask = clust_cond_preVsPoststim.posclusterslabelmat;
                    pos_or_neg_text = 'pos';
                    ylim_ = [-0.8 0.3];
                    ylim_ = [-1 1];
                else
                    clusters = {clust_cond_preVsPoststim.negclusters.prob};
                    clust_mask = clust_cond_preVsPoststim.negclusterslabelmat;
                    pos_or_neg_text = 'neg';
                    ylim_ = [-0.3 0.8];
                    ylim_ = [-1 1];
                end
                if strcmp(sov,'N3')
                    ylim_ = [-1.3 1.3];
                end
                for clust_ind=1:size(clusters,2)
                    curr_output_filename = sprintf('%s\\ERP_bl-%s_sov-%s_cond-%s_clust-%s-%s-%s-%d',save_pre_vs_poststim_dir,bl,sov,cond_preVsPoststim_name,cluster_sov,cond_preVsPoststim_name,pos_or_neg_text,clust_ind);
                    if isfile(sprintf("%s.fig",curr_output_filename)) continue; end

                    % a cluter will be drawn only if: it is the first and p<0.1, or it is p<0.05
                    if (clust_ind == 1 && clusters{clust_ind} > 0.1) ||  (clust_ind ~= 1 && clusters{clust_ind} > 0.05)
                        continue;
                    end
        
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);
                    
                    stat = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,{bl,cond_preVsPoststim_name},clust_electd,[f.time(1),f.time(end)],sov);
        
                    % plot sig points
                    if ~all(stat.mask ==0)
%                         mask_in_trial = zeros(size(f.time,2),1);
%                         mask_in_trial(f.time(1):f.time(end)) = stat.mask; 
                        sig_timerange = stat.mask;
                    else
                        sig_timerange = 0;
                    end
        
                    % get mean activity per sub and cond
                    % allSubs_conds_AvgActivity average the activity over all electrods and time
                    allSubs_conds_AvgActivity = zeros(size(subs,2),size(f.time,2),2); 
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,cond_preVsPoststim_name,sov); 
                    if strcmp(bl,'interblock')
                        curr_bl_timelock = f.imp.get_cond_timelockedBl_interblock(f.imp,sov); 
                    else % if strcmp(bl_string,'bl-prestim')
                        %%%%curr_bl_timelock = f.imp.get_cond_timelockedBl_preStim(f.imp,cond); ,etc
                    end
                    for sub_i = 1:size(subs,2)
                        curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                        curr_sub_bl_struct =  curr_bl_timelock{sub_i};
                        
                        allSubs_conds_AvgActivity(sub_i,:,1) = mean(curr_sub_bl_struct.avg(clust_electd,:),1);
                        allSubs_conds_AvgActivity(sub_i,:,2) = mean(curr_sub_cond_struct.avg(clust_electd,:),1);
                    end
        
                    
                    title_ = sprintf('ERP, %s, %d subjects', sov, size(subs,2));
                    subtitle_ = sprintf('Electrodes from %s pre-vs-post stim cluster: %s (%s) %s.\n Bl - %s, p=%s',cluster_sov,pre_vs_post_cond_string, cond_preVsPoststim_name ,pos_or_neg_text,bl_string,num2str(clusters{clust_ind}));
                    contrast_strings = {bl_string,pre_vs_post_cond_string};
                    funcs_spatioTemporalAnalysis.plot_erps(f.time,contrast_strings,allSubs_conds_AvgActivity ...
                        ,curr_output_filename, curr_colormap, ...
                        'sig_timeranges',{sig_timerange}, 'sig_timeranges_colormap',{{curr_colormap(1,:),curr_colormap(end,:)}} ...
                        ,'title_',title_,'subtitle_',subtitle_,'ylim_',ylim_ ...
                        ,'clust_electd',{clust_cond_preVsPoststim.elec,clust_electd})
                end
            end
        end
    
        function plot_erp_per_cond_across_sovs(f,output_main_dir,sovs,cluster_sov,cond_preVsPoststim_name,pre_vs_post_cond_string,bl,bl_string)
            clust_pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,cluster_sov);
            clust_cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%s_%s_avg",clust_pre_vs_poststim_dir,bl,cond_preVsPoststim_name));
            save_dir = sprintf("%s\\all_sovs",output_main_dir);
            subs = f.imp.get_subs(f.imp);

            sovs_colormap = zeros([numel(sovs),3]);
            for sov_i=1:numel(sovs)
                cols = funcs_spatioTemporalAnalysis.get_colormap_for_sov(sovs{sov_i},2);
                sovs_colormap(sov_i,:) = cols(2,:);
            end
            
            
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {clust_cond_preVsPoststim.posclusters.prob};
                    clust_mask = clust_cond_preVsPoststim.posclusterslabelmat;
                    pos_or_neg_text = 'pos';
                else
                    clusters = {clust_cond_preVsPoststim.negclusters.prob};
                    clust_mask = clust_cond_preVsPoststim.negclusterslabelmat;
                    pos_or_neg_text = 'neg';
                end
                 ylim_ = [-1.3 1.3];
                for clust_ind=1:size(clusters,2)
                    % a cluter will be drawn only if: it is the first and p<0.1, or it is p<0.05
                    if (clust_ind == 1 && clusters{clust_ind} > 0.1) ||  (clust_ind ~= 1 && clusters{clust_ind} > 0.05)
                        continue;
                    end
        
                    curr_output_filename = sprintf('%s\\ERP_bl-%s_allSovs_cond-%s__clust-%s-%s-%s-%d', ...
                        save_dir,bl,cond_preVsPoststim_name,cluster_sov,cond_preVsPoststim_name,pos_or_neg_text,clust_ind);
                    if isfile(sprintf("%s.fig",curr_output_filename)) continue; end
        
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);

                    % get mean activity per sub and cond
                    % allSubs_conds_AvgActivity average the activity over all electrods and time
                    allSubs_sovs_AvgActivity = zeros(size(subs,2),size(f.time,2),numel(sovs)); 
                    sig_timerange = {};
                    sig_timerange_colormaps = {};

                    for sov_i=1:numel(sovs)
                        stat = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,{bl,cond_preVsPoststim_name},clust_electd,[f.time(1),f.time(end)],sovs{sov_i});
            
                        % plot sig points
                        if ~all(stat.mask ==0)
    %                         mask_in_trial = zeros(size(f.time,2),1);
    %                         mask_in_trial(f.time(1):f.time(end)) = stat.mask; 
                            sig_timerange{end + 1} = stat.mask;
                        else
                            sig_timerange{end + 1} = {};
                        end
            
                        curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,cond_preVsPoststim_name,sovs{sov_i}); 
%                         if strcmp(bl,'interblock')
%                             curr_sovBl_timelock = f.imp.get_cond_timelockedBl_interblock(f.imp,sovs{sov_i}); 
%                         else % if strcmp(bl_string,'bl-prestim')
%                             %%%%curr_bl_timelock = f.imp.get_cond_timelockedBl_preStim(f.imp,cond); ,etc
%                         end
                        for sub_i = 1:size(subs,2)
                            curr_sub_bl_struct =  curr_cond_timelock{sub_i};
                            allSubs_sovs_AvgActivity(sub_i,:,sov_i) = mean(curr_sub_bl_struct.avg(clust_electd,:),1);
                        end

                        curr_colormap = funcs_spatioTemporalAnalysis.get_colormap_for_sov(sovs{sov_i},2);
                        sig_timerange_colormaps{end + 1} = {curr_colormap(1,:),curr_colormap(end,:)};
                    end

                    title_ = sprintf('ERP, Condition-%s, %d subjects', pre_vs_post_cond_string,size(subs,2)); 
                    subtitle_ = sprintf('Electrodes from %s pre-vs-post stim cluster: %s (%s) %s.\n Bl - %s, p=%s',cluster_sov,pre_vs_post_cond_string, cond_preVsPoststim_name ,pos_or_neg_text,bl_string,num2str(clusters{clust_ind}));
                    funcs_spatioTemporalAnalysis.plot_erps(f.time,sovs,allSubs_sovs_AvgActivity ...
                        ,curr_output_filename, sovs_colormap, ...
                        'sig_timeranges',sig_timerange, 'sig_timeranges_colormap',sig_timerange_colormaps ...
                        ,'title_',title_,'subtitle_',subtitle_,'ylim_',ylim_ ...
                        ,'clust_electd',{clust_cond_preVsPoststim.elec,clust_electd})
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%% data tests %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plot_and_test_basline_different_that_0(f,conds_names,dir_baseline_erp)
            subs = f.imp.get_subs(f.imp);
            neig = f.imp.get_neighbours(f.imp);
            time0_ind = find(f.time == 0, 1);
            for cond_i= 1:size(conds_names,2)
                curr_output_filename = sprintf("%s//Cond-%s_baseline_perSub_allelectd",dir_baseline_erp, conds_names{cond_i});
                if isfile(sprintf("%s.png", curr_output_filename)) continue; end

                number_of_different_than_0_baseline = 0;
                fig = figure;
                for sub_i = 1:size(subs,2)   
                    ax = subplot(ceil(size(subs,2)/5),5,sub_i);
                    timelock_cond = f.imp.get_cond_timelocked(f.imp,conds_names{cond_i});
                    curr_sub_cond_struct =  timelock_cond{sub_i};
                    baseline = curr_sub_cond_struct.avg(:,1:time0_ind);
                    for elecd_ind=1:size(f.electrodes,1)
                        plot(ax, f.time(1:time0_ind), baseline(elecd_ind,:))
                        hold on;
                        [h,p,ci,stats] = ttest(baseline(elecd_ind,:));
                        if p<0.5
                            fprintf("sub:%s, elecd:%d",subs{sub_i},elecd_ind)
                            number_of_different_than_0_baseline = number_of_different_than_0_baseline+1;
                        end
                    end
                    hold off;
                    axis([f.time(1) f.time(time0_ind) -2.5 2.5])
                    title(sprintf("sub %s",subs{sub_i}));
                    
                    %legend("Location","northwest","FontSize",6)
                end
                
                set(gcf,'Position',[100 100 900 600]); %  [x y width height]
                han=axes(fig,'visible','off'); 
                han.Title.Visible='on';
                han.XLabel.Visible='on';
                han.YLabel.Visible='on';
                ylabel(han,'µV');
                xlabel(han,'Time (s)');
                
               
                title(han,sprintf('Cond - %s : All electrodes, baseline activity per subject',conds_names{cond_i}));
                saveas(gcf,sprintf("%s.png",curr_output_filename));
                saveas(gcf,sprintf("%s.svg",curr_output_filename));
                saveas(gcf,sprintf("%s.fig",curr_output_filename));
                fprintf("Cond-%s: number_of_different_than_0_baseline: %d,   out of: %d\n",conds_names{cond_i},number_of_different_than_0_baseline,size(subs,2)*size(neig,2))
            end
        end
        
        function baseline_avgAndStd_allElectd(f,conds_names)
            subs = f.imp.get_subs(f.imp);

            subs_avgBaseline_PerCondAndElectd = zeros(size(conds_names,2),size(subs,2),size(f.electrodes,1));
            for cond_i = 1:size(conds_names,2)
                timelock_cond = f.imp.get_cond_timelocked(f.imp,conds_names{cond_i});
                for sub_i = 1:size(subs,2)
                    subs_avgBaseline_PerCondAndElectd(cond_i,sub_i,:) = timelock_cond{sub_i}.avg(:,1);
                end
            end
            avg_perCond = mean(subs_avgBaseline_PerCondAndElectd,[2,3],'omitnan'); 
            stdperCond = std(subs_avgBaseline_PerCondAndElectd,0,[2,3],'omitnan'); 
            for cond_i = 1:size(conds_names,2)
                fprintf("Cond %s grand avg is: %d, std is:%d\n",conds_names{cond_i},avg_perCond(cond_i),stdperCond(cond_i))
            end
        end

        function print_clusters_probability(f,contrasrs,cond1_Vs_cond2_dir)
            subs = f.imp.get_subs(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1_text = contrasrs{contrast_ind}{1};
                cond2_text = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s\\%sVs%s_clust_prob_summary.txt",cond1_Vs_cond2_dir,cond1_text,cond2_text);
                if isfile(curr_output_filename) continue; end

                fileID = fopen(curr_output_filename,'w');

                % Multi-subject contrast            
                avgSub_stat  = load(sprintf("%s\\%sVs%s_avg.mat",cond1_Vs_cond2_dir,cond1_text,cond2_text));
                currsub_stat_posclusters_prob = {avgSub_stat.posclusters.prob};
                all_pos_clusters = [];
                for cluster_ind =  1:size(currsub_stat_posclusters_prob,2)
                    if currsub_stat_posclusters_prob{cluster_ind} <=0.2
                        all_pos_clusters = [all_pos_clusters , currsub_stat_posclusters_prob{cluster_ind}];
                    end
                end
                currsub_stat_negclusters_prob = {avgSub_stat.negclusters.prob};
                all_neg_clusters = [];
                for cluster_ind =  1:size(currsub_stat_negclusters_prob,2)
                    if currsub_stat_negclusters_prob{cluster_ind} <=0.2
                        all_neg_clusters = [all_neg_clusters , currsub_stat_negclusters_prob{cluster_ind}];
                    end
                end
                if ~isempty(all_pos_clusters) || ~isempty(all_neg_clusters)
                    fprintf(fileID,"sub-AVG: clusters prob,\t positive: %s\t\t ; negative: %s\n", join(string(all_pos_clusters),","),join(string(all_neg_clusters),","));
                else
                    fprintf(fileID,"sub-AVG: none");
                end
                
                % per-subject contrast
                num_of_clust_small_than_005 = 0;
                num_of_clust_small_than_01 = 0;
                num_of_clust_small_than_02 = 0;
                num_of_subj_with_clust_small_than_02 = 0;
                fprintf(fileID,"\nContrasts: %s vs. %s \n",cond1_text,cond2_text);
                for sub_i =1:size(subs,2)
                    file_path = sprintf("%s\\%sVs%s_sub-%s",cond1_Vs_cond2_dir,cond1_text,cond2_text, subs{sub_i});
                    currsub_stat  = load(file_path{1});
                    currsub_stat_posclusters_prob = {currsub_stat.posclusters.prob};
                    all_pos_clusters = [];
                    for cluster_ind =  1:size(currsub_stat_posclusters_prob,2)
                        if currsub_stat_posclusters_prob{cluster_ind} <=0.2
                            num_of_clust_small_than_02 = num_of_clust_small_than_02+1;
                            all_pos_clusters = [all_pos_clusters , currsub_stat_posclusters_prob{cluster_ind}];
                            if currsub_stat_posclusters_prob{cluster_ind} <=0.05
                                num_of_clust_small_than_005 = num_of_clust_small_than_005 +1;
                            end
                            if currsub_stat_posclusters_prob{cluster_ind} <=0.1
                                num_of_clust_small_than_01 = num_of_clust_small_than_01 +1;
                            end
                        end
                    end
                    currsub_stat_negclusters_prob = {currsub_stat.negclusters.prob};
                    all_neg_clusters = [];
                    for cluster_ind =  1:size(currsub_stat_negclusters_prob,2)
                        if currsub_stat_negclusters_prob{cluster_ind} <=0.2
                            num_of_clust_small_than_02 = num_of_clust_small_than_02+1;
                            all_neg_clusters = [all_neg_clusters , currsub_stat_negclusters_prob{cluster_ind}];
                            if currsub_stat_negclusters_prob{cluster_ind} <=0.05
                                num_of_clust_small_than_005 = num_of_clust_small_than_005 +1;
                            end
                            if currsub_stat_negclusters_prob{cluster_ind} <=0.1
                                num_of_clust_small_than_01 = num_of_clust_small_than_01 +1;
                            end
                        end
                    end
                    if ~isempty(all_pos_clusters) || ~isempty(all_neg_clusters)
                        fprintf(fileID,"Sub %s clusters prob,\t positive: %s\t\t ; negative: %s\n",subs{sub_i}, join(string(all_pos_clusters),","),join(string(all_neg_clusters),","));
                        num_of_subj_with_clust_small_than_02 = num_of_subj_with_clust_small_than_02 + 1;
                    end
                end
                fprintf(fileID,"num_of_clust_small_than_005 = %d \nnum_of_clust_small_than_01 = %d " + ...
                    "\nnum_of_clust_small_than_02 = %d \nnum_of_subj_with_clust_small_than_02 = %d \n", ...
                    num_of_clust_small_than_005, num_of_clust_small_than_01 , ...
                    num_of_clust_small_than_02,num_of_subj_with_clust_small_than_02);
            end
        end
 

        %%%%%%%%%%%%%%%%%%%% depracated %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function plot_OClusters_contrasts(f,conds,cond_preVsPoststim,dir_clusters_erp,is_with_timeElectrode_lines, is_with_T_lines,bl_string)
            subs = f.imp.get_subs(f.imp);
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {cond_preVsPoststim.posclusters.prob};
                    clust_mask = cond_preVsPoststim.posclusterslabelmat;
                    title_text = sprintf("PreVsPoststim %s - positive clusters",conds{3});
                    pos_or_neg_text = 'pos';
                else
                    clusters = {cond_preVsPoststim.negclusters.prob};
                    clust_mask = cond_preVsPoststim.negclusterslabelmat;
                    title_text = sprintf("PreVsPoststim %s - negative clusters",conds{3});
                    pos_or_neg_text = 'neg';
                end
                for clust_ind=1:size(clusters,2)
                    if clusters{clust_ind} > 0.05 continue;  end

                    if is_with_timeElectrode_lines
                        is_with_timeElectrode_lines_string = "timeElectd";
                    else
                        is_with_timeElectrode_lines_string = "SEM";
                    end
                    curr_output_filename = sprintf("%s//clustCond-%s_contrast-%svs%s_bl-%s_clustInd-%d%s_%s",dir_clusters_erp,conds{3},conds{1},conds{2},bl_string,clust_ind,pos_or_neg_text,is_with_timeElectrode_lines_string);
                    if isfile(sprintf("%s.png",curr_output_filename)) continue; end
                    
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);
                    temp = mean(curr_clust_mask,1);
                    clust_times = find(temp>0); %TODO: % test use of clust_times in this func
                    stat = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,conds,clust_electd,[f.time(clust_times(1)),f.time(clust_times(end))]);
                    stat2 = funcs_spatioTemporalAnalysis.cluster_permu_erp(f,conds,curr_clust_mask,[f.time(clust_times(1)),f.time(clust_times(end))]);
        
                    % get mean activity per sub and cond
                    % allSubs_conds_cluseAvgActivity average the activity only in cluster time-electrods.
                    % allSubs_conds_AvgActivity average the activity over all electrods and time
                    allSubs_conds_cluseAvgActivity = zeros(size(conds,2),size(subs,2),size(f.time,2));
                    allSubs_conds_AvgActivity = zeros(size(conds,2),size(subs,2),size(f.time,2));
                    for cond_j = 1:size(conds,2)
                        curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_j}); 
                        for sub_i = 1:size(subs,2)
                            curr_sub_cond_struct =  curr_cond_timelock{sub_i};
                            avg_clusterMasked = curr_sub_cond_struct.avg .* curr_clust_mask;
                            sub_clust_activity_mean = sum(avg_clusterMasked,1) ./ sum(avg_clusterMasked~=0,1);
                            allSubs_conds_cluseAvgActivity(cond_j,sub_i,:) = sub_clust_activity_mean;
                            allSubs_conds_AvgActivity(cond_j,sub_i,:) = mean(curr_sub_cond_struct.avg(clust_electd,:),1);
                        end
                    end
                    
                    %%%%%%%   plot
                    mean_activity_per_cond_clustTimeSpace = squeeze(mean(allSubs_conds_cluseAvgActivity,2));
                    mean_activity_per_cond_clustSpace = squeeze(mean(allSubs_conds_AvgActivity,2));
                    figure();
                    FOROO_colors = {'blue','red','#ad17b5'};
                    if is_with_timeElectrode_lines
                        for cond_j = 1:size(conds,2)-1
                            plot(f.time, mean_activity_per_cond_clustTimeSpace(cond_j,:)','DisplayName',sprintf("%s-cluster time-electrode",conds{cond_j}),'LineStyle','--','Color',FOROO_colors{cond_j})
                            hold on;
                            plot(f.time, mean_activity_per_cond_clustSpace(cond_j,:)','DisplayName',sprintf("%s-cluster electrode",conds{cond_j}),'Color',FOROO_colors{cond_j})
                            hold on;
                        end
                        % plot sig points
                        if ~all(stat2.mask ==0)
                            mask_in_trial = zeros(size(f.time,2),1);
                            mask_in_trial(clust_times(1):clust_times(end)) = stat2.mask;
                            plot(f.time(find(mask_in_trial)),mean_activity_per_cond_clustTimeSpace(3,find(mask_in_trial)),'.', 'DisplayName',sprintf('%s vs. %s - time-electrode',conds{1},conds{2}),"Color",'#808080',"MarkerSize",8)
                        end
                    else
                        one_div_sqrt_samp_size = 1/sqrt(size(subs,2));
                        x = squeeze(allSubs_conds_AvgActivity(1,:,:));
                        shadedErrorBar2(f.time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',FOROO_colors{1},'DisplayName',sprintf("%s-cluster electrode",conds{1})},'patchSaturation',0.2);
                        hold on;
                        x = squeeze(allSubs_conds_AvgActivity(2,:,:));
                        shadedErrorBar2(f.time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',FOROO_colors{2},'DisplayName',sprintf("%s-cluster electrode",conds{2})},'patchSaturation',0.2);
                        hold on;
                        plot(f.time, mean_activity_per_cond_clustSpace(3,:)','DisplayName',sprintf("%s-cluster electrode",conds{3}),'Color',FOROO_colors{3})
                    end

                    % plot T 
                    if is_with_T_lines
                        plot(f.time, mean_activity_per_cond_clustSpace(4,:)','DisplayName',sprintf("%s-cluster electrode",conds{4}),'Color','black')
                    end
                    
                    % plot sig points
                    if ~all(stat.mask ==0)
                        mask_in_trial = zeros(size(f.time,2),1);
                        mask_in_trial(clust_times(1):clust_times(end)) = stat.mask; 
                        plot(f.time(find(mask_in_trial)),mean_activity_per_cond_clustSpace(3,find(mask_in_trial)),'.', 'DisplayName', sprintf('%s vs. %s - electrode',conds{1},conds{2}),"Color",'black',"MarkerSize",8)
                    end

                    electrods_string = join({cond_preVsPoststim.label{clust_electd}},",");
                    electrods_string = erase(electrods_string,"E");
                    electrods_string = electrods_string{1};
                    title(sprintf("%s, clust ind=%d, pval=%f, baseline=%sms",title_text,clust_ind,clusters{clust_ind},bl_string), ...
                        sprintf("%d Electrodes: %s\n%s",size(clust_electd,1),electrods_string(1:round(size(electrods_string,2)/2)),electrods_string(round(size(electrods_string,2)/2)-1:end)),"FontSize",8);
                    legend("Location","northeast","FontSize",5);
                    if pos_neg_ind ==1
                        axis([f.time(1) f.time(end) -0.8 0.2]) %axis([time(1) time(end) -1 1.5])
                    else
                        axis([f.time(1) f.time(end) -0.2 0.8]) %axis([time(1) time(end) -1 1.5])
                    end
                    xlabel('Time (s)')
                    ylabel('µV')
                    saveas(gcf,sprintf("%s.png",curr_output_filename));
                    saveas(gcf,sprintf("%s.svg",curr_output_filename));
                    saveas(gcf,sprintf("%s.fig",curr_output_filename));

                    % plot the clusters electrodes topography
                    figure();
                    cfg = [];
                    cfg.feedback    = 'no';
                    cfg.elec= cond_preVsPoststim.elec;
                    layout = ft_prepare_layout(cfg);
                    ft_plot_layout(layout,'label','no','box','no','chanindx',clust_electd,'pointsize',22);
                    saveas(gcf,sprintf("%s_topography.png",curr_output_filename));
                    saveas(gcf,sprintf("%s_topography.svg",curr_output_filename));
                    saveas(gcf,sprintf("%s_topography.fig",curr_output_filename));
                end
            end
        end
        
        function timeElectedMatrix_perCond1VsCond2Cluster(f,contrasrs,cond1_Vs_cond2_dir)
            subs = f.imp.get_subs(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1_text = contrasrs{contrast_ind}{1};
                cond2_text = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s//%svs%s_prevelenceInSpatiotemporalCluster",cond1_Vs_cond2_dir,cond1_text,cond2_text);
                if isfile(springf("%s.png", curr_output_filename)) continue; end

                allSub_masksSum = zeros(size(f.electrodes,1),size(f.time,2));
                number_of_sub_with_sig_clusters = 0;
                figure
                for sub_i=1:size(subs,2)
                    curr_Cond1vsCond2_stat = load( sprintf("%s\\%sVs%s_sub-%s.mat",cond1_Vs_cond2_dir,cond1_text,cond2_text, subs{sub_i}));
                    if any(curr_Cond1vsCond2_stat.prob(:)<0.2)
                        allSub_masksSum = allSub_masksSum+curr_Cond1vsCond2_stat.mask;
                        number_of_sub_with_sig_clusters = number_of_sub_with_sig_clusters +1;
                    end
                end
                c = pcolor(f.time, linspace(1,size(curr_Cond1vsCond2_stat.label,1) , size(curr_Cond1vsCond2_stat.label,1)), allSub_masksSum);
                xlabel('Time');
                ylabel('Electrode');
                title(sprintf('Prevelence of each time-electrode in the %d subjects spatiotemporal clusters',size(subs,2)), ...
                    sprintf('Number of subjects with sig electrodes is: %d',number_of_sub_with_sig_clusters))
                colorbar
                %caxis([0, 5]);
                saveas(gcf,sprintf("%s.png",curr_output_filename));
                saveas(gcf,sprintf("%s.svg",curr_output_filename));
                saveas(gcf,sprintf("%s.fig",curr_output_filename));
            end
        end

    end

    methods(Access=private, Static)
        % Electrods Cluster between conditions. per timepoint for one subject
        function metadata = cluster_independetT(f,cond1_struct, cond2_struct,latency,stat_file_string,is_plot_topoplot)
            neighbours = f.imp.get_neighbours(f.imp);

            metadata = {};
            timelockFC  = cond1_struct;
            timelockFIC = cond2_struct;
            
            % ft_timelockstatistics
            cfg                  = [];
            cfg.method           = 'montecarlo';
            cfg.statistic        = 'indepsamplesT';
            cfg.correctm         = 'cluster';
            
            cfg.clusteralpha     = 0.2;  
            cfg.clusterstatistic = 'maxsum';   
            cfg.minnbchan        = 1;     
            cfg.tail             = 0;         
            cfg.clustertail      = 0;
            cfg.alpha            = 0.25;
            cfg.numrandomization = 10000;
            cfg.neighbours    = neighbours; 
            cfg.latency     = latency;
            n_fc  = size(timelockFC.trial, 2);
            n_fic = size(timelockFIC.trial, 2);
            cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
            cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)
            [stat] = ft_timelockstatistics(cfg, timelockFIC, timelockFC);
            save(sprintf("%s",stat_file_string), '-struct', 'stat');
            metadata.ft_timelockstatistics =  stat.cfg;
        
            %plot
            % cfg.toi makes sure to plot also the baseline timeperiod
            timediff = cond1_struct.time{1}(2) - cond1_struct.time{1}(1);
            toi = latency(1): timediff :latency(2);
            if is_plot_topoplot
                filename = erase(stat_file_string,".mat");
                cfg = funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,filename);
                metadata.cfg_ft_clusterplot =  cfg;
            end
        end
        
        % Electrods Cluster between conditions. per timepoint all subjects
        function metadata = cluster_dependentT(f,cond1_struct, cond2_struct,latency,mat_filename,is_plot_topoplot)
            subs = f.imp.get_subs(f.imp);
            neighbours = f.imp.get_neighbours(f.imp);

            metadata = {};
            cfg = [];
            cfg.latency     = latency;
            Nsub = size(subs,2);
            cfg.numrandomization = 10000;
            
            cfg.neighbours  = neighbours; % defined as above
            cfg.avgovertime = 'no';
            cfg.parameter   = 'avg';
            cfg.method      = 'montecarlo';
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.correctm    = 'cluster';
            cfg.correcttail = 'prob';
            cfg.minnbchan        = 1;      % minimal number of neighbouring channels
            
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            
            stat = ft_timelockstatistics(cfg,cond1_struct{:}, cond2_struct{:});
            save(sprintf("%s",mat_filename), '-struct', 'stat');
            metadata.ft_timelockstatistics =  stat.cfg;

            is_cluster_exists = false;
            if isfield(stat, "posclusters")
                pos_prob = [stat.posclusters.('prob')];
                if  pos_prob(1)<=0.2
                    is_cluster_exists = true;
                end
            end
            if isfield(stat, "negclusters")
                neg_prob = [stat.negclusters.('prob')];
                if  neg_prob(1)<=0.2
                    is_cluster_exists = true;
                end
            end
            
            % plot
            if is_plot_topoplot
                filename = erase(mat_filename,".mat");
                summary_filename = sprintf("%s_summary",filename);
                if is_cluster_exists
                    timediff = 0.004;
                    toi = latency(1): timediff :latency(2);
                    cfg = funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,filename);
                    metadata.cfg_ft_clusterplot =  cfg;
    
                    timediff = 0.04;
                    toi = latency(1): timediff :latency(2);
                    funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,summary_filename);
                else
                    timediff = 0.04;
                    toi = latency(1): timediff :latency(2);
                    cfg = funcs_spatioTemporalAnalysis.topo_plot(stat,toi,summary_filename);
                end
            end
        end

        % sov is only relevant if one of the conds are bl. Otherwise,
        % ignore it.
        function stat = cluster_permu_erp(f,conds,clust_mask,latency,sov)
            subs = f.imp.get_subs(f.imp);
            all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
            for cond_j = 1:size(conds,2)
                if strcmp(conds{cond_j},'interblock')
                    curr_cond_timelock = f.imp.get_cond_timelockedBl_interblock(f.imp,sov);
                else
                    curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_j},sov); 
                end
                
                for sub_i = 1:size(subs,2)
                    curr_subcond = curr_cond_timelock{sub_i};
                    curr_subcond = rmfield(curr_subcond,'dof');
                    curr_subcond = rmfield(curr_subcond,'var');
                    curr_subcond.label = {'eletd_avg'};
                    if size(clust_mask,2) == 1 % there is only electrodes
                        %curr_subcond.var = std(curr_subcond.avg(clust_mask,:),1,1);
                        curr_subcond.avg = mean(curr_subcond.avg(clust_mask,:),1);
                    else % theres time-electorde
                        avg_clusterMasked = curr_subcond.avg .* clust_mask;
                        sub_clust_activity_mean = sum(avg_clusterMasked,1) ./ sum(avg_clusterMasked~=0,1);
                        curr_subcond.avg = sub_clust_activity_mean;
                    end
                    all_conds_timelocked_currClustElecd{cond_j}{sub_i} = curr_subcond;
                end
            end
        
            % cluster permutation anaslysis 
            % define the parameters for the statistical comparison
            cfg = [];
            cfg.channel     = {'eletd_avg'};
            cfg.latency     = latency;
            cfg.avgovertime = 'no';
            cfg.parameter   = 'avg';
            cfg.method      = 'montecarlo';
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.numrandomization = 10000;
            cfg.alpha       = 0.05;
            cfg.correctm = 'cluster'; %'no';            
            Nsub = size(subs,2);
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{1}{:}, all_conds_timelocked_currClustElecd{2}{:});   % don't forget the {:}!
        end

        % plotting

        function cfg = cluster_plot(stat,toi,filename)
            % make a plot
            cfg = [];
            cfg.zlim = [-5 5];
            cfg.alpha = 0.2; % This is the max alpha to be plotted. (0.3 is the hights value possible)
            cfg.saveaspng = filename;
            cfg.visible = 'no';
            cfg.toi =toi;
            %cfg.highlightsymbolseries   =[0.01 0.05 0.1 0.2 0.3]; %1x5 vector, highlight marker symbol series (default ['*', 'x', '+', 'o', '.'] for p < [0.01 0.05 0.1 0.2 0.3]
            cfg.highlightsizeseries     = [4 4 4 4 4];
             cfg.highlightcolorpos       = [0.3 0 0];
             cfg.highlightcolorneg       = [0 0 0.3];
            cfg = ft_clusterplot(cfg, stat); % i added saveas(gcf,sprintf("%s.png",filename)); etc to the function's code.

        end

        function cfg = topo_plot(preVsPoststim_res,toi,filename)
            cfg = [];
            cfg.xlim = toi;
            cfg.parameter = 'stat';
            cfg.zlim = [-5 5];
            cfg.comment  ='xlim';
            cfg.commentpos = 'middletop';
            cfg.colormap = 'parula';
            cfg  = ft_topoplotER(cfg,filename,preVsPoststim_res); %to enable saving you need to delete:"saveif ~ft_nargout don't return anything clear cfg end", and add "saveas(gcf,png_filename);" at the end and png_filename to the argument list
        end
    
        function custom_colormap = get_colormap_for_sovs(sovs)
            % Initialize the colormap cell array
            custom_colormap = zeros(numel(sovs),3);
        
            % Loop over each sleep stage in the input cell array
            for i = 1:numel(sovs)
                % Get the colormap for the current sleep stage with one shade
                custom_colormap(i,:) = get_colormap_for_sov(sovs{i}, 1);
            end
        end
        
        function custom_colormap = get_colormap_for_sov(sov, num_shades)
            % Define the color dictionary
            color_dict = containers.Map(...
                {'wake_morning', 'wake_night', 'N2', 'N3', 'REM', 'N1'}, ...
                {[0.5, 0.8, 1], [0, 0, 1], [1, 0.8, 0], [0, 1, 0], [1, 0, 0], [1, 0, 1]} ...
            );
        
            % Get the RGB color from the dictionary
            if isKey(color_dict, sov)
                color_ = color_dict(sov);
                custom_colormap = funcs_spatioTemporalAnalysis.create_custom_colormap(color_, num_shades);
            else
                error('Invalid sleep stage. Supported sleep stages are: wake_morning, wake_night, N2, N3, REM, N1');
            end
        end
        
        function custom_colormap = create_custom_colormap(color_, num_shades)
            % Create a colormap with the specified number of shades
            custom_colormap = zeros(num_shades, 3);
            
            % Linearly interpolate each color component (R, G, B) independently
            for i = 1:3
                custom_colormap(:, i) = linspace(0, color_(i), num_shades);
            end
        end
        
        function plot_erps(time_,variables_name,data,output_filename, var_colormap,varargin)
            p = inputParser;
            addRequired(p, 'time_'); addRequired(p, 'variables_name'); addRequired(p, 'data'); 
            addRequired(p, 'output_filename'); addRequired(p, 'var_colormap'); 

            addOptional(p, 'ylim_', []); addOptional(p, 'clust_electd', []); addOptional(p, 'subtitle_',""); addOptional(p, 'title_', "");
            addOptional(p, 'sig_timeranges',{}); addOptional(p, 'sig_timeranges_colormap',{});

            parse(p, time_,variables_name,data,output_filename, var_colormap,varargin{:});
            r = p.Results;

            figure();
        
            % plot variables lines
            one_div_sqrt_samp_size = 1/sqrt(size(r.data,1));
            for val_i=1:numel(r.variables_name)
                curr_var_val_name = num2str(r.variables_name{val_i});
        %       plot without errorbar        
        %       mean_subs = squeeze(mean(curr_clust_res(:,:,val_i),1));
        %       plot(time_X,mean_subs,'Color',custom_colormap(val_i,:),'DisplayName',curr_var_val_name);
                x = squeeze(r.data(:,:,val_i));
                % r.var_colormap need to keep being N x 3, N=#vars.
                shadedErrorBar2(r.time_,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',r.var_colormap(val_i,:),'DisplayName',curr_var_val_name},'patchSaturation',0.1);
                hold on;
            end
        
            % plot sig line
            for i=1:numel(r.sig_timeranges)
                if ~isempty(r.sig_timeranges{i})
                    time_of_sig = r.time_(find(r.sig_timeranges{i}));
                    sig_line_height =   r.ylim_(1) + ((r.ylim_(2) - r.ylim_(1)) / 8) - ((i-1) * 0.05);
                    curr_colormap = r.sig_timeranges_colormap{i};
                    plot(time_of_sig,sig_line_height*ones(numel(time_of_sig)),'Color',curr_colormap{1},'DisplayName','','HandleVisibility', 'off',LineWidth=1.5);
                    hold on;
                    plot(time_of_sig,sig_line_height*ones(numel(time_of_sig)),'Color',curr_colormap{2},'DisplayName','','HandleVisibility', 'off',LineWidth=1.5,LineStyle=':');
                    hold on;
                end
            end
           
            axis([r.time_(1) r.time_(end) r.ylim_(1) r.ylim_(2)]) 
            
            title(r.title_);
            subtitle(r.subtitle_);
            if numel(r.variables_name)<=6
                legend("Location","northwest","FontSize",10);
            end
            xlabel('Time (ms)')
            ylabel('µV')

            if ~isempty(r.clust_electd)
                axes('Position',[0.15 0.15 .2 .2])
                box on
                cfg = [];
                cfg.feedback    = 'no';
                %cfg.elec= clust_cond_preVsPoststim.elec;
                cfg.elec= r.clust_electd{1};
                layout = ft_prepare_layout(cfg);
                ft_plot_layout(layout,'label','no','box','no','chanindx',r.clust_electd{2},'pointsize',22);
            end
            
            saveas(gcf,sprintf("%s.png",r.output_filename));
            saveas(gcf,sprintf("%s.svg",r.output_filename));
            saveas(gcf,sprintf("%s.fig",r.output_filename));
            close;
        end

    end
end

