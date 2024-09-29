restoredefaultpath
addpath D:\matlab_libs\fieldtrip-20230223
ft_defaults
addpath 'D:\matlab_libs\eeglab2023.0'
eeglab nogui;

%%  {'Cz','E31','E80','E55','E7','E106'} 
input_set_dir = 'D:\\AnatArzData\Data\preProcessed';
set_output_dir = 'D:\OExpOut\processed_data\set_subSovCond';
ft_output_dir = 'D:\OExpOut\processed_data\ft_subSovCond';
events_dir = 'D:\AnatArzData\Data\imported\elaborated_events';
ica_input_dir = 'D:\AnatArzData\Data\ica';
event_statistics_dir = 'D:\OExpOut\event_statistics';
set_imported = 'D:\AnatArzData\Data\imported';
set_preProcessed = 'D:\AnatArzData\Data\preProcessed';

events_withN2events_dir = "D:\OExpOut\old\eventDetection\try2\imported_eventDetectionChan\no_filters\events_with_sleepevents";

new_sample_rate = 250;
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','38'};

%%  Test subCondSov files
responses_AT = zeros([numel(subs),1525]);
events_AT = {};
for sub_i=1:numel(subs)
    EEG_AT_sub_file = pop_loadset('filename', sprintf('s-%s_sov-wake_night_LastAT.set',subs{sub_i}), 'filepath', set_output_dir);
    responses_AT(sub_i,:) = mean(EEG_AT_sub_file.data([6,25,43,92,93,79],:,:),[1,3]);
    curr_epochs = {};
    for epoch_i=1:numel(EEG_AT_sub_file.epoch)
        curr_epochs{end+1} = EEG_AT_sub_file.epoch(epoch_i).eventurevent{1};
    end
    events_AT{end+1} = curr_epochs;
end
responses_AT_mean = mean(responses_AT,1);

responses_AO = zeros([numel(subs),1525]);
events_AOF = {};
for sub_i=1:numel(subs)
    EEG_AOF_sub_file = pop_loadset('filename', sprintf('s-%s_sov-wake_night_LastAOF.set',subs{sub_i}), 'filepath', set_output_dir);
    responses_AO(sub_i,:) = mean(EEG_AOF_sub_file.data([6,25,43,92,93,79],:,:),[1,3]);
    curr_epochs = {};
    for epoch_i=1:numel(EEG_AOF_sub_file.epoch)
        curr_epochs{end+1} = EEG_AOF_sub_file.epoch(epoch_i).eventurevent{1};
    end
    events_AOF{end+1} = curr_epochs;
end
responses_AO_mean = mean(responses_AO,1);

plot(EEG_AOF_sub_file.times,responses_AT_mean,'DisplayName','AT');
hold on;
plot(EEG_AOF_sub_file.times,responses_AO_mean,'DisplayName','AOF');
legend();


%%  Test orig files
EEGs_after_extraction_AOF = {};
EEGs_after_extraction_AT = {};
for sub_i=1:numel(subs)
    EEG_orig_sub_file = pop_loadset('filename', sprintf('s_%s_wake_night_orig.set',subs{sub_i}), 'filepath', set_imported);
    EEG_orig_sub_file_reref = pop_reref( EEG_orig_sub_file, []);

    EEG_orig_sub_OFevents = pop_epoch(EEG_orig_sub_file_reref,{},[-0.1 6],'eventindices',cellfun(@(x) int32(x), events_AOF{sub_i}));
    EEG_orig_sub_OFevents_chan = pop_select(EEG_orig_sub_OFevents, 'channel', {'Cz','E31','E80','E55','E7','E106'});
    EEG_after_rebase =  pop_rmbase(EEG_orig_sub_OFevents_chan, [-(1000*0.1)   0]);
    [EEG_after_thresh, Indexes] = pop_eegthresh(EEG_after_rebase, 1, 1:size(EEG_after_rebase.data,1), -250, 250, -0.1, 6, 0, 1);
    EEGs_after_extraction_AOF{end+1} =EEG_after_thresh;

    EEG_orig_sub_ATevents = pop_epoch(EEG_orig_sub_file_reref,{},[-0.1 6],'eventindices',cellfun(@(x) int32(x), events_AT{sub_i}));
    EEG_orig_sub_ATevents_chan = pop_select(EEG_orig_sub_ATevents, 'channel', {'Cz','E31','E80','E55','E7','E106'});
    EEG_after_rebase =  pop_rmbase(EEG_orig_sub_ATevents_chan, [-(1000*0.1)   0]);
    [EEG_after_thresh, Indexes] = pop_eegthresh(EEG_after_rebase, 1, 1:size(EEG_after_rebase.data,1), -250, 250, -0.1, 6, 0, 1);
    EEGs_after_extraction_AT{end+1} =EEG_after_thresh;
end

%%
responses_AOF_orig = zeros([numel(subs),3050]);
for sub_i=1:numel(EEGs_after_extraction_AOF)
    responses_AOF_orig(sub_i,:) = mean(EEGs_after_extraction_AOF{sub_i}.data,[1,3]);
end 

responses_AT_orig = zeros([numel(subs),3050]);
for sub_i=1:numel(EEGs_after_extraction_AT)
    responses_AT_orig(sub_i,:) = mean(EEGs_after_extraction_AT{sub_i}.data,[1,3]);
end

responses_AOF_orig_mean = mean(responses_AOF_orig,1);
responses_AT_orig_mean = mean(responses_AT_orig,1);
%%
plot(responses_AOF_orig_mean,'DisplayName','AOF_Orig');
hold on;
plot(responses_AT_orig_mean,'DisplayName','AT_Orig');
legend();


%%  Test preprocessed files
EEGs_after_extractionPrepro_AOF = {};
EEGs_after_extractionPrepro_AT = {};
for sub_i=1:numel(subs)
    EEG_prepro_sub_file = pop_loadset('filename', sprintf('s_%s_wake_night_preProcessed.set',subs{sub_i}), 'filepath', set_preProcessed);
    EEG_currSovEvent_reref = pop_reref( EEG_prepro_sub_file, []);

    EEG_prepro_sub_OFevents = pop_epoch(EEG_currSovEvent_reref,{},[-0.1 3],'eventindices',cellfun(@(x) int32(x), events_AOF{sub_i}));
    EEG_prepro_sub_OFevents_chan = pop_select(EEG_prepro_sub_OFevents, 'channel', {'Cz','E31','E80','E55','E7','E106'});
    EEG_after_rebase =  pop_rmbase(EEG_prepro_sub_OFevents_chan, [-(1000*0.1)   0]);
    [EEG_after_thresh, Indexes] = pop_eegthresh(EEG_after_rebase, 1, 1:size(EEG_after_rebase.data,1), -250, 250, -0.1, 3, 0, 1);
    EEGs_after_extractionPrepro_AOF{end+1} =EEG_after_thresh;

    EEG_prepro_sub_ATevents = pop_epoch(EEG_currSovEvent_reref,{},[-0.1 3],'eventindices',cellfun(@(x) int32(x), events_AT{sub_i}));
    EEG_prepro_sub_ATevents_chan = pop_select(EEG_prepro_sub_ATevents, 'channel', {'Cz','E31','E80','E55','E7','E106'});
    EEG_after_rebase =  pop_rmbase(EEG_prepro_sub_ATevents_chan, [-(1000*0.1)   0]);
    [EEG_after_thresh, Indexes] = pop_eegthresh(EEG_after_rebase, 1, 1:size(EEG_after_rebase.data,1), -250, 250, -0.1, 3, 0, 1);
    EEGs_after_extractionPrepro_AT{end+1} =EEG_after_thresh;
end

responses_AOF_prepro = zeros([numel(subs),1550]);
for sub_i=1:numel(EEGs_after_extractionPrepro_AOF)
    responses_AOF_prepro(sub_i,:) = mean(EEGs_after_extractionPrepro_AOF{sub_i}.data,[1,3]);
end

responses_AT_prepro = zeros([numel(subs),1550]);
for sub_i=1:numel(EEGs_after_extractionPrepro_AT)
    responses_AT_prepro(sub_i,:) = mean(EEGs_after_extractionPrepro_AT{sub_i}.data,[1,3]);
end

responses_AOF_prepro_mean = mean(responses_AOF_prepro,1);
responses_AT_prepro_mean = mean(responses_AT_prepro,1);
%%
plot(EEGs_after_extractionPrepro_AOF{sub_i}.times,responses_AOF_prepro_mean,'DisplayName','AOF_prepro');
hold on;
plot(EEGs_after_extractionPrepro_AT{sub_i}.times,responses_AT_prepro_mean,'DisplayName','AT_prepro');
legend();


