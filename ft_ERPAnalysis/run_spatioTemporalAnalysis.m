function run_spatioTemporalAnalysis(args_path)
    %% args set
    args = load(args_path);
    args = args.args;
    subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'}; %  args.subs;
    wake_files_name_suffix = "wake_morning";%args.wake_files_name_suffix;
    ft_cond_dir = args.ft_cond_dir;
    bl = args.bl;
    contrasts = {{'ORsenBig5','OFsenBig5'},{'ORsenSmall6','OFsenSmall6'}};%args.contrasts;
    pre_vs_post_conds_names = {"O"}; %args.pre_vs_post_conds_names;
    output_main_dir = args.output_main_dir;
    %%

    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
    restoredefaultpath
    addpath(sprintf('%s\\fieldtrip-20230223', args.libs_dir))
    ft_defaults
    addpath(sprintf('%s\\eeglab2023.0', args.libs_dir))
    addpath(args.libs_dir)
    addpath(args.code_dir)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    cond_rand_name ='O';
    imp = ft_importer(subs,ft_cond_dir,bl,wake_files_name_suffix); 
    neig = imp.get_neighbours(imp);
    timelock = imp.get_cond_timelocked(imp,cond_rand_name);
    electrodes = timelock{1}.label;
    time = timelock{1}.time;
    time0_ind = find(time == 0, 1);
    time_from0 = time(time0_ind:end);
    f = funcs_spatioTemporalAnalysis(imp, electrodes,time);
    
    cond1_Vs_cond2_dir = sprintf('%s\\%s\\cond1_Vs_cond2',output_main_dir,wake_files_name_suffix);
    pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,wake_files_name_suffix);
    dir_baseline_erp = sprintf('%s\\%s\\baseline_erp',output_main_dir,wake_files_name_suffix);
    persub_output_dir = sprintf("%s\\%s\\per_sub_electrode",output_main_dir,wake_files_name_suffix);
    mkdir(cond1_Vs_cond2_dir);
    mkdir(pre_vs_poststim_dir);
    mkdir(dir_baseline_erp);
    mkdir(persub_output_dir);
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    Analysis                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Cond1 VS Cond2 - subjects mean
    plot_topoplot = true;
    f.spatiotempoClustPerm_cond1VsCond2_subAvg(f,cond1_Vs_cond2_dir, contrasts,plot_topoplot)
    
    %% Cond1 VS Cond2 - per subject
%     plot_topoplot = false;
%     f.spatiotempoClustPerm_cond1VsCond2_perSub(f,cond1_Vs_cond2_dir, contrasts, plot_topoplot)
    
    %% baseline vs activity - subjects mean
    plot_topoplot = true;
    f.spatiotempoClustPerm_baselineVsActivity_subAvg(f,pre_vs_poststim_dir, pre_vs_post_conds_names,plot_topoplot)

    %% baseline vs activity  - per subject
%     plot_topoplot = false;
%     f.spatiotempoClustPerm_baselineVsActivity_perSub(f,pre_vs_poststim_dir, pre_vs_post_conds_names,plot_topoplot)
%     

    %% baseline_avgAndStd_allElectd
%     f.baseline_avgAndStd_allElectd(f,pre_vs_post_conds_names)
    %% Is the baseline activity signigicantly different than 0
%     f.plot_and_test_basline_different_that_0(f,pre_vs_post_conds_names,dir_baseline_erp)
    
    %% Explore clusters deviancy
    % % % cond1_text =  'O';
    % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % % % 
    % % % preVsPoststim_cond  = load(sprintf("%s/preVsPoststim_bl-%d_%s.mat",preStim_Vs_postStim_dir,baseline_timerange,cond1_text));
    % % % stat = preVsPoststim_cond;
    % % % figure
    % % % subplot(4,1,1); plot(stat.time, stat.stat); ylabel('t-value');
    % % % subplot(4,1,3); semilogy(stat.time, stat.prob); ylabel('prob'); axis([0 0.5 0.001 2])
    % % % subplot(4,1,4); plot(stat.time, stat.mask); ylabel('significant'); axis([0 0.5  -0.1 1.1])
    % % % 
    % % % figure 
    % % % subplot(2,1,1); hist(stat.negdistribution, 200);% axis([-10 10 0 100])
    % % % for i=1:numel(stat.negclusters)
    % % %   X = [stat.negclusters(i).clusterstat stat.negclusters(i).clusterstat];
    % % %   Y = [0 100];
    % % %   line(X, Y, 'color', 'r')
    % % % end
    % % % 
    % % % subplot(2,1,2); hist(stat.posdistribution, 200); %axis([-10 10 0 100])
    % % % 
    % % % for i=1:numel(stat.posclusters)
    % % %   X = [stat.posclusters(i).clusterstat stat.posclusters(i).clusterstat];
    % % %   Y = [0 100];
    % % %   line(X, Y, 'color', 'r')
    % % % end
    
    %% print_clusters_probability per subject
%     f.print_clusters_probability(f,contrasts,cond1_Vs_cond2_dir)
    
    %% Common time-electrodes matrix for every subjects cond1 vs. cond2 cluster test
    
%     f.timeElectedMatrix_perCond1VsCond2Cluster(f,contrasts,cond1_Vs_cond2_dir)

    %%%%%%%%% Given allSub_masksSum, it plotes topographys for every 100ms  %%%%%%
    % % % [imp,grandAvg_cond] = imp.get_cond_grandAvg(imp,cond_rand_name);
    % % % for i=1:5
    % % %     cfg=[];
    % % %     cfg.colorbar = 'yes'; 
    % % %     grandAvg_cond = rmfield(grandAvg_cond,["dof","var"]);
    % % %     grandAvg_cond.label = grandAvg_cond.label(1:92);
    % % %     starttime_i = time0_ind+((i-1)*25);
    % % %     if i<5
    % % %         endtime_i = time0_ind+(i*25);
    % % %     else
    % % %         endtime_i = size(time,2);
    % % %     end
    % % %     cfg.zlim = [0 3.5];
    % % %     grandAvg_cond.avg = allSub_masksSum(:,starttime_i:endtime_i);
    % % %     grandAvg_cond.time = time(starttime_i:endtime_i);
    % % %     ft_topoplotER(cfg, grandAvg_cond)
    % % %     saveas(gcf, sprintf("%s/%svs%s_ElecdAvgClustPervelance_bl-%d_time-[%.2f-%.2f].png",cond1_Vs_cond2_dir,cond1_text,cond2_text,baseline_timerange,time(starttime_i),time(endtime_i)))
    % % % end
    

    %% load pre-post-stimuli cluster stats
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Get time-electodes clusters of cond O vs. baseline. Look for difference in OF vs. OR in that time-electrode range
    % with cluster permutatiton diff results
    
    %%%%%%%%%%%%%%%%
    for cont_i=1:size(contrasts,2)
        conds = {contrasts{cont_i}{1},contrasts{cont_i}{2},'O','T'};  % makes sure it's size 4 (cond1, cond2, O, T)

        cond_preVsPoststim = load(sprintf("%s\\preVsPoststim_bl-%d_%s_avg",pre_vs_poststim_dir,bl, 'O'));

        f.plot_OClusters_contrasts(f,conds,cond_preVsPoststim,pre_vs_poststim_dir,true)
        f.plot_OClusters_contrasts(f,conds,cond_preVsPoststim,pre_vs_poststim_dir,false)
    end
    
    %% Time permutation analysis for each electrode X subj
%     f.tempoClustPerm_cond1VsCond2_perSub(f,contrasts,persub_output_dir)
    
    %% Create a graph sums all sig. electrode X subj
%     f.plot_allSubs_electrodes_sig_range(f,contrasts,persub_output_dir)
%     f.plot_allSubs_electrodes_sig_range_omissionAvgElect(f,contrasts,persub_output_dir,pre_vs_poststim_dir)
%     f.plot_allSubs_electrodes_sig_range_omissionPerSubElect(f,contrasts,persub_output_dir,pre_vs_poststim_dir)
end

