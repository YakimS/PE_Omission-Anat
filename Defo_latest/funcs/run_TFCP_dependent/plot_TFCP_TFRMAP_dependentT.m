function plot_TFCP_TFRMAP_dependentT(data_to_plot,filename,fig_title,contrast_conds,event_lines)
    grandavg_cond1= data_to_plot.grandavg_cond1;
    grandavg_cond2= data_to_plot.grandavg_cond2;
    stat  = data_to_plot.stat;
    clust_struct = data_to_plot.clust_struct;

    % Calculate difference
    cfg_diff = [];
    cfg_diff.operation =  'x1-x2';
    cfg_diff.parameter = data_to_plot.cfg_avg_parameter;
    cfg_diff.previous = 'no';
    diff_cond12 = ft_math(cfg_diff, grandavg_cond1, grandavg_cond2);

    % Create significance mask
    tolerance = 1e-10;
    mask_ = zeros(size(diff_cond12.(data_to_plot.cfg_avg_parameter)));
    test_latency_index_1 = find(abs(diff_cond12.time - data_to_plot.test_latency(1)) < tolerance);
    test_latency_index_2 = find(abs(diff_cond12.time - data_to_plot.test_latency(2)) < tolerance);
    mask_(:,:,test_latency_index_1:test_latency_index_2) =  repmat(stat.mask,[size(mask_,1),1,1]);

    
    % Add masks to data structures
    diff_cond12.mask = logical(mask_);
    grandavg_cond1.mask = logical(mask_);
    grandavg_cond2.mask = logical(mask_);

    % Calculate automatic z-limits
    data_sets = {grandavg_cond1, grandavg_cond2, diff_cond12};
    all_data = [];
    for i = 1:length(data_sets)
        data_vals = data_sets{i}.(data_to_plot.cfg_avg_parameter);
        data_vec = data_vals(:);
        clean_vals = data_vec(isfinite(data_vec) & isreal(data_vec)); % Remove NaN, Inf, and complex values
        if ~isempty(clean_vals)
            all_data = [all_data; clean_vals];
        end
    end
    data_range = [prctile(all_data, 5), prctile(all_data, 95)];
    data_max = max(abs(data_range));
    zlim_data = [-data_max, data_max];
    zlim_stat = [-3, 3];

    fig = figure('Position', [100, 100, 1200, 800]);

    % Common plotting configuration
    cfg_base = [];
    cfg_base.channel = clust_struct.('elect_label');
    cfg_base.xlim = data_to_plot.plot_timerange;
    cfg_base.baseline = 'no';
    cfg_base.parameter = data_to_plot.cfg_avg_parameter;
    cfg_base.maskparameter = 'mask';
    cfg_base.maskstyle = 'outline';
    cfg_base.colormap = getBlueGreyRedColormap(128);
    cfg_base.figure = 'gca';

    % Condition 1
    subplot(2, 3, 1);
    cfg_plot = cfg_base;
    cfg_plot.zlim = zlim_data;
    cfg_plot.title = sprintf('%s', contrast_conds{1}.long_s);
    ft_singleplotTFR(cfg_plot, grandavg_cond1);
    add_event_lines(event_lines);

    % Condition 2
    subplot(2, 3, 2);
    cfg_plot.title = sprintf('%s', contrast_conds{2}.long_s);
    ft_singleplotTFR(cfg_plot, grandavg_cond2);
    add_event_lines(event_lines);
    
    % Difference
    subplot(2, 3, 3);
    cfg_plot.title = sprintf('Difference (%s - %s)', contrast_conds{1}.long_s, contrast_conds{2}.long_s);
    ft_singleplotTFR(cfg_plot, diff_cond12);
    add_event_lines(event_lines);
    
    % Statistics
    subplot(2, 3, 4);
    cfg_plot = cfg_base;
    cfg_plot.channel ='all';
    cfg_plot.parameter = 'stat';
    cfg_plot.zlim = zlim_stat;
    cfg_plot.title = 'T-statistics';
    cfg_plot.figure = 'gca';
    ft_singleplotTFR(cfg_plot, stat);
    add_event_lines(event_lines);
    
    % Electrodes Layout
    subplot(2, 3, 5);
    axis off;
    cfg_ftplot = [];
    cfg_ftplot.feedback = 'no';
    cfg_ftplot.elec= stat.elec;
    layout = ft_prepare_layout(cfg_ftplot);
    layout_chanindx = match_str(layout.label,clust_struct.('elect_label'));
    ft_plot_layout(layout, 'label', 'no', 'box', 'no', 'chanindx', layout_chanindx, 'pointsize', 30, 'pointcolor', 'black');
    title(clust_struct.long_s);
    
    % Analysis Details
    subplot(2, 3, 6);
    axis off;
    text(0.1, 0.9, 'Analysis Parameters:', 'FontSize', 12, 'FontWeight', 'bold');
    param_text = {
        sprintf('Electrodes: %s', clust_struct.short_s),
        sprintf('Test window: [%.3f, %.3f] s', data_to_plot.test_latency(1), data_to_plot.test_latency(2)),
        sprintf('Plot window: [%.3f, %.3f] s', data_to_plot.plot_timerange(1), data_to_plot.plot_timerange(2)),
        sprintf('N subjects: %d', data_to_plot.sub_num),
        sprintf('Parameter: %s', data_to_plot.cfg_avg_parameter)
    };
    for i = 1:length(param_text)
        text(0.1, 0.8 - (i-1)*0.1, param_text{i}, 'FontSize', 10);
    end
    
    % Overall title
    sgtitle(sprintf('%s | Electrodes: %s', fig_title, clust_struct.short_s));
    
    saveas(gcf,filename);
%             saveas(gcf,sprintf("%s.fig",filename));
    close;
end

function add_event_lines(event_lines)
    hold on;
    for i = 1:length(event_lines)
        event_time = event_lines{i}.event_time;
        line([event_time, event_time], ylim, 'Color', event_lines{i}.event_color, 'LineWidth', 1);
        ylim_temp = ylim;
        text(event_time, ylim_temp(2)-((ylim_temp(2)-ylim_temp(1))/8), event_lines{i}.event_text(1:2), ...
            'Color', event_lines{i}.event_color, 'FontSize', 8, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
    end
    hold off;
end