clear
%clc
%close all

%% Add paths now..

%Fieldtrip path
ftp_toolbox = 'C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20151231';
%EEGlab path
eeglab_toolbox = 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab13_5_4b';
%uicromeasures path
uicromeasures_toolbox = 'C:\Users\User\OneDrive\Documents\githubProjects\PE_Omission-Anat\EventDetection\Sridhar';

addpath(ftp_toolbox);
addpath(genpath(eeglab_toolbox));
addpath(genpath(uicromeasures_toolbox));
rmpath(genpath([eeglab_toolbox '/functions/octavefunc'])); 

%% %1. Preprocessed file -- > This contains the EEGlab preprocessed file

S.eeg_filepath = 'C:\Users\User\Cloud-Drive\BigFiles\AnatArzData\Data\rerefrenced';
S.eeg_filename = ['s_32_sleep_referenced'];
% S.eeg_filepath = 'C:\Users\User\OneDrive\Desktop';
% S.eeg_filename = ['test'];

% load the preprocessed EEGdata set..
evalexp = 'pop_loadset(''filename'', [S.eeg_filename ''.set''], ''filepath'', S.eeg_filepath);';

[T,EEG] = evalc(evalexp);

%% reref to Cz
czidx = find(strcmp('Cz',{EEG.chanlocs.labels}));
EEG = pop_reref( EEG, czidx);

%% Use it to micro measure alertness levels..
% Outputs: trialstruc   - Trial indexs of alert, drowsy(mild),
%                         drowsy(severe), and also vertex, spindle, 
%                         k-complex indices..
channelconfig = '128'; %'64' or '128' or '256' channel eeg configuration..
[trialstruc] = classify_ssAndKcomp(EEG,channelconfig);