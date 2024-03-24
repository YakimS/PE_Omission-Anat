addpath 'D:\matlab_libs'
elecd_ =  ['Cz'];

%%
load('D:\OExpOut\spatioTemp\AdaptorOmission\STCP-ERP_conds-AOF+AOR_condsSovs-wn+wn_subAvg.mat')
rowsWithOne = any(metadata.stat.posclusterslabelmat == 1, 2);
rowIndexes = find(rowsWithOne);
elecd_ = {metadata.stat.label{rowIndexes}};
%%
cfg = [];
cfg.startdir = 'D:\OExpOut\ADAM\RESULTS_allSovs';
cfg.electrode_def =elecd_;
cfg.mpcompcor_method = 'cluster_based';
cfg.electrode_method = 'average';
erp_stats = adam_compute_group_ERP(cfg);
%%
% cfg = [];
% cfg.startdir = 'D:\OExpOut\ADAM\RESULTS_allSovs';
% cfg.electrode_def = { elecd_};
% cfg.electrode_method = 'subtract';
% erp_stats_diff = adam_compute_group_ERP(cfg);
%%
cfg = [];
cfg.singleplot = false;
adam_plot_MVPA(cfg, erp_stats)

%% MVPA
%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.startdir = 'D:\OExpOut\ADAM\RESULTS_allSovs';
cfg.mpcompcor_method = 'cluster_based';
% cfg.splinefreq = 30;
cfg.reduce_dims = 'diag';
mvpa_stats = adam_compute_group_MVPA(cfg);

%%
cfg = [];
cfg.singleplot = true;
adam_plot_MVPA(cfg, mvpa_stats)

%% BDM weights
%%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.mpcompcor_method = 'cluster_based';
cfg.plotweights_or_pattern = 'covpatterns';
cfg.timelim = [500 550];
bdm = adam_plot_BDM_weights(cfg,mvpa_stats);
