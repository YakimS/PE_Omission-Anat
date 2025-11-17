
clear
close all

%%
restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20241219
ft_defaults
addpath 'D:\matlab_libs\eeglab2023.0'
addpath 'D:\matlab_libs\sleepsmg-code-r25'
addpath 'C:\Users\User\OneDrive\Documents\githubProjects\LD_MATLAB'
eeglab nogui;


%%

fs = 250.0;
% Read the BDF file
EEG = pop_biosig('OpenBCI-BDF-2024-10-22_00-57-59.bdf', 'importevent', 'off');

% Create header structure
header = struct();
header.srate = EEG.srate;
header.channels.labels = {EEG.chanlocs.labels};
header.numChannels = EEG.nbchan;
header.pnts = EEG.pnts;

% Preprocess the data
[filteredData, selectedChannels, updatedHeader] = preprocessPSG(EEG.data, header);

% After preprocessing
EEG = pop_saveset(EEG, 'filename', 'OpenBCI-BDF-2024-10-22_00-57-59.set', 'filepath', pwd);

%%

% Plot specific epoch (e.g., epoch 10)
plotPSGEpoch(filteredData, updatedHeader, 200);


%%
% Save the filtered data
outputFilename = 'filtered_PSG_data.bdf';
saveFilteredBDF(filteredData, updatedHeader, EEG, outputFilename);
 %%

 function saveFilteredBDF(filteredData, updatedHeader, originalEEG, outputFilename)
    % Create a new EEG structure for the filtered data
    EEG = originalEEG;
    
    % Update the data and channel information
    EEG.data = filteredData;
    EEG.nbchan = size(filteredData, 1);
    EEG.chanlocs = EEG.chanlocs(1:EEG.nbchan);
    
    % Update channel labels
    for i = 1:EEG.nbchan
        EEG.chanlocs(i).labels = updatedHeader.channels.labels{i};
    end
    
    % Add processing history to EEG.comments
    EEG.comments = sprintf(['Filtered data: Bandpass (0.3-30 Hz) and Notch (50 Hz)\n', ...
                          'Original file: %s\n', ...
                          'Processing date: %s'], ...
                          originalEEG.filename, datestr(now));
    
    % Save using EEGLAB's file saving function
    EEG = eeg_checkset(EEG);
    pop_writeeeg(EEG, outputFilename, 'TYPE', 'BDF');
 end

 function [filteredData, selectedChannels, updatedHeader] = preprocessPSG(data, header)
    % Find channels to process (exclude specified patterns)
    excludePatterns = {'Accel', 'BDF Annotations'};
    channelMask = true(1, header.numChannels);
    
    for pattern = excludePatterns
        channelMask = channelMask & ~contains(header.channels.labels, pattern);
    end
    selectedChannels = find(channelMask);
    
    % Design bandpass filter
    filterOrder = 4;
    lowFreq = 0.3;
    highFreq = 30;
    [b_band, a_band] = butter(filterOrder, [lowFreq highFreq]/(header.srate/2), 'bandpass');
    
    % Design 50 Hz notch filter manually
    notchFreq = 50;
    Q = 35;  % Quality factor - higher Q means narrower notch
    w0 = notchFreq/(header.srate/2);
    bw = w0/Q;
    
    % Create notch filter coefficients
    [b_notch, a_notch] = butter(2, [w0-bw, w0+bw], 'stop');
    
    % Initialize filtered data
    filteredData = zeros(length(selectedChannels), size(data, 2));
    
    % Apply filters to each selected channel
    for i = 1:length(selectedChannels)
        % Remove DC offset
        signalData = data(selectedChannels(i),:);
        signalData = signalData - mean(signalData);
        
        % Apply notch filter first
        signalData = filtfilt(b_notch, a_notch, double(signalData));
        
        % Then apply bandpass filter
        filteredData(i,:) = filtfilt(b_band, a_band, signalData);
    end
    
    % Update header for selected channels
    updatedHeader = header;
    updatedHeader.channels.labels = header.channels.labels(selectedChannels);
    updatedHeader.numChannels = length(selectedChannels);
end
function merged = mergeStructs(default, user)
    % Helper function to merge two structures
    merged = default;
    fields = fieldnames(user);
    for i = 1:length(fields)
        if isfield(default, fields{i})
            merged.(fields{i}) = user.(fields{i});
        end
    end
end

function plotPSGEpoch(data, header, epochNum)
    % Calculate samples for 30 seconds
    samplesPerEpoch = 30 * header.srate;
    totalEpochs = floor(size(data, 2) / samplesPerEpoch);
    
    % Validate epoch number
    if nargin < 3
        epochNum = randi([1, totalEpochs]);
    elseif epochNum > totalEpochs
        error('Epoch number exceeds available epochs. Max epoch: %d', totalEpochs);
    end
    
    % Calculate start and end samples
    startSample = (epochNum - 1) * samplesPerEpoch + 1;
    endSample = startSample + samplesPerEpoch - 1;
    
    % Extract epoch data
    epochData = data(:, startSample:endSample);
    
    % Create time vector
    t = (0:samplesPerEpoch-1) / header.srate;
    
    % Plot each channel
    figure('Position', [100 100 1200 800]);
    numChannels = size(data, 1);
    
    for i = 1:numChannels
        subplot(numChannels, 1, i);
        plot(t, epochData(i,:), 'b');
        ylabel(header.channels.labels{i}, 'Interpreter', 'none');
        
        if i == numChannels
            xlabel('Time (seconds)');
        end
        
        if i == 1
            title(sprintf('30-second PSG Epoch %d of %d (%.1f - %.1f minutes)', ...
                  epochNum, totalEpochs, ...
                  (startSample-1)/header.srate/60, ...
                  endSample/header.srate/60));
        end
        
        xlim([0 30]);
        grid on;
    end
end

function [data, header] = readBDF(filename)
    % Check if EEGLAB is in the path
    if ~exist('pop_biosig', 'file')
        error('Please install EEGLAB first. You can download it from: https://sccn.ucsd.edu/eeglab/download.php');
    end
    
    % Read the BDF file using EEGLAB's BIOSIG interface
    EEG = pop_biosig(filename);
    
    % Extract data and important header information
    data = EEG.data;
    
    % Create header structure
    header = struct();
    header.srate = EEG.srate;
    header.channels = struct();
    header.channels.labels = {EEG.chanlocs.labels};
    header.numChannels = EEG.nbchan;
    header.pnts = EEG.pnts;
    header.times = EEG.times;
    
    % Calculate recording duration in seconds
    header.duration = EEG.pnts / EEG.srate;
end
