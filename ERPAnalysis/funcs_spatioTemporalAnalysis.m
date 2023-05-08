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
            cfg.numrandomization = 1000;
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

                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd.png",persub_output_dir,cond1_name,cond2_name);
                if isfile(curr_output_filename) continue; end

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
                saveas(gcf, curr_output_filename)
            end
        end
        
        function plot_allSubs_electrodes_sig_range_omissionPerSubElect(f,contrasrs,persub_output_dir,pre_vs_poststim_dir)
           subs = f.imp.get_subs(f.imp);
           bl = f.imp.get_baseline_length(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1_name = contrasrs{contrast_ind}{1};
                cond2_name = contrasrs{contrast_ind}{2};
        
                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd_omissionAvgElect.png",persub_output_dir,cond1_name,cond2_name);
                if isfile(curr_output_filename) continue; end
        
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
                saveas(gcf, curr_output_filename)
            end
        end

        function plot_allSubs_electrodes_sig_range_omissionAvgElect(f,contrasrs,persub_output_dir,pre_vs_poststim_dir)
            subs = f.imp.get_subs(f.imp);
            bl = f.imp.get_baseline_length(f.imp);
            time0_ind = find(f.time == 0, 1);
            for contrast_ind=1:size(contrasrs,2)
                cond1_name = contrasrs{contrast_ind}{1};
                cond2_name = contrasrs{contrast_ind}{2};
        
                curr_output_filename = sprintf("%s\\%svs%s_summary-allSubElectd_omissionPerSubElect.png",persub_output_dir,cond1_name,cond2_name);
                if isfile(curr_output_filename) continue; end
            
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
                saveas(gcf, curr_output_filename)
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
                        curr_output_filename = sprintf("%s//clustCond-%s_contrast-%svs%s_bl-%d_clustInd-%d%s_PerSub.png",pre_vs_poststim_dir,bl_cond_text,cond1_text,cond2_text,bl,clust_ind,pos_or_neg_text);
                        if isfile(curr_output_filename) continue; end
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
                            shadedErrorBar(x,y1,{@mean,@std},'lineprops','-b','patchSaturation',0.2); 
                            shadedErrorBar(x,y2,{@mean,@std},'lineprops','-r','patchSaturation',0.2); 
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
                        saveas(fig, curr_output_filename)
                    end
                end
            end
        end

        %%%%%%%%%%%%%%%%%%%% spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function spatiotempoClustPerm_baselineVsActivity_subAvg(f,output_dir, conds_names,plot_topoplot)   
            bl = f.imp.get_baseline_length(f.imp);
            for cond_i = 1:size(conds_names,2)
                curr_output_filename = sprintf("%s\\preVsPoststim_bl-%d_%s_avg.mat",output_dir,bl,conds_names{cond_i});
                if isfile(curr_output_filename) continue; end
                timelock_cond = f.imp.get_cond_timelocked(f.imp,conds_names{cond_i});
                timelockBl_cond = f.imp.get_cond_timelockedBl(f.imp,conds_names{cond_i});
                metadata = funcs_spatioTemporalAnalysis.cluster_dependentT(f,timelockBl_cond, timelock_cond,[-0.1,0.45],curr_output_filename,plot_topoplot);
            end
            if exist("metadata","var")
                save(sprintf("%s//preVsPoststim-bl-%d_metadata",output_dir,bl), "metadata")
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
        %%%%%%%%%%%%%%%%%%%% TEST - spatio-temporal cluster permutation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function plot_and_test_basline_different_that_0(f,conds_names,dir_baseline_erp)
            subs = f.imp.get_subs(f.imp);
            neig = f.imp.get_neighbours(f.imp);
            time0_ind = find(f.time == 0, 1);
            for cond_i= 1:size(conds_names,2)
                curr_output_filename = sprintf("%s//Cond-%s_baseline_perSub_allelectd.png",dir_baseline_erp, conds_names{cond_i});
                if isfile(curr_output_filename) continue; end

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
                saveas(gcf, curr_output_filename)
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
        
        function timeElectedMatrix_perCond1VsCond2Cluster(f,contrasrs,cond1_Vs_cond2_dir)
            subs = f.imp.get_subs(f.imp);
            for contrast_ind=1:size(contrasrs,2)
                cond1_text = contrasrs{contrast_ind}{1};
                cond2_text = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s//%svs%s_prevelenceInSpatiotemporalCluster.png",cond1_Vs_cond2_dir,cond1_text,cond2_text);
                if isfile(curr_output_filename) continue; end

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
                saveas(gcf, curr_output_filename)
            end
        end
        
        function plot_OClusters_contrasts(f,conds,conds_preVsPoststim,dir_clusters_erp,is_with_timeElectrode_lines)
            subs = f.imp.get_subs(f.imp);
            bl = f.imp.get_baseline_length(f.imp);
            for pos_neg_ind=1:2
                if pos_neg_ind ==1
                    clusters = {conds_preVsPoststim.(conds{3}).posclusters.prob};
                    clust_mask = conds_preVsPoststim.(conds{3}).posclusterslabelmat;
                    title_text = sprintf("PreVsPoststim %s - positive clusters",conds{3});
                    pos_or_neg_text = 'pos';
                else
                    clusters = {conds_preVsPoststim.(conds{3}).negclusters.prob};
                    clust_mask = conds_preVsPoststim.(conds{3}).negclusterslabelmat;
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
                    curr_output_filename = sprintf("%s//clustCond-%s_contrast-%svs%s_bl-%d_clustInd-%d%s_%s.png",dir_clusters_erp,conds{3},conds{1},conds{2},bl,clust_ind,pos_or_neg_text,is_with_timeElectrode_lines_string);
                    if isfile(curr_output_filename) continue; end
                    
                    % get time-electrode mask for current cluster
                    curr_clust_mask = clust_mask;
                    curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                    curr_clust_mask(curr_clust_mask ~= 0) = 1;
                    temp = mean(curr_clust_mask,2);
                    clust_electd = find(temp>0);
                    temp = mean(curr_clust_mask,1);
                    clust_times = find(temp>0);
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
                        shadedErrorBar(f.time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',FOROO_colors{1},'DisplayName',sprintf("%s-cluster electrode",conds{1})},'patchSaturation',0.2);
                        hold on;
                        x = squeeze(allSubs_conds_AvgActivity(2,:,:));
                        shadedErrorBar(f.time,squeeze(allSubs_conds_AvgActivity(2,:,:)),{@mean,@(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',FOROO_colors{2},'DisplayName',sprintf("%s-cluster electrode",conds{2})},'patchSaturation',0.2);
                        hold on;
                        plot(f.time, mean_activity_per_cond_clustSpace(3,:)','DisplayName',sprintf("%s-cluster electrode",conds{3}),'Color',FOROO_colors{3})
                    end
                    % plot T 
                    plot(f.time, mean_activity_per_cond_clustSpace(4,:)','DisplayName',sprintf("%s-cluster electrode",conds{4}),'Color','black')
                    % plot sig points
                    if ~all(stat.mask ==0)
                        mask_in_trial = zeros(size(f.time,2),1);
                        mask_in_trial(clust_times(1):clust_times(end)) = stat.mask; 
                        plot(f.time(find(mask_in_trial)),mean_activity_per_cond_clustSpace(3,find(mask_in_trial)),'.', 'DisplayName', sprintf('%s vs. %s - electrode',conds{1},conds{2}),"Color",'black',"MarkerSize",8)
                    end

                    electrods_string = join({conds_preVsPoststim.(conds{3}).label{clust_electd}},",");
                    electrods_string = erase(electrods_string,"E");
                    electrods_string = electrods_string{1};
                    title(sprintf("%s, clust ind=%d, pval=%f, baseline=%dms",title_text,clust_ind,clusters{clust_ind},bl), ...
                        sprintf("%d Electrodes: %s\n%s",size(clust_electd,1),electrods_string(1:round(size(electrods_string,2)/2)),electrods_string(round(size(electrods_string,2)/2)-1:end)),"FontSize",8);
                    legend("Location","northeast","FontSize",5);
                    if pos_neg_ind ==1
                        axis([f.time(1) f.time(end) -0.8 0.2]) %axis([time(1) time(end) -1 1.5])
                    else
                        axis([f.time(1) f.time(end) -0.2 0.8]) %axis([time(1) time(end) -1 1.5])
                    end
                    xlabel('Time (s)')
                    ylabel('µV')
                    saveas(gcf, curr_output_filename)

                    % plot the clusters electrodes topography
                    figure();
                    cfg = [];
                    cfg.feedback    = 'no';
                    elec = ft_read_sens('GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'
                    cfg.elec=elec;
                    layout = ft_prepare_layout(cfg);
                    ft_plot_layout(layout,'label','no','box','no','chanindx',clust_electd,'pointsize',11);
                    saveas(gcf, sprintf("%s_topography.png",erase(curr_output_filename,".png")))            
                end
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
            cfg.numrandomization = 1000;
            cfg.neighbours    = neighbours; 
            cfg.latency     = latency;
            n_fc  = size(timelockFC.trial, 2);
            n_fic = size(timelockFIC.trial, 2);
            cfg.design           = [ones(1,n_fic), ones(1,n_fc)*2]; % design matrix
            cfg.ivar             = 1; % number or list with indices indicating the independent variable(s)
            [stat] = ft_timelockstatistics(cfg, timelockFIC, timelockFC);
            save(sprintf("%s",stat_file_string), '-struct', 'stat');
            metadata.ft_timelockstatistics =  stat.cfg;
        
            if all(stat.mask == 0)
                return
            end
        
            %plot
            % cfg.toi makes sure to plot also the baseline timeperiod
            timediff = cond1_struct.time{1}(2) - cond1_struct.time{1}(1);
            toi = latency(1): timediff :latency(2);
            if is_plot_topoplot
                png_filename = erase(stat_file_string,".mat");
                cfg = funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,png_filename);
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
        
            % plot
            if is_plot_topoplot
                timediff = 0.04;
                toi = latency(1): timediff :latency(2);
                png_filename = erase(mat_filename,".mat");
                cfg = funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,png_filename);
                metadata.cfg_ft_clusterplot =  cfg;
            end
        end
        
        function stat = cluster_permu_erp(f,conds,clust_mask,latency)
            subs = f.imp.get_subs(f.imp);
            all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
            for cond_j = 1:size(conds,2)
                curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_j}); 
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
            cfg.method      = 'analytic';
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.alpha       = 0.05;
            cfg.correctm    = 'no';            
            Nsub = size(subs,2);
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{1}{:}, all_conds_timelocked_currClustElecd{2}{:});   % don't forget the {:}!
        end
        
        function cfg = cluster_plot(stat,toi,png_filename)
            % make a plot
            cfg = [];
            %cfg.highlightsymbolseries = ['*','.','.','.','.']; %%  (default ['*', 'x', '+', 'o', '.'] for p < [0.01 0.05 0.1 0.2 0.3]
            cfg.highlightsizeseries     = [5,4,4,4,4];  %1x5 vector, highlight marker size series   (default [6 6 6 6 6] for p < [0.01 0.05 0.1 0.2 0.3])
            cfg.zlim = [-5 5];
            cfg.alpha = 0.2; % This is the max alpha to be plotted. (0.3 is the hights value possible)
            cfg.saveaspng = png_filename;
            cfg.visible = 'no';
            cfg.toi =toi;
            cfg = ft_clusterplot(cfg, stat);
        end
    end
end

