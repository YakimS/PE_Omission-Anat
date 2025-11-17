
% if event_lines.time is single number it creates a line, if 2, it creates a transparent rectangle
function plot_erps(epoch_time,variables_s,data,output_filename, var_colormap,cfg)
    if ~isfield(cfg, 'is_plot_subs')                cfg.is_plot_subs = false; end  
    if ~isfield(cfg, 'is_plot_ste')                 cfg.is_plot_ste = true; end 
    if ~isfield(cfg, 'plot_bp_filter')              cfg.plot_bp_filter = 'no'; end
    if ~isfield(cfg, 'ylim_')                       cfg.ylim_ =  [-1.2 2]; end
    if ~isfield(cfg, 'plot_latency')                cfg.plot_latency = [epoch_time(1), epoch_time(end)]; end
    if ~isfield(cfg, 'event_lines')                 cfg.event_lines = {}; end 

    if ~isfield(cfg, 'elctrds_clusts')              cfg.elctrds_clusts = []; end 
    if ~isfield(cfg, 'subtitle_')                   cfg.subtitle_ = ""; end 
    if ~isfield(cfg, 'title_')                      cfg.title_ = {}; end 
    if ~isfield(cfg, 'bottom_string')               cfg.bottom_string = ""; end 
    if ~isfield(cfg, 'sig_timeranges')              cfg.sig_timeranges = {}; end 
    if ~isfield(cfg, 'sig_timeranges_colormaps')     cfg.sig_timeranges_colormaps = {}; end 

    if ~isfield(cfg, 'ticksX')                      cfg.ticksX = []; end
    if ~isfield(cfg, 'ticksY')                      cfg.ticksY = []; end
    if ~isfield(cfg, 'axisFontSize')                cfg.axisFontSize = 15; end
    if ~isfield(cfg, 'LineWidth')                   cfg.LineWidth = (cfg.ylim_(2) - cfg.ylim_(1))*0.3; end

    if ~isfield(cfg, 'is_legend')                   cfg.is_legend = true; end
    if ~isfield(cfg, 'is_svg_plot')                   cfg.is_svg_plot = false; end

    if  ~cfg.is_plot_ste && ...
        (size(variables_s,2)==1 || (isstring(variables_s{1}) && numel(variables_s)==1))
        cfg.is_plot_ste = false;
        cfg.is_plot_subs = true;
    end

    fig = figure('Visible', 'off','Position', [0, 0, 1000, 1000], 'Color', 'white');

    subplot('Position', [0.1, 0.4, 0.8, 0.55]);

    h_line = plot([min(epoch_time) max(epoch_time)], [0 0], '--', 'Color', [0.7 0.7 0.7], 'LineWidth', 1, 'HandleVisibility', 'off');
    hold on

    % plot variables lines
    one_div_sqrt_samp_size = 1/sqrt(size(data,1));
    for val_i=numel(variables_s):-1:1
        if isstring(variables_s{val_i}) || ischar(variables_s{val_i})
            curr_var_val_name =variables_s{val_i};
        else
            curr_var_val_name = num2str(variables_s{val_i}.long_s);
        end

        curr_plot_data = data(:,:,val_i);
        if ~strcmp(cfg.plot_bp_filter, 'no')
            bpFilt = designfilt('bandpassfir', 'FilterOrder', 100, ...
                               'CutoffFrequency1',cfg.plot_bp_filter(1), ...
                               'CutoffFrequency2', cfg.plot_bp_filter(2), ...
                                'SampleRate', 250);
            for i = 1:size(data, 1)
                curr_plot_data(i, :) = filtfilt(bpFilt, curr_plot_data(i, :));
            end
        end

        
        % r.var_colormap need to keep being N x 3, N=#vars.
        if(cfg.is_plot_subs)
            x = squeeze(curr_plot_data);

            var_colormap = lines(size(x,1));
            for val_i = 1:size(x,1)
                plot(epoch_time, x(val_i,:), 'color', [var_colormap(val_i, :)], 'HandleVisibility', 'off', 'LineWidth', 1); % Use color with transparency
                hold on;
            end
%                     plot(time_,x,'color',[var_colormap(val_i,:) 0.3], 'HandleVisibility', 'off'); hold on;
            if isfield(cfg, 'plot_each_sub_comp_latency') 
                structfun(@(curr_comp) ...
                    structfun(@(curr_sov) ...
                        structfun(@(curr_sub) ...
                            structfun(@(curr_cond) ...
                                plot(curr_cond.latency, curr_cond.amplitude, ...
                                'bo', 'MarkerSize', 3, 'MarkerFaceColor', curr_cond.color, ...
                                'HandleVisibility', 'off'), ...
                            curr_sub, 'UniformOutput', false), ...
                        curr_sov, 'UniformOutput', false), ...
                    curr_comp, 'UniformOutput', false), ...
                cfg.plot_each_sub_comp_latency, 'UniformOutput', false);
            end
        end
        if(cfg.is_plot_ste)
            x = squeeze(curr_plot_data);
            
            shadedErrorBar2(epoch_time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',var_colormap(val_i,:),'DisplayName',curr_var_val_name,'LineWidth', 1.5},'patchSaturation',0.1); hold on;
        else
            mean_subs = squeeze(mean(curr_plot_data,1));
            if(cfg.is_plot_subs)
                plot(epoch_time,mean_subs,'Color','black','DisplayName',curr_var_val_name,'LineWidth', 1.5); hold on;
            else
                plot(epoch_time,mean_subs,'Color',var_colormap(val_i,:),'DisplayName',curr_var_val_name,'LineWidth', 1.5); hold on;
            end
        end               
    end

    if(cfg.is_plot_subs)
        cfg.ylim_ = cfg.ylim_ * 1.5;
    end

    uistack(h_line, 'bottom')  % Moves the line to the bottom of the stack

    % plot event type vertical line
    text_pos_factor = 0.8;
    if ~isempty(cfg.event_lines)
        field_names = fieldnames(cfg.event_lines);
        for event_i = 1:numel(field_names)
            current_field = field_names{event_i};
            event_time = cfg.event_lines.(current_field).('event_time');
            event_color = cfg.event_lines.(current_field).('event_color');
            event_text_color = cfg.event_lines.(current_field).('event_text_color');
            event_text = cfg.event_lines.(current_field).('event_text');
            if isscalar(event_time)
                plot([event_time, event_time], cfg.ylim_,'Color',event_color, 'LineWidth', 1,'DisplayName','','HandleVisibility', 'off');
                text(event_time+(cfg.plot_latency(2)-cfg.plot_latency(1))/150, text_pos_factor*cfg.ylim_(2), event_text,'Color',event_text_color, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',20,'LineStyle','--');
            else
                rect_position = [event_time(1), cfg.ylim_(1), (event_time(2)-event_time(1)), abs(cfg.ylim_(1))+abs(cfg.ylim_(2))]; % [x, y, width, height] cfg.ylim_(2)
                hRect = rectangle('Position', rect_position, 'FaceColor', event_color(1:3), 'EdgeColor', 'none','FaceAlpha', event_color(4));
                uistack(hRect, 'bottom');
                text(event_time(1)+(cfg.plot_latency(2)-cfg.plot_latency(1))/150, text_pos_factor*cfg.ylim_(2), event_text,'Color',event_text_color, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle','FontSize',20,'LineStyle','--');
            end
        end
    end


    % plot sig line
    general_sig_line_height_factor = 5; % where the sig lines starts. The smaller, the higher.
    distance_between_lines_factor = 0.02;
    num_of_sig_lines = 0;
    for i=1:numel(cfg.sig_timeranges)
        if ~isempty(cfg.sig_timeranges{i})
            num_of_sig_lines = num_of_sig_lines +1;
            sig_seqs = findNonZeroSequences(cfg.sig_timeranges{i});
            for j=1:numel(sig_seqs)
                sig_line_height =   cfg.ylim_(1) + ((cfg.ylim_(2) - cfg.ylim_(1)) / general_sig_line_height_factor) - ((num_of_sig_lines-1) * (cfg.ylim_(2) - cfg.ylim_(1))*distance_between_lines_factor);
                curr_colormap = cfg.sig_timeranges_colormaps{i};
                plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{1},'DisplayName','','HandleVisibility', 'off','LineWidth',cfg.LineWidth);
                hold on;
                plot(sig_seqs{j},sig_line_height*ones(numel(sig_seqs{j})),'Color',curr_colormap{2},'DisplayName','','HandleVisibility', 'off','LineWidth',cfg.LineWidth,LineStyle='--');
                hold on;
            end
        end
    end
   
    axis([cfg.plot_latency(1) cfg.plot_latency(end) cfg.ylim_(1) cfg.ylim_(2)]) 
    if cfg.is_legend
        legend("Location","northeast","FontSize",12);
    end
    xlabel('Time (s)','FontSize',15)
    ylabel('Amplitude (µV)','FontSize',15)
    ax = gca;
    ax.FontSize = cfg.axisFontSize;
    if numel(cfg.ticksX) > 0     
        xticks(cfg.ticksX)       
    end
    if numel(cfg.ticksY) > 0     
        yticks(cfg.ticksY)        
    end
    
%             if r.plot_latency(2)>= 5
%                 set(gcf,'Position',[0 0 1300 400])
%             else
%                 set(gcf,'Position',[0 0 1300 400])
%             end
   
    
    ax = gca;
    props = {'YLabel', 'XLabel', 'YTick', 'XTick', 'YTickLabel', 'XTickLabel'};
    orig_vals = get(ax, props);
    
    % Store size
    set(ax, 'Units', 'inches');
    ax_size = get(ax, 'Position');
    set(ax, 'Units', 'normalized');
    newfig = figure('Visible', 'off', 'Units', 'inches', 'Position', [1 1 ax_size(3)*1.2 ax_size(4)*1.2]);
    newax = copyobj(ax, newfig);
    set(newax, 'Position', [0.1 0.1 0.8 0.8], 'XTickLabel', [], 'YTickLabel', [], 'XLabel', [], 'YLabel', []);
   if cfg.is_svg_plot     
        print(newfig, '-dsvg', '-painters', sprintf('%s_onlyAxis.svg', output_filename));
   else
       exportgraphics(newax, sprintf("%s_onlyAxis.png",output_filename));
   end
    close(newfig);
    set(ax, props, orig_vals); % Restore original state
    

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

    % plot text details
    try
        % Construct the full text string with headers and information
        fig_text_info = sprintf('%s\n\n ___Electrode cluster details___\n%s\n\n___Trials stats___\n%s', ...
            cfg.title_, cfg.subtitle_, cfg.bottom_string);
        if ~strcmp(cfg.plot_bp_filter, 'no')
            fig_text_info = sprintf("%s\n\nBandpass: %.1f,%.1f",fig_text_info,cfg.plot_bp_filter(1),cfg.plot_bp_filter(2));
        end
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


    metadata= {};
    metadata.cfg = cfg;
    metadata.variables_s = variables_s;
    metadata.data = data;
    metadata.time_ = epoch_time;
    metadata = removeLargePrevious(metadata);
    save(sprintf("%s.mat",output_filename),"metadata");
    saveas(gcf,sprintf("%s.png",output_filename));
%             saveas(gcf,sprintf("%s.svg",r.output_filename));
    saveas(gcf,sprintf("%s.fig",output_filename));
    close;
end

function nonZeroSequences = findNonZeroSequences(array)
    nonZeroSequences = {}; % Initialize cell array to hold sequences
    currentSequence = [];  % Initialize an empty array for the current sequence
    
    for i = 1:length(array)
        if array(i) ~= 0
            % Add the number to the current sequence
            currentSequence = [currentSequence, array(i)];
        else
            if ~isempty(currentSequence)
                % Add the current sequence to the cell array and reset it
                nonZeroSequences{end+1} = currentSequence;
                currentSequence = [];
            end
        end
    end
    
    % Check if the last sequence goes until the end of the array
    if ~isempty(currentSequence)
        nonZeroSequences{end+1} = currentSequence;
    end
end