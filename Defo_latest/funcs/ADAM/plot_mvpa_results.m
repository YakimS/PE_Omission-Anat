function plot_mvpa_results(results_dir, plot_dir, all_subsets, contrast, varargin)
% PLOT_MVPA_RESULTS Plot MVPA decoding results
% plot_mvpa_results(results_dir, plot_dir, all_subsets, all_contrasts)
% plot_mvpa_results(results_dir, plot_dir, all_subsets, all_contrasts, 'timerange', [300 600], 'acclim', [.3 .7])
%
% Required inputs:
%   results_dir - directory containing MVPA results
%   plot_dir - directory to save plots
%   all_subsets - cell array of subset names (e.g., {'subset-wn','subset-N1'})
%   contrast - contrast name (e.g., 'UnexOm-vs-ExOm')
%
% Optional inputs:
%   'timerange' - time range for weights plot (default: [300 600])
%   'acclim' - accuracy limits for plots (default: [.3 .7])

    % Handle optional parameters
    timerange_weights_plot = [300 600]; % default
    acclim = [.3 .7]; % default
    
    if nargin > 4
        for i = 1:2:length(varargin)
            if strcmpi(varargin{i}, 'timerange')
                timerange_weights_plot = varargin{i+1};
            elseif strcmpi(varargin{i}, 'acclim')
                acclim = varargin{i+1};
            end
        end
    end
    
    % Create plot directory if it doesn't exist
    if ~exist(plot_dir, 'dir')
        mkdir(plot_dir);
    end
    
    % Setup config
    cfg = [];
    cfg.tail = 'both';
    cfg.trainlim = [0, 900]; % [] if no, [250 400] if yes   
    cfg.timelim = [-0, 900]; % [] if no, [250 400] if yes   
    
    % Process each subset
    for subset_i = 1:numel(all_subsets)
        curr_subset = all_subsets{subset_i};
        
        % Get diagonal decoding results
        cfg.wanted_dir = sprintf('%s\\%s', results_dir, curr_subset);
        cfg.isDiag = true;
        save_file_name_diag = sprintf('%s\\%s_decode_diag-%d_%s', plot_dir, curr_subset, true, contrast);
        contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {contrast}, 'UniformOutput', false);
        mvpa_stats_diag = get_avg_decoding(cfg, save_file_name_diag); 
        plot_decoding(contrasts_withsubset, mvpa_stats_diag, acclim);
        save_plot_and_close_fig(save_file_name_diag);
        
        % Get non-diagonal decoding results
        cfg.isDiag = false;
        save_file_name_nodiag = sprintf('%s\\%s_decode_diag-%d_%s', plot_dir, curr_subset, false, contrast);
        mvpa_stats_nodiag = get_avg_decoding(cfg, save_file_name_nodiag); 
        contrasts_withsubset = cellfun(@(x) [curr_subset, '_', x], {contrast}, 'UniformOutput', false);
        plot_decoding(contrasts_withsubset, mvpa_stats_nodiag, acclim);
        save_plot_and_close_fig(save_file_name_nodiag);

        % Plot timerange activation pattern
        plot_timerange_activation_pattern(contrasts_withsubset, mvpa_stats_diag, timerange_weights_plot);
        save_file_name = sprintf('%s\\%s_%s_covarTopo_time[%d,%d]', plot_dir, curr_subset, contrast, ...
            timerange_weights_plot(1), timerange_weights_plot(2));
        save_plot_and_close_fig(save_file_name);
    end
    
    fprintf('Plotting completed. Results saved to %s\n', plot_dir);
end

function mvpa_stats = get_avg_decoding(cfg, save_file_name)   
    if ~isfield(cfg, 'wanted_dir')           error('cfg must include dir field with filename'); end
    if ~isfield(cfg, 'mpcompcor_method')     cfg.mpcompcor_method = 'cluster_based'; end
    if ~isfield(cfg, 'isDiag')               cfg.isDiag = 0; end
    if ~isfield(cfg, 'tail')                 cfg.tail = 'both'; end
    if ~isfield(cfg, 'trainlim')             cfg.trainlim = false; end
    if ~isfield(cfg, 'cfg.testlim')          cfg.testlim = cfg.trainlim; end
    if ~isfield(cfg, 'timelim')              cfg.timelim = {}; end 

    if cfg.isDiag
        cfg.reduce_dims = 'diag'; % train and test on the same time points
    end
    
    matfilename = sprintf("%s.mat", save_file_name);
    if exist(matfilename, "file")
        mvpa_stats = load(matfilename);
        mvpa_stats = mvpa_stats.mvpa_stats; 
    else
        mvpa_stats = adam_compute_group_MVPA(cfg);
        save(matfilename, "mvpa_stats");
    end
end

function plot_decoding(plot_order, mvpa_stats, acclim)
    % PLOT THE DIAGONAL DECODING RESULTS FOR ALL EEG COMPARISONS
    cfg = [];
    cfg.plot_order = plot_order;
    cfg.singleplot = true; % all erps in a single plot
    cfg.acclim = acclim; % change the y-limits of the plot
    cfg.figure_size = [600, 400];
    cfg.plotsigline_method = 'follow';
    adam_plot_MVPA(cfg, mvpa_stats); % actual plotting
end

function save_plot_and_close_fig(file_name)
    saveas(gcf, sprintf("%s.png", file_name));
    close(gcf);
end

function plot_timerange_activation_pattern(plot_order, mvpa_stats, timerange)
    cfg = [];
    cfg.plot_order = plot_order;
    cfg.mpcompcor_method = 'cluster_based'; % multiple comparison correction method
    cfg.plotweights_or_pattern = 'covpattern'; % covariance activation pattern - CAN BE: 'weights', 'covpattern' or 'corpattern'
    cfg.weightlim = [-1.5 1.5]; % set common scale to all plots
    if timerange
        cfg.timelim = timerange; % time window to visualize
    end
    adam_plot_BDM_weights(cfg, mvpa_stats); % actual plotting
end