%% COMPUTE RAW GROUP ERPs FROM THE EEG_NONFAM_VS_SCRAMBLED FIRST LEVEL ANALYSIS
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.electrode_def = {'E2','E3','E4','E5','E9','E10','E11','E12','E13','E15','16','E18','E19','E20','E22','E23','E24','E26','E27','E28','E110','E111','E116','E117','E118','E123','E124'};         % electrode to plot
cfg.electrode_method = 'average';
erp_stats = adam_compute_group_ERP(cfg);     % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up

%% COMPUTE THE DIFFERENCE BETWEEN THE ERPs FROM THE EEG_NONFAM_VS_SCRAMBLED FIRST LEVEL ANALYSIS
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.electrode_def = {'E2','E3','E4','E5','E9','E10','E11','E12','E13','E15','16','E18','E19','E20','E22','E23','E24','E26','E27','E28','E110','E111','E116','E117','E118','E123','E124'};         % electrode to plot
cfg.electrode_method = 'average';
cfg.condition_method = 'subtract';           % compute subtraction of ERP 
erp_stats_dif = adam_compute_group_ERP(cfg); % select EEG_NONFAM_VS_SCRAMBLED when dialog pops up

%% PLOT THE ERPs AND THEIR DIFFERENCE IN A SINGLE PLOT
cfg = [];                                    % clear the config variable
cfg.singleplot = true;                       % all graphs in a single plot
cfg.line_colors = {[.75 .75 .75] [.5 .5 .5] [0 0 .5]};  % change the colors
adam_plot_MVPA(cfg, erp_stats, erp_stats_dif);   % actual plotting

%% COMPUTE THE DIFFERENCE ERPs OF ALL EEG COMPARISONS
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.electrode_def = {'E2','E3','E4','E5','E9','E10','E11','E12','E13','E15','16','E18','E19','E20','E22','E23','E24','E26','E27','E28','E110','E111','E116','E117','E118','E123','E124'};                 % electrode to plot
cfg.electrode_method = 'average';
cfg.condition_method = 'subtract';           % compute group ERPs of individual conditions 
erp_stats_dif = adam_compute_group_ERP(cfg); % select EEG_RAW when dialog pops up 

%% PLOT THE DIFFERENCE ERPs OF ALL COMPARISONS
cfg = [];                                    % clear the config variable
%cfg.plot_order = {'EEG_wmorning_OF_VS_OR' 'EEG_wnight_OF_VS_OR' ,'EEG_w_OF_VS_OR'};
cfg.singleplot = true;                       % all erps in a single plot
cfg.acclim = [-9 3];                         % change the y-limits of the plot
adam_plot_MVPA(cfg, erp_stats_dif);          % actual plotting

%% INSPECTING THE STATS STRUCTURE TO FIND ONSET AND PEAK TIMES
erp_stats_dif(3)
erp_stats_dif(3).pStruct
erp_stats_dif(3).pStruct.negclusters

%% COMPUTE THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.reduce_dims = 'diag';                    % train and test on the same points
mvpa_stats = adam_compute_group_MVPA(cfg);   % select RAW_EEG when dialog pops up

%% PLOT THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
cfg = [];                                    % clear the config variable
cfg.plot_order = {'OF-vs-OR'};
cfg.singleplot = true;                       % all erps in a single plot
cfg.acclim = [.4 .7];                        % change the y-limits of the plot
adam_plot_MVPA(cfg, mvpa_stats);             % actual plotting

%% PLOT SINGLE SUBJECT RESULTS OF THE EEG_FAM_VS_SCRAMBLED COMPARISON
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.reduce_dims = 'diag';                    % train and test on the same points
cfg.splinefreq = 11;                         % acts as an 11 Hz low-pass filter
cfg.plotsubjects = true;                     % also plot individual subjects
%cfg.plot_dim = 'freq_time';
adam_compute_group_MVPA(cfg);                % select EEG_FAM_VS_SCRAMBLED when dialog pops up

%% PLOT ACTIVATION PATTERNS OF ALL EEG COMPARISONS
cfg = [];                                    % clear the config variable
cfg.plot_order = {'EEG_wmorning_OF_VS_OR' 'EEG_wnight_OF_VS_OR' ,'EEG_w_OF_VS_OR'};
cfg.mpcompcor_method = 'cluster_based';      % amultiple comparison correction method
cfg.plotweights_or_pattern = 'covpatterns';  % covariance activation pattern
cfg.weightlim = [-1.2 1.2];                  % set common scale to all plots
cfg.timelim = [250 400];                     % time window to visualize
adam_plot_BDM_weights(cfg,mvpa_stats);       % actual plotting

%% COMPUTE THE TEMPORAL GENERALIZATION MATRIX OF ALL EEG AND MEG COMPARISONS
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.iterations = 250;                        % reduce the number of iterations to save time
mvpa_eeg_stats = adam_compute_group_MVPA(cfg);  % select RAW_EEG when dialog pops up
mvpa_meg_stats = adam_compute_group_MVPA(cfg);  % select RAW_MEG when dialog pops up

%% PLOT THE TEMPORAL GENERALIZATION MATRIX OF ALL EEG AND MEG COMPARISONs
cfg = [];                                    % clear the config variable
%cfg.plot_order = {'subset-wmorning' 'subset-wmnight'}; 
cfg.plot_order = {'subset-wmorning_T-vs-A' 'subset-wmorning_OF-vs-OR' 'subset-wmorning_OFBig5-vs-ORBig5'...
                  'subset-wnight_T-vs-A' 'subset-wnight_OF-vs-OR' 'subset-wnight_OFBig5-vs-ORBig5'}; 
adam_plot_MVPA(cfg, mvpa_eeg_stats, mvpa_meg_stats);  % actual plotting, combine EEG/MEG results

%% COMPUTE GENERALIZATION ACROSS TIME FOR THE 250-400 MS TIME WINDOW FOR EEG AND MEG COMPARISONS 
cfg = [];                                    % clear the config variable
cfg.startdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS';          % path to first level results 
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
cfg.trainlim = [0 448];                    % specify a 250-400 ms interval in the training data
cfg.reduce_dims = 'avtrain';                 % average over that training interval
mvpa_eeg_stats = adam_compute_group_MVPA(cfg);  % select RAW_EEG when dialog pops up
mvpa_meg_stats = adam_compute_group_MVPA(cfg);  % select RAW_MEG when dialog pops up

%% PLOT GENERALIZATION ACROSS TIME FOR THE 250-400 MS TIME WINDOW FOR EEG AND MEG COMPARISONS 
cfg = [];                                    % clear the config variable
cfg.plot_order = {'subset-wmorning_T-vs-A' 'subset-wmorning_OF-vs-OR' 'subset-wmorning_OFBig5-vs-ORBig5'...
                  'subset-wnight_T-vs-A' 'subset-wnight_OF-vs-OR' 'subset-wnight_OFBig5-vs-ORBig5'}; 
adam_plot_MVPA(cfg, mvpa_eeg_stats, mvpa_meg_stats);  % actual plotting, combine EEG/MEG results

%% COMPARE MEG TO EEG STATS
cfg = [];                                    % clear the config variable
cfg.mpcompcor_method = 'cluster_based';      % multiple comparison correction method
meg_vs_eeg_stats = adam_compare_MVPA_stats(cfg,mvpa_meg_stats,mvpa_eeg_stats);

%% PLOT THE MEG - EEG DIFFERENCE
cfg = [];                                    % clear the config variable
%cfg.plot_order = {'subset-wnight_T-vs-A' 'subset-wnight_OF-vs-OR' 'subset-wnight_OFBig5-vs-ORBig5'};
adam_plot_MVPA(cfg, meg_vs_eeg_stats);       % actual plotting

