clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionGL')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = GL_configuration('mvpa');
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionGL')

%% 
contrast = {v.UnexOm, v.ExOm};
latency = [-0.9 0.9];
sovs = {v.wn, v.N1, v.N2, v.N3, v.REM};

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

% % Run regular analysis
% output_dir_regular = sprintf("%s\\RESULTS_resampNo_subRandPerm", main_output_dir);
% run_mvpa_firstlevel('regular', dirs.output_adamformat, dirs.output_adam_firstlvl, cont_string, sovs_string, subs, ...
%     'parallel_workers', 4);


% % Run random permutation analysis
run_mvpa_firstlevel('randperm', dirs.output_adamformat, dirs.output_adam_firstlvl, {cont_string}, sovs_string, subs, ...
    'randpermutations', 30);

%% Average decoding

% results_dir = "C:\loo\GL2";
% plot_dir =  'C:\mvpa\GL\plots2\loo_resampNo';
% all_subsets = {'subset-wn','subset-N2','subset-N1','subset-N3','subset-REM'}; %,'subset-N2','subset-N3','subset-REM'
% contrast = 'UnexOm-vs-ExOm'; 

results_dir = 'C:\mvpa\GL\FirstLevel2\RESULTS_resampNo_subRandPerm';
plot_dir = 'C:\mvpa\GL\plots2\resampNo';
all_subsets = {'subset-wn', 'subset-N1', 'subset-N2', 'subset-N3', 'subset-REM'};
contrast = 'UnexOm-vs-ExOm'; 

plot_mvpa_results(results_dir, plot_dir, all_subsets, contrast, ...
    'timerange', [300 600], 'acclim', [.3 .7]);

%%
% Just provide the directory - no need for time vector
plot_dir = 'C:\mvpa\GL\plots2\loo_resampNo';
contrast = 'UnexOm-vs-ExOm'; 
results_table = extractMVPAStats(plot_dir,contrast);
disp(results_table);

% Save to CSV for paper
% writetable(results_table, 'mvpa_summary_stats.csv');
% sig_results = results_table(results_table.Is_Significant == 1, :);
% sorted_results = sortrows(results_table, 'Peak_Accuracy', 'descend');

%%
%% SINGLE SUB DIAGONAL decoding using random permutation

plot_dir = 'C:\mvpa\GL\plots2\resampNo';
results_dir = 'C:\mvpa\GL\FirstLevel2'; % gotta have regular firstlvl before "randperm" dir
all_subsets = {'subset-wn', 'subset-N1', 'subset-N2', 'subset-N3', 'subset-REM'}; % 
all_contrasts = {'UnexOm-vs-ExOm'}; 
acclim = [.35 .7];
testlim = [-100 900];


for subset_i=1:numel(all_subsets)
    curr_subset = all_subsets{subset_i};
    for contrast_i=1:numel(all_contrasts)
       curr_contrast = all_contrasts{contrast_i};
        contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {curr_contrast}, 'UniformOutput', false);
        contrast_dir = sprintf('%s\\%s\\%s_%s',results_dir,curr_subset,curr_subset,curr_contrast);

        cfg = [];                               
        cfg.wanted_dir = contrast_dir;           % path to first level results 
        cfg.reduce_dims = 'diag';
        cfg.plotsubjects = false;
        cfg.mpcompcor_method = 'fdr';
        cfg.timelim          = testlim;
        cfg.compute_randperm = true;
        cfg.tail = 'both';
        mvpa_stats = adam_compute_group_MVPA(cfg);

        % save_file_name = sprintf('%s\\%s_%s_PerSubDecodeComparePermu_diag-1_tail-%s',plot_dir,curr_subset,curr_contrast,'both');
        % save_plot_and_close_fig(save_file_name);

%          plot_timerange_activation_pattern(contrasts_withsubset,mvpa_stats,timelim)

        % %%% AvgPerSubDecodeComparePermu
        % plot_decoding(contrasts_withsubset,mvpa_stats,acclim)
        % save_file_name = sprintf('%s\\%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s',plot_dir,curr_subset,curr_contrast,'both');
        % save_plot_and_close_fig(save_file_name)
        % 
        % save_file_name = sprintf('%s\\%s_%s_AvgPerSubDecodeComparePermu_diag-1_tail-%s_2',plot_dir,curr_subset,curr_contrast,'both');
        % plot_avgSubPerm_decoding(mvpa_stats,[0.35,0.8],contrasts_withsubset,save_file_name); 

        %%% allPerSubDecodeComparePermu
        save_file_name = sprintf('%s\\%s_%s_subDecodeComparePermu_diag-1_tail-%s',plot_dir,curr_subset,curr_contrast,'both');
        plot_subPerm_decoding(mvpa_stats,[0.35,0.8],contrasts_withsubset,save_file_name);
    end
end




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

function plot_subPerm_decoding(mvpa_stats,acclim,title_,save_file_name_prefix)
    indi_over_time = mvpa_stats.indivClassOverTime;
    pvals_indi_over_time = mvpa_stats.pvalsOverTime;
    time = mvpa_stats.settings.times{1};

    for i=1:size(indi_over_time,1)
        h=figure;
        set(h,'visible','off');
        plot(time, indi_over_time(i,:),'Color',[0, 0, 0, 1]); % Plot the line

        significantIndices = find(pvals_indi_over_time(i,:) <= 0.05);
        % Plot each significant dot
        hold on;
        plot(time(significantIndices), indi_over_time(i,significantIndices), '.','color','black','MarkerSize',8);

        % Identify and plot bold segments for adjacent significant dots
        for j = 1:length(significantIndices)
            if j < length(significantIndices) && significantIndices(j+1) == significantIndices(j) + 1
                % Start of a bold segment
                startIndex = j;
                while j < length(significantIndices) && significantIndices(j+1) == significantIndices(j) + 1
                    j = j + 1;
                end
                % End of a bold segment
                endIndex = j;
                if endIndex - startIndex > 10
                    plot(time(significantIndices(startIndex:endIndex)), indi_over_time(i,significantIndices(startIndex:endIndex)), 'k','LineWidth',2);
                end
            end
        end

        xlim([time(1),time(end)]);
        if acclim ~=0
            ylim(acclim);
        end
        title(sprintf("%s, subINDEX-%d",title_{1}, i));
        xlabel("time (s)");
        ylabel("AUC");
        set(gcf,'Position',[100 100 600 300]);
        save_file_name = sprintf("%s_subINDEX-%d",save_file_name_prefix,i);
        save_plot_and_close_fig(save_file_name);
    end
end


function plot_avgSubPerm_decoding(mvpa_stats,acclim,title_,save_file_name)
    indi_over_time = mvpa_stats.indivClassOverTime;
    h=figure;
    set(h,'visible','off');
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
    save_plot_and_close_fig(save_file_name)
end