function plot_STCP_ERP_dependentT(data_to_plot,curr_output_filename)
    stat = data_to_plot.stat;
    cfg = data_to_plot.cfg;

    is_cluster_exists = false;
    if isfield(stat, "posclusters")
        pos_prob = [stat.posclusters.('prob')];
        if  ~isempty(pos_prob) && pos_prob(1)<=0.05
            is_cluster_exists = true;
        end
    end
    if isfield(stat, "negclusters")
        neg_prob = [stat.negclusters.('prob')];
        if  ~isempty(neg_prob) && neg_prob(1)<=0.05
            is_cluster_exists = true;
        end
    end
    
    % plot          
    if cfg.is_plot_topoplot
        sample_rate = 250;
        rec_fps = 1/sample_rate;
        
        timediff = ((cfg.plot_latency(end) - cfg.plot_latency(1))/16);
        toi = cfg.plot_latency(1): timediff :cfg.plot_latency(end);
        cfg_topoplot = [];
        cfg_topoplot.parameter = 'avg';
        cfg_topoplot.xlim = toi;
        cfg_topoplot.zlim  = [-1,1];
        topo_plot(cfg_topoplot,data_to_plot.subt_conds12);
        sgtitle(sprintf('Topographical μV Difference, all time (Z:%.1f-%.1f)', cfg_topoplot.zlim(1), cfg_topoplot.zlim(2)));

        timediff = ceil(((cfg.test_latency(end) - cfg.test_latency(1))/16) / rec_fps) * rec_fps;
        toi = cfg.test_latency(1): timediff :cfg.test_latency(end);
        cfg_topoplot.xlim = toi;
        cfg_topoplot.elec = stat.elec;
        cfg_topoplot.zlim  = [-1,1];
        cfg_topoplot.rotate  = [];
        cfg_topoplot.parameter = 'avg';
        topo_plot(cfg_topoplot,data_to_plot.subt_conds12); 
        sgtitle(sprintf('Topographical μV Difference, test time (Z:%.1f-%.1f)', cfg_topoplot.zlim(1), cfg_topoplot.zlim(2)));

        cfg_topoplot.zlim  = [-5,5];
        cfg_topoplot.parameter = 'stat';
        if is_cluster_exists
            cfg_topoplot = rmfield(cfg_topoplot, 'xlim');
            cfg_topoplot.toi = toi;
            cluster_plot(stat,cfg_topoplot); 
        else
            topo_plot(cfg_topoplot,stat); 
        end
        sgtitle(sprintf('Cluster Analysis - T Statistic (Z:%.1f-%.1f)', cfg_topoplot.zlim(1), cfg_topoplot.zlim(2)));

        figures = findall(0, 'Type', 'figure');
        set(figures(1), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off', 'Color', 'white');
        set(figures(2), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off', 'Color', 'white');
        set(figures(3), 'Units', 'pixels', 'Position', [0.05, 0.05, 600, 500], 'PaperPositionMode', 'auto', 'InvertHardcopy', 'off', 'Color', 'white');

        frame1 = getframe(figures(1)); img1 = frame1.cdata;
        frame2 = getframe(figures(2)); img2 = frame2.cdata;
        frame3 = getframe(figures(3)); img3 = frame3.cdata;
        
        % Ensure all images have the same height by padding the smaller ones
        [height1, ~, ~] = size(img1);
        [height2, ~, ~] = size(img2);
        [height3, ~, ~] = size(img3);
        
        max_height = max([height1, height2, height3]);
        
        if height1 < max_height
            img1 = padarray(img1, [max_height-height1, 0, 0], 255, 'post');
        end
        if height2 < max_height
            img2 = padarray(img2, [max_height-height2, 0, 0], 255, 'post');
        end
        if height3 < max_height
            img3 = padarray(img3, [max_height-height3, 0, 0], 255, 'post');
        end
        
        combined_img = [img1, img2, img3];
        combined_figure = figure('Color', 'white');;
        imshow(combined_img);
        imwrite(combined_img, sprintf("%s.png",curr_output_filename));
%                     saveas(combined_figure, sprintf("%s.fig", filename));
        close 'all';
    end
end

function cfg = cluster_plot(stat,cfg)
%   if ~isfield(cfg, 'saveaspng')           error('cfg must include saveaspng field with filename'); end
    if ~isfield(cfg, 'parameter')           error('cfg must include parameter field with parameter'); end 
    if ~isfield(cfg, 'toi')                 error('cfg must include parameter toi with time range of intrest'); end 
    if ~isfield(cfg, 'alpha')                       cfg.alpha = 0.05; end                               % This is the max alpha to be plotted. (0.3 is the highst value possible)
    if ~isfield(cfg, 'zlim')                        cfg.zlim = [-1,1]; end
    if ~isfield(cfg, 'subplotsize')                 cfg.subplotsize =[4,4]; end             % better keep it that way, becuase this is the default grid of ft_topoplot
    if ~isfield(cfg, 'visible')                     cfg.visible = 'on'; end
    if ~isfield(cfg, 'highlightsymbolseries')       cfg.highlightsymbolseries = ['.', '.', '.', '.', '.']; end
    if ~isfield(cfg, 'highlightsizeseries')         cfg.highlightsizeseries = [4 4 4 4 4]; end
    if ~isfield(cfg, 'highlightcolorpos')           cfg.highlightcolorpos =[0.5 0 0]; end
    if ~isfield(cfg, 'highlightcolorneg')           cfg.highlightcolorneg = [0 0 0.5]; end
    if ~isfield(cfg, 'style')                       cfg.style = 'straight'; end             %     colormap only. Defualt - colormap and conture lines

    cfg.rotate = [];
    cfg = ft_clusterplot(cfg, stat); 
end