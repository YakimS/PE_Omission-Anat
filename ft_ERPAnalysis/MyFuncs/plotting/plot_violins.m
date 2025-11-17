function plot_violins(variables_s,data,output_filename, var_colormap,subs,cfg)
    if ~isfield(cfg, 'is_plot_box')                 cfg.is_plot_box = true; end 

    if ~isfield(cfg, 'ylim_')                       cfg.ylim_ =  [-8 8]; end
    if ~isfield(cfg, 'elctrds_clusts')              cfg.elctrds_clusts = []; end 
    if ~isfield(cfg, 'subtitle_')                   cfg.subtitle_ = ""; end 
    if ~isfield(cfg, 'title_')                      cfg.title_ = {}; end 
    if ~isfield(cfg, 'bottom_string')               cfg.bottom_string = ""; end 
    if ~isfield(cfg, 'sig_timeranges')              cfg.sig_timeranges = {}; end 
    if ~isfield(cfg, 'sig_timeranges_colormaps')    cfg.sig_timeranges_colormaps = {}; end
    if ~isfield(cfg, 'difference_res')              cfg.difference_res = 0; end
    if ~isfield(cfg, 'descriptive_report')          cfg.descriptive_report = 0; end
    if ~isfield(cfg, 'parametric_report')           cfg.parametric_report = 0; end
    if ~isfield(cfg, 'wilcoxon_report')             cfg.wilcoxon_report = 0; end
   
    if ~isfield(cfg, 'ticksY')                      cfg.ticksY = []; end

    fig = figure('Visible', 'off','Position', [0, 0, 1000, 1000], 'Color', 'white');
%             fig = figure('Position', [0, 0, 1000, 800], 'Color', 'white');
    subplot('Position', [0.2, 0.4, 0.25, 0.55]);

    oneline_data = data(:);
    [rows, cols] = size(data);
    column_indices_matrix = repmat(1:cols, rows, 1);
    column_indices_vector = column_indices_matrix(:);
    patch([0 cols cols 0], [0 0 0 0], [0.7 0.7 0.7], 'EdgeColor', [0.7 0.7 0.7], 'LineStyle', '--', 'LineWidth', 0.5);
    hold on
    h_violin = daviolinplot(oneline_data,'groups', column_indices_vector, ...
        'color',var_colormap,'scatter',1, ...
        'outfactor', 3.5,  'outsymbol', '', ... 
        'xtlabels', variables_s,'violinwidth',2,'boxwidth',1,'violin','half', ...
        'linkline',1); % 'legend',variables_s

    ylabel('Amplitude (µV)','FontSize',15)
    xlabel('Repitition','FontSize',15)
    ax = gca;
    ax.FontSize = 15;
    xlim([0.5 cols+0.5]);  % Improtant to give more space for the rightmost violin so it wont get cutted
    ylim(cfg.ylim_)
     if numel(cfg.ticksY) > 0     
        yticks(cfg.ticksY)        
    end

    ylab = get(get(gca,'YLabel'), 'String');
    xlab = get(get(gca,'XLabel'), 'String');
    ysize = get(get(gca,'YLabel'), 'FontSize');
    xsize = get(get(gca,'XLabel'), 'FontSize');
    yticks_var = get(gca, 'YTick');
    xticks = get(gca, 'XTick');
    yticklabels = get(gca, 'YTickLabel');
    xticklabels = get(gca, 'XTickLabel');

    ax_save = gca;
    set(ax_save, 'XTickLabel', [], 'YTickLabel', [], 'XLabel', [], 'YLabel', []);
    exportgraphics(ax_save, sprintf("%s_onlyAxis.png",output_filename));
    ylabel(ylab, 'FontSize', ysize);
    xlabel(xlab, 'FontSize', xsize);
    set(gca, 'YTick', yticks_var, 'YTickLabel', yticklabels);
    set(gca, 'XTick', xticks, 'XTickLabel', xticklabels);

    % plot electrodes topography
    if ~isempty(cfg.elctrds_clusts)
        axes('Position',[.02 .02 .25 .25])
        cfg_ftplot = [];
        cfg_ftplot.feedback    = 'no';
        cfg_ftplot.elec= cfg.elctrds_clusts{1};
        layout = ft_prepare_layout(cfg_ftplot);
        layout_chanindx = match_str(layout.label, cfg.elctrds_clusts{2});
        ft_plot_layout(layout,'label','no','box','no','chanindx',layout_chanindx,'pointsize',30,'pointcolor','black');
        hold on;
    end


    difference_res_string = "";
    if iscell(cfg.wilcoxon_report)
        for t_i=1:numel(cfg.wilcoxon_report)
            difference_res_string = sprintf("%s\n%s vs. %s __ %s",difference_res_string,variables_s{t_i},variables_s{t_i+1},cfg.wilcoxon_report{t_i});
        end
    end
    parametric_report_string = "";
    if iscell(cfg.parametric_report)
        for t_i=1:numel(cfg.parametric_report)
            parametric_report_string = sprintf("%s\n%s vs. %s __ %s",parametric_report_string,variables_s{t_i},variables_s{t_i+1},cfg.parametric_report{t_i});
        end
    end
    descriptive_report_string = "";
    if iscell(cfg.descriptive_report)
        for t_i=1:numel(cfg.descriptive_report)
            descriptive_report_string = sprintf("%s\n%s",descriptive_report_string,cfg.descriptive_report{t_i});
        end
    end
    

    % plot text details
    try
        % Construct the full text string with headers and information
        fig_text_info = sprintf('%s\n\n ___Electrode cluster details___\n%s', ...
            cfg.title_, cfg.subtitle_);
        if iscell(cfg.descriptive_report)
             fig_text_info = sprintf('%s\n___Descriptive_results___%s', fig_text_info, descriptive_report_string);
        end
        if iscell(cfg.wilcoxon_report)
            fig_text_info = sprintf('%s\n___Non-Parmetric results___%s', fig_text_info, difference_res_string);
        end
        if iscell(cfg.parametric_report)
            fig_text_info = sprintf('%s\n___Parametric_report results___%s', fig_text_info, parametric_report_string);
        end
        
        fig_text_info =  sprintf('%s\n___Trials stats___\n%s', fig_text_info, cfg.bottom_string);
        fig_text_info = char(fig_text_info);
    
        header_indices = regexp(fig_text_info, '___.*?___');
        num_letters = sum(isletter(fig_text_info));
    
        % Find the middle of the letter count
        mid_letter_index = floor(num_letters / 2);
        letter_count = 0;
        split_index = 0; 
        % Traverse the characters in the string and count letters
        for i = 1:numel(fig_text_info)
            if isletter(fig_text_info(i))
                letter_count = letter_count + 1;  % Count the letters
            end
            if letter_count >= mid_letter_index
                split_index = i;  % Store the character index where the letter count reaches the midpoint
                break;
            end
        end
    
        % Now split the text at the closest header to the midpoint
        if numel(header_indices) > 2
            [~, closest_header_index] = min(abs(header_indices - split_index));
            part1 = fig_text_info(1:header_indices(closest_header_index) - 1);
            part2 = fig_text_info(header_indices(closest_header_index):end);
        else
            % If there's only one header or no headers, display the text in one box
            part1 = fig_text_info;
            part2 = '';
        end
    
        % Place two textboxes in the figure
        annotation('textbox',[0.3, 0, 0.35, 0.29], 'String', part1, ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none', ...
            'Interpreter', 'none', 'FontSize', 7);
        if ~isempty(part2)
            annotation('textbox', [0.65, 0, 0.35, 0.29], 'String', part2, ...
                'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none', ...
                'Interpreter', 'none', 'FontSize', 7);
        end
    catch
        % Handle errors gracefully
    end

% 
%             try
%                 fig_text_info = sprintf("%s\n\n ___Electrode cluster details___\n%s\n\n___Trials stats___\n%s", ...
%                         cfg.title_, cfg.subtitle_,cfg.bottom_string);
%                 if cfg.difference_res
%                     fig_text_info = sprintf("%s____Differnece-sigrank results_____%s",fig_text_info,difference_res_string);
%                 end
%                 annotation('textbox', [0.3, 0, 0.95, 0.25],'String', fig_text_info, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'EdgeColor', 'none','Interpreter','none', 'FontSize', 7);
%             catch
%                 % Do nothing if the warning is triggered
%             end

    metadata= {};
    metadata.cfg = cfg;
    metadata.variables_s = variables_s;
    metadata.data = data;
    metadata.subs = subs;
    save(sprintf("%s.mat",output_filename),"metadata");
    saveas(gcf,sprintf("%s.png",output_filename));
%             saveas(gcf,sprintf("%s.svg",r.output_filename));
    saveas(gcf,sprintf("%s.fig",output_filename));
    close;
end
