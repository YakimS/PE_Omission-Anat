function cfg = topo_plot(cfg,preVsPoststim_res)
    if ~isfield(cfg, 'parameter')           error('cfg must include parameter field with parameter'); end 
    if ~isfield(cfg, 'xlim')                 error('cfg must include parameter xlim with time range of intrest'); end 
    if ~isfield(cfg, 'zlim')                cfg.zlim = [-1,1]; end
    if ~isfield(cfg, 'subplotsize')         cfg.subplotsize =[4,4]; end             % better keep it that way, becuase this is the default grid of ft_topoplot
    if ~isfield(cfg, 'style')               cfg.style = 'straight'; end             % colormap only. Defualt - colormap and conture lines
    if ~isfield(cfg, 'comment')             cfg.comment = 'xlim'; end
    if ~isfield(cfg, 'marker')              cfg.marker = 'off'; end
    if ~isfield(cfg, 'commentpos')          cfg.commentpos = 'title'; end
    if ~isfield(cfg, 'rotate')              cfg.rotate = []; end

    cfg.colormap = getBlueGreyRedColormap(128);

    cfg.layout = preVsPoststim_res.elec;
    cfg.interactive = 'no';

    cfg  = ft_topoplotER(cfg,preVsPoststim_res);
end