clear
clc
close all

%% Add paths now..

%Fieldtrip path
ftp_toolbox = 'C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20151231';
%EEGlab path
eeglab_toolbox = 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab13_5_4b';
%uicromeasures path
uicromeasures_toolbox = 'C:\Users\User\OneDrive\Documents\githubProjects\PE_Omission-Anat\EventDetection\Sridhar';
%Model file -- > This contains the Model file for classification
S.model_filepath = [ uicromeasures_toolbox '/models/'];
S.model_filename = ['model_collec64_'];
modelfilepath = [ S.model_filepath S.model_filename];

addpath(ftp_toolbox);
addpath(genpath(eeglab_toolbox));
addpath(genpath(uicromeasures_toolbox));
rmpath(genpath([eeglab_toolbox '/functions/octavefunc'])); 

%% %1. Preprocessed file -- > This contains the EEGlab preprocessed file

S.eeg_filepath = 'C:\Users\User\Cloud-Drive\BigFiles\AnatArzData\Data\preProcessed';
S.eeg_filename = ['s_32_sleep2_preProcessed'];

% load the preprocessed EEGdata set..
evalexp = 'pop_loadset(''filename'', [S.eeg_filename ''.set''], ''filepath'', S.eeg_filepath);';

[T,EEG] = evalc(evalexp);

%% reref to Cz
czidx = find(strcmp('Cz',{EEG.chanlocs.labels}));
EEG = pop_reref( EEG, czidx);

%%
ALL_EEGS = [];
pnts = EEG.pnts;
num_of_parts = 100; %25 too much
sec_in_part = pnts / num_of_parts /EEG.srate;
process_part = 10;
for i= 1:process_part
    ALL_EEGS = [ALL_EEGS, pop_select(EEG, 'time', [round(sec_in_part * (i-1)) ,round(sec_in_part * i)])];
end
 
%% Use it to micro measure alertness levels..
% Outputs: trialstruc   - Trial indexs of alert, drowsy(mild),
%                         drowsy(severe), and also vertex, spindle, 
%                         k-complex indices..
channelconfig = '128'; %'64' or '128' or '256' channel eeg configuration..

trial_structs = [];
for i= 1:process_part
    curr_struct =  classify_microMeasures(ALL_EEGS(i), modelfilepath,channelconfig);
    trial_structs = [trial_structs,curr_struct];
end


