addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs'
%% SINGLE SUB DIAGONAL decoding using random permutation

plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_resamp55_allSovs_subRandPerm';
results_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resamp55_allSovs_subRandPerm';
all_subsets = {'subset-wmorning', 'subset-wnight','subset-N1','subset-N2','subset-N3','subset-REM'};
all_subsets = {'subset-N2'};
all_contrasts = {'OF-vs-OR'};
acclim = [.465 .565];

% plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_resampNo';
% results_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resampNo';
% all_subsets = {'subset-wmorning', 'subset-wnight'};
% all_contrasts = {'T-vs-A'};
% acclim = [.465 .765];


for subset_i=1:numel(all_subsets)
    curr_subset = all_subsets{subset_i};
    for contrast_i=1:numel(all_contrasts)
       curr_contrast = all_contrasts{contrast_i};
       for isRightTail_i=1:2
           if isRightTail_i==1
                tail = 'right';
            else
                tail = 'both';
            end
            
            contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {curr_contrast}, 'UniformOutput', false);
            contrast_dir = sprintf('%s\\%s\\%s_%s',results_dir,curr_subset,curr_subset,curr_contrast);
            mvpa_stats=get_avgSubPerm_decoding(contrast_dir,tail);
            
            save_file_name = sprintf('%s_%s_PerSubDecodeComparePermu_diag-1_tail-%s',curr_subset,curr_contrast,tail);
            save_plot_and_close_fig(plot_dir,save_file_name)
             %plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timerange_weights_plot)

            plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
            save_file_name = sprintf('%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s',curr_subset,curr_contrast,tail);
            save_plot_and_close_fig(plot_dir,save_file_name)
       end
        save_file_name = sprintf('%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s_2',curr_subset,curr_contrast,tail);

        plot_subPerm_decoding(mvpa_stats,[0.35,0.7],contrasts_withsubset,plot_dir,save_file_name);

        plot_avgSubPerm_decoding(mvpa_stats,[0.35,0.7],contrasts_withsubset);
        
        save_plot_and_close_fig(plot_dir,save_file_name)
    end
end

%% Average decoding - states of vigi, all at once

plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_resampNo_allSovs';
results_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resampNo_allSovs';
all_subsets = {'subset-O'};
all_contrasts = {'wmorning-vs-wnight','wmorning-vs-N1','wmorning-vs-N2','wmorning-vs-N3','wmorning-vs-REM', ...
                'wnight-vs-N1','wnight-vs-N2','wnight-vs-N3','wnight-vs-REM', ...
                'N1-vs-N2','N1-vs-N3','N1-vs-REM',...
                'N2-vs-N3','N2-vs-REM',...
                'N3-vs-REM'};
timerange_test = 0; 

for isDiag_i=1:2
    if isDiag_i==1
        acclim = [.46 .57];
        isDiag = true;
    else
        acclim = [.445 .555]; % make is symmetrical around 0.5, so white will signify "chance"
        isDiag = false;
    end
    
    for isRightTail_i=1:2
        if isRightTail_i==1
            tail = 'right';
        else
            tail = 'both';
        end
        for subset_i=1:numel(all_subsets)
            curr_subset = all_subsets{subset_i};
            subset_dir = sprintf('%s\\%s',results_dir,curr_subset);
            mvpa_stats=get_avg_decoding(subset_dir, tail,isDiag,timerange_test); 
            for contrast_i=1:numel(all_contrasts)
                contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {all_contrasts{contrast_i}}, 'UniformOutput', false);
                plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
                save_file_name = sprintf('%s_%s_decode_diag-%d_tail-%s',curr_subset,all_contrasts{contrast_i},isDiag,tail);
                save_plot_and_close_fig(plot_dir,save_file_name)
                %plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timerange_weights_plot)
            end
        end
    end
end


%% Average decoding
% 
% plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_resampNo_allSovs_5fold';
% results_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resampNo_allSovs_5fold';
% all_subsets = {'subset-wnight','subset-wmorning','subset-N1','subset-N2','subset-N3','subset-REM'};
% all_contrasts = {'OF-vs-OR', 'OR-vs-OF'};

% plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_resampNo_allSovs_5fold';
% results_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resampNo_allSovs_5fold';
% all_subsets = {'subset-O'};
% all_contrasts = {'wmorning-vs-wnight','wmorning-vs-N1','wmorning-vs-N2','wmorning-vs-N3','wmorning-vs-REM', ...
%                 'wnight-vs-N1','wnight-vs-N2','wnight-vs-N3','wnight-vs-REM', ...
%                 'N1-vs-N2','N1-vs-N3','N1-vs-REM',...
%                 'N2-vs-N3','N2-vs-REM',...
%                 'N3-vs-REM'};

% results_dir = "C:\adam-loo";
% plot_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\PLOTS_loo_resampleNo';
% all_subsets = {'subset-wn','subset-wm','subset-N1','subset-N2','subset-N3','subset-REM'};%,
% all_contrasts = {'OF-vs-OR'};

timerange_weights_plot = [400 448];
timerange_test = 0;      % 0 if no, [250 400] if yes   

for isDiag_i=1:2
    if isDiag_i==1
        acclim = [.46 .57];
        isDiag = true;
    else
        acclim = [.445 .555]; % make is symmetrical around 0.5, so white will signify "chance"
        isDiag = false;
    end
    
    for isRightTail_i=1:2
        if isRightTail_i==1
            tail = 'right';
        else
            tail = 'both';
        end
        for subset_i=1:numel(all_subsets)
            curr_subset = all_subsets{subset_i};
            subset_dir = sprintf('%s\\%s',results_dir,curr_subset);
            mvpa_stats=get_avg_decoding(subset_dir, tail,isDiag,timerange_test); 
            for contrast_i=1:numel(all_contrasts)
                contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {all_contrasts{contrast_i}}, 'UniformOutput', false);
                plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
                save_file_name = sprintf('%s_%s_decode_diag-%d_tail-%s',curr_subset,all_contrasts{contrast_i},isDiag,tail);
                save_plot_and_close_fig(plot_dir,save_file_name)
                %plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timerange_weights_plot)
            end
            if numel(all_contrasts) >1 % plot all in one png
%                     contrasts_withsubset = cellfun(@(x) [subset_name, '_', x], all_contrasts, 'UniformOutput', false);
%                     plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
%                     save_file_name = sprintf('%s_%s_decode_diag-%d_tail-%s',subset_name,'all',isDiag,tail);
%                     save_plot_and_close_fig(plot_dir,save_file_name)
%                     %plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timerange_weights_plot)
            end
        end
    end
end

%% COMPARE 2 subsets difference STATS
cfg = [];                                    % clear the config variable
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
meg_vs_eeg_stats = adam_compare_MVPA_stats(cfg,subset1_stats,subset2_stats);

cfg = [];                                    % clear the config variable
%cfg.plot_order = {'EEG_wmorning_OF_VS_OR' 'EEG_wnight_OF_VS_OR' ,'EEG_w_OF_VS_OR'};
adam_plot_MVPA(cfg, meg_vs_eeg_stats);       % actual plotting

%save
save_file_name = sprintf('%s-vs-%s_differnce',subset1_name,subset2_name);
save_plot_and_close_fig(plot_dir,save_file_name)

%% Functions

function mvpa_stats=get_avgSubPerm_decoding(dir,tail)
    cfg = [];                                % clear the config variable
    cfg.wanted_dir = dir;           % path to first level results 
    cfg.reduce_dims = 'diag';
    cfg.plotsubjects = true;
    cfg.mpcompcor_method = 'fdr';
    cfg.compute_randperm = true;
    cfg.tail = tail;
    mvpa_stats = adam_compute_group_MVPA(cfg);
end

function plot_avgSubPerm_decoding(mvpa_stats,acclim,title_)
    addpath('C:\Users\User\Cloud-Drive\BigFiles\libs');
    indi_over_time = mvpa_stats.indivClassOverTime;
  
    time = mvpa_stats.settings.times{1};
    shadedErrorBar2(time,mvpa_stats.indivClassOverTime,{@mean,@std},'patchSaturation',0.1)%,'lineprops','-b');
    hold on;
    plot(time,indi_over_time,'Color',[0 ,0, 0, 0.2]);
    hold on;
    plot(time,mvpa_stats.ClassOverTime,'Color',[0, 0, 0, 1]);
    xlim([time(1),time(end)]);
    if acclim ~=0
        ylim(acclim);
    end
    title(title_);
    xlabel("time (s)");
    ylabel("AUC");
    set(gcf,'Position',[100 100 600 300])
end

function plot_subPerm_decoding(mvpa_stats,acclim,title_,plot_dir,save_file_name_prefix)
    indi_over_time = mvpa_stats.indivClassOverTime;
    pvals_indi_over_time = mvpa_stats.pvalsOverTime;
    time = mvpa_stats.settings.times{1};
    for i=1:size(indi_over_time,1)
        plot(time,indi_over_time(i,:),'Color',[0, 0, 0, 1]);
        for j=1:numel(time)
           if pvals_indi_over_time(i,j) <= 0.05
               hold on;
               plot(time(j), indi_over_time(i,j), '.','color','black','MarkerSize',13); 
           end
        end

        xlim([time(1),time(end)]);
        if acclim ~=0
            ylim(acclim);
        end
        title(sprintf("%s, subINDEX-%d",title_{1}, i));
        xlabel("time (s)");
        ylabel("AUC");
        set(gcf,'Position',[100 100 600 300])
        save_file_name = sprintf("%s_subINDEX-%d",save_file_name_prefix,i);
        save_plot_and_close_fig(plot_dir,save_file_name)
    end
end

function mvpa_stats=get_avg_decoding(dir,tail,isDiag,timerange)
    % COMPUTE THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
    cfg = [];                                    % clear the config variable
    cfg.wanted_dir = dir;           % path to first level results 
    cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
    if isDiag
        cfg.reduce_dims = 'diag';                    % train and test on the same points
    end
    cfg.tail             = tail;
    if timerange
        cfg.trainlim = timerange;                    % specify a 250-400 ms interval in the training data
        cfg.reduce_dims = 'avtrain';                 % average over that training interval 
    end

    mvpa_stats = adam_compute_group_MVPA(cfg);
end

function plot_decoding(plot_order,mvpa_stats,acclim)
    % PLOT THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
    cfg = [];                                    % clear the config variable
    cfg.plot_order = plot_order;
    cfg.singleplot = true;                       % all erps in a single plot
    cfg.acclim =acclim;                        % change the y-limits of the plot
    cfg.figure_size = [600,400];
    %cfg.splinefreq = lp_smoothing; % just dont. Andres "Its dodgy"
    adam_plot_MVPA(cfg, mvpa_stats);             % actual plotting
end

function plot_timerange_activation_pattern(plot_order,mvpa_stats,timerange)
    cfg = [];                                    % clear the config variable
    cfg.plot_order = plot_order;
    cfg.mpcompcor_method = 'cluster_based';      % amultiple comparison correction method. 
    cfg.plotweights_or_pattern = 'weights';  % covariance activation pattern cAN BE: 'weights', 'covpattern' or 'corpattern'
    %cfg.weightlim = [-3 3];                  % set common scale to all plots
    if timerange
        cfg.timelim = timerange;                    % time window to visualize
    end
    adam_plot_BDM_weights(cfg,mvpa_stats);       % actual plotting
end



function save_plot_and_close_fig(folder,file_name)
    saveas(gcf, sprintf("%s\\%s.fig", folder, file_name));
    saveas(gcf, sprintf("%s\\%s.svg", folder, file_name));
    saveas(gcf, sprintf("%s\\%s.png", folder, file_name));
    close(gcf);
end


%%%%%%%%%%%%%%%%%%%

% %% ERP PLOT
% %configure
% electrodes_def = {'E2','E3'};
% contrast = 'OF-vs-OR'; 
% subset_name = 'subset-wn';
% 
% % compute
% contrast_dir = sprintf('%s\\%s\\%s_%s',results_dir,subset_name,subset_name,contrast);
% erp_plot(electrodes_def,contrast_dir);
% 
% % save
% save_file_name = sprintf('%s_erp',sprintf('%s_%s',subset_name,contrast));
% save_plot_and_close_fig(plot_dir,save_file_name)
% %% ERP DIFF
% %configure
% subset_name = 'subset-N2';
% electrodes_def = {'E2','E3'};
% contrasts = {'T-vs-A' 'OF-vs-OR' 'OFSmall6-vs-ORSmall6' 'OFBig5-vs-ORBig5'};
% contrasts = {'OF-vs-OR'};
% 
% % compute
% subset_dir = sprintf('%s\\%s',results_dir,subset_name);
% contrasts_withsubset = cellfun(@(x) [subset_name, '_', x], contrasts, 'UniformOutput', false);
% erp_diff_plot(subset_dir,electrodes_def,contrasts_withsubset)
% 
% % save
% contrasts_str = strjoin(contrasts, ', ');
% contrasts_str = ['{', contrasts_str, '}'];
% save_file_name = sprintf('%s_%s_erpDiff',subset_name,contrasts_str);
% save_plot_and_close_fig(plot_dir,save_file_name)
% 
% 
% function ftr_plot(electrodes,contrast_dir)
%     cfg = [];                                    % clear the config variable
%     cfg.wanted_dir = contrast_dir;
%     cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
%     cfg.electrode_def = electrodes;                 % electrode to plot
%     cfg.electrode_method = 'average';
%     erp_stats = adam_compute_group_ERP(cfg);     % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up
%     
%     % COMPUTE THE DIFFERENCE BETWEEN THE ERPs FROM THE EEG_NONFAM_VS_SCRAMBLED FIRST LEVEL ANALYSIS
%     cfg = [];                                    % clear the config variable
%     cfg.wanted_dir = contrast_dir;
%     cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
%     cfg.electrode_def = electrodes;         % electrode to plot
%     cfg.electrode_method = 'average';
%     cfg.condition_method = 'subtract';           % compute subtraction of ERP 
%     erp_stats_dif = adam_compute_group_ERP(cfg); % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up
%     
%     % PLOT THE ERPs AND THEIR DIFFERENCE IN A SINGLE PLOT
%     cfg = [];                                    % clear the config variable
%     cfg.singleplot = true;                       % all graphs in a single plot
%     cfg.line_colors = {[.75 .75 .75] [.5 .5 .5] [0 0 .5]};  % change the colors
%     adam_plot_MVPA(cfg, erp_stats, erp_stats_dif);   % actual plotting
% 
% end
% 
% function erp_plot(electrodes,contrast_dir)
%     cfg = [];                                    % clear the config variable
%     cfg.wanted_dir = contrast_dir;
%     cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
%     cfg.electrode_def = electrodes;                 % electrode to plot
%     cfg.electrode_method = 'average';
%     erp_stats = adam_compute_group_ERP(cfg);     % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up
%     
%     % COMPUTE THE DIFFERENCE BETWEEN THE ERPs FROM THE EEG_NONFAM_VS_SCRAMBLED FIRST LEVEL ANALYSIS
%     cfg = [];                                    % clear the config variable
%     cfg.wanted_dir = contrast_dir;
%     cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
%     cfg.electrode_def = electrodes;         % electrode to plot
%     cfg.electrode_method = 'average';
%     cfg.condition_method = 'subtract';           % compute subtraction of ERP 
%     erp_stats_dif = adam_compute_group_ERP(cfg); % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up
%     
%     % PLOT THE ERPs AND THEIR DIFFERENCE IN A SINGLE PLOT
%     cfg = [];                                    % clear the config variable
%     cfg.singleplot = true;                       % all graphs in a single plot
%     cfg.line_colors = {[.75 .75 .75] [.5 .5 .5] [0 0 .5]};  % change the colors
%     adam_plot_MVPA(cfg, erp_stats, erp_stats_dif);   % actual plotting
% 
% end
% 
% function erp_diff_plot(subset_dir,electrodes,plot_order)
%     % COMPUTE THE DIFFERENCE ERPs OF ALL EEG COMPARISONS
%     cfg = [];                                    % clear the config variable
%     cfg.wanted_dir = subset_dir;          % path to first level results 
%     cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
%     cfg.electrode_def = electrodes;                 % electrode to plot
%     cfg.electrode_method = 'average';
%     cfg.condition_method = 'subtract';           % compute group ERPs of individual conditions 
%     erp_stats_dif = adam_compute_group_ERP(cfg); 
%     
%     % PLOT THE DIFFERENCE ERPs OF ALL COMPARISONS
%     cfg = [];                                    % clear the config variable
%     cfg.plot_order = plot_order;
%     cfg.singleplot = true;                       % all erps in a single plot
%     %cfg.acclim = [-9 3];                         % change the y-limits of the plot
%     adam_plot_MVPA(cfg, erp_stats_dif);          % actual plotting
%     
%     % INSPECTING THE STATS STRUCTURE TO FIND ONSET AND PEAK TIMES
%     erp_stats_dif(3)
%     erp_stats_dif(3).pStruct
%     erp_stats_dif(3).pStruct.negclusters
% end

