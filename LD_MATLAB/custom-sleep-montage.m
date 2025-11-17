function custom_Montage(handles, range)
% Custom montage for your specific channel configuration
% Inputs:
%   handles - struct containing figure handles and EEG data
%   range - current range (in data points) to plot

%% Setup
% Define which channels to use and their colors
electrodes = {'1', '2', '3', '4', '5', '6', '7', '8'};  % Original channel names
labels = {'EOG', 'Nostr', 'Chin', 'FP2', 'F3', 'F4', 'C4', 'O2'}; % Display names
colors = {[0 0 1], [1 0 0], [0 1 0], [0.5 0 0.5], [0 0.5 0.5], [0.5 0.5 0], [0.7 0 0], [0 0 0.7]};

%% Plot each channel
hold(handles.mainAxes, 'off');
plotChannel(handles, range, electrodes{1}, labels{1}, colors{1}, 1, 8); % EOG
plotChannel(handles, range, electrodes{2}, labels{2}, colors{2}, 2, 8); % Nostril EMG
plotChannel(handles, range, electrodes{3}, labels{3}, colors{3}, 3, 8); % Chin EMG
plotChannel(handles, range, electrodes{4}, labels{4}, colors{4}, 4, 8); % FP2
plotChannel(handles, range, electrodes{5}, labels{5}, colors{5}, 5, 8); % F3
plotChannel(handles, range, electrodes{6}, labels{6}, colors{6}, 6, 8); % F4
plotChannel(handles, range, electrodes{7}, labels{7}, colors{7}, 7, 8); % C4
plotChannel(handles, range, electrodes{8}, labels{8}, colors{8}, 8, 8); % O2

% Set axis properties
set(handles.mainAxes, 'YTick', 1:8);
set(handles.mainAxes, 'YTickLabel', labels);
set(handles.mainAxes, 'YDir', 'reverse');
grid(handles.mainAxes, 'on');

function plotChannel(handles, range, channel, label, color, position, total)
% Helper function to plot individual channels
% Get channel index
chanIdx = find(strcmp({handles.EEG.chanlocs.labels}, channel));
if isempty(chanIdx)
    warning(['Channel ' channel ' not found']);
    return;
end

% Get data for current range
data = handles.EEG.data(chanIdx, range(1):range(2));

% Scale data to fit in one unit space
scale = 0.4;
data = (data / (2 * std(data))) * scale;

% Plot the data
plot(handles.mainAxes, range(1):range(2), data + position, 'Color', color);
hold(handles.mainAxes, 'on');

% Add scale lines for EEG channels (optional)
if any(strcmp(label, {'FP2', 'F3', 'F4', 'C4', 'O2'}))
    % Add 50µV scale lines
    plot(handles.mainAxes, [range(1) range(2)], ...
         [position+scale position+scale], ':', 'Color', 'r');
    plot(handles.mainAxes, [range(1) range(2)], ...
         [position-scale position-scale], ':', 'Color', 'r');
end
