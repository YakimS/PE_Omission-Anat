%% GENERAL SPECIFICATIONS OF THE EXPERIMENT 
filenames = {
                'S01_ds000117_EEG' ...
                'S01_ds000117_MEG_grad' ... 
                'S02_ds000117_EEG' 'S02_ds000117_MEG_grad' ...
                'S03_ds000117_EEG' 'S03_ds000117_MEG_grad' ...
                'S04_ds000117_EEG' 'S04_ds000117_MEG_grad' ...
                'S05_ds000117_EEG' 'S05_ds000117_MEG_grad' ...
                'S06_ds000117_EEG' 'S06_ds000117_MEG_grad' ...
                'S07_ds000117_EEG' 'S07_ds000117_MEG_grad' ...
                'S08_ds000117_EEG' 'S08_ds000117_MEG_grad' ...
                'S09_ds000117_EEG' 'S09_ds000117_MEG_grad' ...
                'S10_ds000117_EEG' 'S10_ds000117_MEG_grad' ...
                'S11_ds000117_EEG' 'S11_ds000117_MEG_grad' ...
                'S12_ds000117_EEG' 'S12_ds000117_MEG_grad' ...
                'S13_ds000117_EEG' 'S13_ds000117_MEG_grad' ...
                'S14_ds000117_EEG' 'S14_ds000117_MEG_grad' ...
                'S15_ds000117_EEG' 'S15_ds000117_MEG_grad' ...
                'S16_ds000117_EEG' 'S16_ds000117_MEG_grad' ...
                'S17_ds000117_EEG' 'S17_ds000117_MEG_grad' ...
                'S18_ds000117_EEG' 'S18_ds000117_MEG_grad' ...
                'S19_ds000117_EEG' 'S19_ds000117_MEG_grad' ...
                };
eeg_filenames = file_list_restrict(filenames,'EEG');    % only EEG files
meg_filenames = file_list_restrict(filenames,'MEG');    % only MEG files

% event code specifications for factor stimulus type
famous_faces = [5 6 7];                    % specifies event codes of all famous faces
nonfamous_faces = [13 14 15];              % specifies event codes of all non-famous faces
scrambled_faces = [17 18 19];              % specifies event codes of all scrambled faces

% event code specifications for factor stimulus repetition
first_presentation = [5 13 17];            % specifies event codes of all first presentations
immediate_repeat = [6 14 18];              % specifies event codes of all immediate repeats
delayed_repeat = [7 15 19];                % specifies event codes of all delayed repeats

% GENERAL ANALYSIS CONFIGURATION SETTINGS
cfg = [];                                  % clear the config variable
cfg.datadir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\DATA_demo';            % this is where the data files are
cfg.model = 'BDM';                         % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';                    % classify raw or time frequency representations ('tfr')
cfg.nfolds = 5;                            % the number of folds to use
cfg.class_method = 'AUC';             	   % the performance measure to use
cfg.crossclass = 'yes';                    % whether to compute temporal generalization
cfg.channelpool = 'ALL_NOSELECTION';       % the channel selection to use 
cfg.resample = 55;                         % downsample (useful for temporal generalization)
cfg.erp_baseline = [-.1,0];                % baseline correction in sec. ('no' for no correction)

%% SPECIFIC SETTINGS FOR EACH OF THE SIX FIRST LEVEL ANALYSES
% EEG NONFAMOUS VERSUS SCRAMBLED FACES
cfg.filenames = eeg_filenames;             % specifies filenames (EEG in this case)
cfg.class_spec{1} = cond_string(nonfamous_faces,first_presentation);  % the first stimulus class
cfg.class_spec{2} = cond_string(scrambled_faces,first_presentation);  % the second stimulus class
cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS_demo\EEG_RAW\EEG_NONFAM_VS_SCRAMBLED';  % output location
adam_MVPA_firstlevel(cfg);                 % run first level analysis
% 
% % EEG FAMOUS VERSUS SCRAMBLED FACES
% cfg.filenames = eeg_filenames;             % specifies filenames (EEG in this case)
% cfg.class_spec{1} = cond_string(famous_faces,first_presentation);     % the first stimulus class
% cfg.class_spec{2} = cond_string(scrambled_faces,first_presentation);  % the second stimulus class
% cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS\EEG_RAW\EEG_FAM_VS_SCRAMBLED';     % output location
% adam_MVPA_firstlevel(cfg);                 % run first level analysis
% 
% % EEG FAMOUS VERSUS NON-FAMOUS FACES
% cfg.class_spec{1} = cond_string(famous_faces,first_presentation);     % the first stimulus class
% cfg.class_spec{2} = cond_string(nonfamous_faces,first_presentation);  % the second stimulus class
% cfg.filenames = eeg_filenames;             % specifies filenames (EEG in this case)
% cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS\EEG_RAW\EEG_FAM_VS_NONFAMOUS';     % output location
% adam_MVPA_firstlevel(cfg);                 % run first level analysis
% 
% % MEG NONFAMOUS VERSUS SCRAMBLED FACES
% cfg.filenames = meg_filenames;             % specifies filenames (MEG in this case)
% cfg.class_spec{1} = cond_string(nonfamous_faces,first_presentation);  % the first stimulus class
% cfg.class_spec{2} = cond_string(scrambled_faces,first_presentation);  % the second stimulus class
% cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS\MEG_RAW\MEG_NONFAM_VS_SCRAMBLED';  % output location
% adam_MVPA_firstlevel(cfg);                 % run first level analysis
% 
% % MEG FAMOUS VERSUS SCRAMBLED FACES
% cfg.filenames = meg_filenames;             % specifies filenames (MEG in this case)
% cfg.class_spec{1} = cond_string(famous_faces,first_presentation);     % the first stimulus class
% cfg.class_spec{2} = cond_string(scrambled_faces,first_presentation);  % the second stimulus class
% cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS\MEG_RAW\MEG_FAM_VS_SCRAMBLED';     % output location
% adam_MVPA_firstlevel(cfg);                 % run first level analysis
% 
% % MEG FAMOUS VERSUS NON-FAMOUS FACES
% cfg.filenames = meg_filenames;             % specifies filenames (MEG in this case)
% cfg.class_spec{1} = cond_string(famous_faces,first_presentation);     % the first stimulus class
% cfg.class_spec{2} = cond_string(nonfamous_faces,first_presentation);  % the second stimulus class
% cfg.outputdir = 'C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo\RESULTS\MEG_RAW\MEG_FAM_VS_NONFAMOUS';     % output location
% adam_MVPA_firstlevel(cfg);                 % run first level analysis
