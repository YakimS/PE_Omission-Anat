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

    cfg.rotate = 0;
    
    cfg = ft_clusterplot(cfg, stat); 
end
