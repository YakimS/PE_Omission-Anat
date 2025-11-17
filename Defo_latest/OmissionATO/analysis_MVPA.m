clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = ATO_configuration('mvpa');
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')

%% 
contrast = {v.AOmiR,v.AOmiF};
sovs = {v.wn, v.N2, v.N3, v.REM};
latency = [-0.1,1.16];

%%
% Run LOO design

is_loo = true;
change_ft_to_ADAM_format(contrast, sovs, latency, subs, dirs, is_loo);

% Run no-LOO design
is_loo = false;
change_ft_to_ADAM_format(contrast, sovs, latency, subs, dirs, is_loo);


%%
% MVPA First Level Analysis
sovs_string = cellfun(@(x) x.short_s{1}, sovs, 'UniformOutput', false);
cont_string = cellfun(@(x) x.short_s{1}, contrast, 'UniformOutput', false);


% Run LOO analysis
% run_mvpa_firstlevel('loo', dirs.output_adamformat, dirs.output_adam_firstlvl_loo, cont_string, sovs_string, subs);
% 
% 
% % % Run regular analysis
% output_dir_regular = sprintf("%s\\RESULTS_resampNo_subRandPerm", dirs.output_adam_firstlvl);
% run_mvpa_firstlevel('regular', dirs.output_adamformat, dirs.output_adam_firstlvl, cont_string, sovs_string, subs, ...
%     'parallel_workers', 4);


% % Run random permutation analysis
output_dir_randperm = sprintf("%s\\RESULTS_resampNo_subRandPerm", dirs.output_adam_firstlvl);
run_mvpa_firstlevel('randperm', dirs.output_adamformat, dirs.output_adam_firstlvl, {cont_string}, sovs_string, subs, ...
    'randpermutations', 30);

%% Average decoding

% results_dir =  dirs.output_adam_firstlvl_loo;
% plot_dir =  dirs.output_adam_plots;
% all_subsets = {'subset-wn','subset-N2','subset-N1','subset-N3','subset-REM'}; %,'subset-N2','subset-N3','subset-REM'
% contrast = 'UnexOm-vs-ExOm'; 

% results_dir = sprintf("%s\\RESULTS_resampNo_subRandPerm");% gotta have regular firstlvl before "randperm" dir
plot_dir = dirs.output_adam_plots;
all_subsets = {'subset-wn', 'subset-N2', 'subset-N3', 'subset-REM'};
contrast = 'AOR-vs-AOF'; 

plot_mvpa_results(dirs.output_adam_firstlvl, plot_dir, all_subsets, contrast, ...
    'timerange', [300 600], 'acclim', [.3 .7]);

%%
plot_dir =  dirs.output_adam_plots;
contrast = 'AOR-vs-AOF'; 
results_table = extractMVPAStats(plot_dir,contrast);
disp(results_table);

% Save to CSV for paper
% writetable(results_table, 'mvpa_summary_stats.csv');
% sig_results = results_table(results_table.Is_Significant == 1, :);
% sorted_results = sortrows(results_table, 'Peak_Accuracy', 'descend');

%% SINGLE SUB DIAGONAL decoding using random permutation

results_dir = sprintf("%s\\RESULTS_resampNo_subRandPerm", dirs.output_adam_firstlvl);% gotta have regular firstlvl before "randperm" dir
all_subsets = {'subset-wn', 'subset-N2', 'subset-N3', 'subset-REM'};
all_contrasts = {'AOR-vs-AOF'}; 
acclim = [.35 .7];
timelim = [-100 900];
testlim = [0,timelim(2)];

for subset_i=1:numel(all_subsets)
    curr_subset = all_subsets{subset_i};
    for contrast_i=1:numel(all_contrasts)
       curr_contrast = all_contrasts{contrast_i};
        contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {curr_contrast}, 'UniformOutput', false);
        contrast_dir = sprintf('%s\\%s\\%s_%s',dirs.output_adam_firstlvl,curr_subset,curr_subset,curr_contrast);

        cfg = [];                               
        cfg.wanted_dir = contrast_dir;           % path to first level results 
        cfg.reduce_dims = 'diag';
        cfg.plotsubjects = false;
        cfg.mpcompcor_method = 'cluster_based'; % fdr
        cfg.timelim          = timelim;
        cfg.testlim         = testlim;
        cfg.compute_randperm = true;
        cfg.tail = 'both';
        mvpa_stats = adam_compute_group_MVPA(cfg);

        save_file_name = sprintf('%s\\%s_%s_PerSubDecodeComparePermu_diag-1_tail-%s',dirs.output_adam_plots,curr_subset,curr_contrast,'both');
        save_plot_and_close_fig(save_file_name);

%          plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timelim)


        %%% allPerSubDecodeComparePermu
        save_file_name = sprintf('%s\\%s_%s_subDecodeComparePermu_diag-1_tail-%s',dirs.output_adam_plots,curr_subset,curr_contrast,'both');
        plot_subPerm_decoding(mvpa_stats,[0.35,0.8],contrasts_withsubset,save_file_name);

        %%% AvgPerSubDecodeComparePermu
        plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
        save_file_name = sprintf('%s\\%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s',dirs.output_adam_plots,curr_subset,curr_contrast,'both');
        save_plot_and_close_fig(save_file_name)
        
        save_file_name = sprintf('%s\\%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s_2',dirs.output_adam_plots,curr_subset,curr_contrast,'both');
        plot_avgSubPerm_decoding(mvpa_stats,[0.35,0.8],contrasts_withsubset,save_file_name); 
    end
end
%%


function save_plot_and_close_fig(file_name)
%     saveas(gcf, sprintf("%s\\%s.fig", folder, file_name));
%     saveas(gcf, sprintf("%s\\%s.svg", folder, file_name));
    saveas(gcf, sprintf("%s.png", file_name));
    close(gcf);
end


function plot_decoding(plot_order,mvpa_stats,acclim)
    % PLOT THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
    cfg = [];                                    % clear the config variable
    cfg.plot_order = plot_order;
    cfg.singleplot = true;                       % all erps in a single plot
    cfg.acclim =acclim;                        % change the y-limits of the plot
    cfg.figure_size = [600,400];
    cfg.plotsigline_method    = 'follow';
    %cfg.splinefreq = lp_smoothing; % just dont. Andres "Its dodgy"
    adam_plot_MVPA(cfg, mvpa_stats);             % actual plotting
end

