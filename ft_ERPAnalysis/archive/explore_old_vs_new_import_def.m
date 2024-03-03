restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
clear;
close;
%%
sub = '10';
ses = 'wake_morning';
elabo_events_table = load(sprintf('C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\rerefrenced\\elaborated_events+outliers\\s_%s_%s_referenced_elaboEvents+outliers.mat',sub,ses));
elabo_events_table = elabo_events_table.events;

% old_event_name = 'OEf6';
% eeglabsub =  pop_loadset(sprintf('s_%s_%s_referenced_%s.set',sub,ses,old_event_name), 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond\before outliers exclusion');
% old_import_table = eeglabsub.event;

new_event_name = 'OFsenBig5';
% eeglabsub =  pop_loadset(sprintf('s_%s_%s_%s.set',sub,ses,new_event_name), 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond');
% new_import_table = eeglabsub.event;
% 

loaded = load(sprintf("%s\\s_%s_%s_%s.mat","C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond",sub,ses,new_event_name));
loaded = loaded.ft_data;
loaded_trial_size = size(loaded.trial,2);
indexes_value = find( strcmp({elabo_events_table.('TOA')},'O')  ...
                        & [elabo_events_table.('is_outlier_trial')] == 0 ...
                        & [elabo_events_table.('omission_type_seniority')] > 5 ...
                        & strcmp({elabo_events_table.('block_type')},'fixed'));
indexes_table = elabo_events_table(indexes_value);


% preproc_stage = 'referenced';
% ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
% set_file_name =   strcat('s_',sub,'_',ses,'_',preproc_stage,'.set');
% eeglabsub_reref =  pop_loadset(set_file_name, ref_input_dir);
% new_eeglabsub = pop_selectevent( eeglabsub_reref, 'event',indexes_value,'deleteevents','on','deleteepochs','on');
%new_new_eeglabsub = pop_selectevent( new_eeglabsub, 'omitevent',[1]);
%%
trials = false(1,numel(eeglabsub_reref.event));
trials(indexes_value) = true;

%%
cfg = []; 
cfg.dataset = sprintf('C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\rerefrenced\\s_%s_%s_%s.set',sub,ses,preproc_stage);
cfg.trials = trials;
cfg.continuous = 'no';
ft_data = ft_preprocessing(cfg);
%%
cfg = []; 
cfg.trials =trials;
cfg.continuous = 'no';
[ft_data2] = ft_selectdata(cfg, ft_data);
%%
pop_saveset(new_eeglabsub,'filepath','C:\Users\User\Cloud-Drive\BigFiles\ADAMs_demo','filename','deleteme','version','7.3');
%%
cfg = []; 
cfg.dataset = 'C:\\Users\\User\\Cloud-Drive\\BigFiles\\ADAMs_demo/deleteme.set';
cfg.continuous = 'no';
ft_data = ft_preprocessing(cfg);

cfg = []; 
cfg.trials =[false true(1,numel(ft_data.trial)-1)];
[data] = ft_selectdata(cfg, ft_data);


%%
[EEG, changes] = eeg_checkset(new_eeglabsub,'epochconsist','eventconsistency');