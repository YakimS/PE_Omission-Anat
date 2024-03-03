restoredefaultpath
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs'
eeglab nogui;
%% init
onlyTriggerAndEMG_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\onlyTriggerAndEMG';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\sniff_output';
raw_triggers_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\raw\triggers';
triggers_events_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\triggers_textfile';


channles_names = {'EMG1','EMG2','Trigger','ECG'};
subs_for_triggers = {'02','03','04','05','06','07','08','09','11','12','13','14',...
    '15','16','17','18','19','21','22','24','26','27','28','29'...
    '30','31','32','33','34','35','36','37','38'}; %'01','10', excluded. '20','23','25'
subs_emg = subs_for_triggers(~strcmp(subs_for_triggers, '35'));
subs_ecg = subs_emg(~strcmp(subs_emg, '28'));
subs_ecg = subs_ecg(~strcmp(subs_ecg, '26'));


% exclusions reasons:
%  - Subject 01 has 260 triggers
%  - Subject 10 has only 9 events
%sub 20 have 28 events,, and 36 data triggers. sub 20 have minsum 121.639999.
%sub 23 have 30 events, and 136 data triggers. sub 23 have minsum 1100.643000
% sub 25 have 30 events, and 52 data triggers. sub 25 have minsum 1325.603000
% sub 28,26 has bad ECG
%sub 35 have 27 events, and 29 data triggers. It is possible to add him, but requires change in code

conds_colors = {[0,0,1], [1,0,1], [0,1,0]};
conds_names = {'None', 'Pleasant', 'Unpleasant'};
categories=categorical({conds_names{1};conds_names{2};conds_names{3}});

trigger_type_num = numel(conds_names);
trigger_type_max_trials = 10;
sampfreq = 250;
sec_before = 3.5;
sec_after = 6;

hr_after_trigger_perSub = NaN([numel(subs_ecg),trigger_type_num,trigger_type_max_trials]);
hr_before_trigger_perSub = NaN([numel(subs_ecg),trigger_type_num,trigger_type_max_trials]);
hrv_before_trigger_perSub = NaN([numel(subs_ecg),trigger_type_num,trigger_type_max_trials]);
hrv_after_trigger_perSub = NaN([numel(subs_ecg),trigger_type_num,trigger_type_max_trials]);

emg1_before_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);
emg1_after_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);
emg2_before_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);
emg2_after_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);

emg1_after2sec_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,5]);
emg2_after2sec_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,5]);

emg1v_before_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);
emg2v_before_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials]);
emg1v_after2sec_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,5]);
emg2v_after2sec_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,5]);

emg1_erp_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,sampfreq*(sec_after+sec_before)]);
emg2_erp_trigger_perSub = NaN([numel(subs_emg),trigger_type_num,trigger_type_max_trials,sampfreq*(sec_after+sec_before)]);

%% find triggers

for sub_i=1:numel(subs_for_triggers)
    sniff_sub_data = load(strcat(onlyTriggerAndEMG_dir,'\BBS',subs_for_triggers{sub_i},' SNIFF_orig_onlyTriggerAndEMG.mat'));
    data = sniff_sub_data.subData;
    
    trigger = data(4,1:end);
    time = 1:size(trigger,2);
    time = time/sampfreq;

    % find onset of trigger
    trigger_z_score = (trigger - mean(trigger)) / std(trigger);
    [~ ,triggerOnset_locs,triggerOnset_widths,~] = findpeaks(trigger_z_score,time,'MinPeakDistance',5,'MinPeakHeight',0.1,'WidthReference','halfheight');
%      findpeaks(trigger_z_score,time,'MinPeakDistance',5,'MinPeakHeight',0.1,'WidthReference','halfheight');
    
    % find duration of trigger
%     env= envelope(abs(trigger/10000),5,'peak');
%     [~ ,~,widths,proms] = findpeaks(env,time,'MinPeakDistance',5,'MinPeakHeight',10,'WidthReference','halfprom');
%     % findpeaks(env,time,'MinPeakDistance',5,'MinPeakHeight',10,'Annotate','extents');
%     % hold on;
%     % plot(time,trigger/10000);
% 
%     if numel(widths) == 0 || numel(beats_peak) == 0
%         strcat('sub', subs(sub_i), 'has no peaks')
%     end

    [idx,event_times] = get_sub_event_order(subs_for_triggers{sub_i},raw_triggers_dir);
    if numel(event_times)~= 30 || numel(triggerOnset_locs)-numel(event_times)>3
        fprintf("sub %s have %d events, and %d data triggers\n",subs_for_triggers{sub_i},numel(event_times),numel(triggerOnset_locs))
    end

    [minSum, offset, other_offsets_mean_sum] = get_min_diff_offset(event_times, triggerOnset_locs);
    if minSum>5
        fprintf("sub %s have minsum %f\n",subs_for_triggers{sub_i},minSum)
    end
    
    triggerOnset_locs = triggerOnset_locs(1+offset:offset + numel(event_times));
    triggerOnset_widths = triggerOnset_widths(1+offset:offset + numel(event_times));
%     disp(['minsum:' num2str(minSum)])
%     disp(['other_offsets_mean_sum:' num2str(other_offsets_mean_sum)])
%     disp(['sub:' subs{sub_i}])

    %Save trigger events
    file_name = sprintf('%s\\sub-%s_triggerEvents.txt', triggers_events_dir,subs_for_triggers{sub_i});
    fileID = fopen(file_name, 'w');
    if fileID == -1
        error('Could not open the file for writing.');
    end
    fprintf(fileID, 'type\tlatency\n');

    idx_names = cell(size(idx));
    for i = 1:numel(idx)
        idx_names{i} = conds_names{idx(i)};
    end
    for i = 1:length(triggerOnset_locs)
        fprintf(fileID, '%s\t%.2f\n', idx_names{i}, triggerOnset_locs(i));
    end
    fclose(fileID);

    idx_filename = sprintf("%s\\sub-%s_idx.mat",triggers_events_dir,subs_for_triggers{sub_i});
    triggerOnset_widths_filename = sprintf("%s\\sub-%s_triggerOnset_widths.mat",triggers_events_dir,subs_for_triggers{sub_i});
    triggerOnset_locs_filename = sprintf("%s\\sub-%s_triggerOnset_locs.mat",triggers_events_dir,subs_for_triggers{sub_i});
    save(triggerOnset_locs_filename, 'triggerOnset_locs');
    save(triggerOnset_widths_filename, 'triggerOnset_widths');
    save(idx_filename, 'idx');

    %fprintf("sub: %s, events: %d\n",subs{sub_i},numel(triggerOnset_locs))
end

%% Compute stats ECG
for sub_i=1:numel(subs_ecg)
    sniff_sub_data = load(strcat(onlyTriggerAndEMG_dir,'\BBS',subs_ecg{sub_i},' SNIFF_orig_onlyTriggerAndEMG.mat'));
    data = sniff_sub_data.subData;
    ecg = data(3,1:end);
    time = 1:size(data(4,1:end),2);
    time = time/sampfreq;

    triggerOnset_locs_filename = sprintf("%s\\sub-%s_triggerOnset_locs.mat",triggers_events_dir,subs_ecg{sub_i});
    triggerOnset_widths_filename = sprintf("%s\\sub-%s_triggerOnset_widths.mat",triggers_events_dir,subs_ecg{sub_i});
    idx_filename = sprintf("%s\\sub-%s_idx.mat",triggers_events_dir,subs_ecg{sub_i});
    load(triggerOnset_locs_filename);
    load(triggerOnset_widths_filename);
    load(idx_filename);
    
    % filter ECG
    cutoff_frequency = 30;
    normalized_cutoff_frequency = cutoff_frequency / sampfreq / 2;
    filter_order = 100;  % Adjust the filter order as needed
    b = fir1(filter_order, normalized_cutoff_frequency, 'high');
    filtered_ecg = filter(b, 1, ecg);
    filtered_ecg_abs_z_score = abs((filtered_ecg - mean(filtered_ecg)) / std(filtered_ecg));
    [beats_peak ,beats_locs] = findpeaks(filtered_ecg_abs_z_score,time,'MinPeakDistance',0.4,'MinPeakHeight',3);

    for trig_type=1:trigger_type_num
        curr_type_locs = triggerOnset_locs(idx==trig_type);
        curr_type_widths = triggerOnset_widths(idx==trig_type);
        for trial_i=1:numel(curr_type_locs)
            curr_trial_time = curr_type_locs(trial_i) - (curr_type_widths(trial_i)/2);

            beats_locs_Xs_before = beats_locs(beats_locs>=curr_trial_time-sec_before & beats_locs<curr_trial_time);
            beats_locs_Xs_after = beats_locs(beats_locs>=curr_trial_time & beats_locs<curr_trial_time+sec_after);
            hr_before_trigger_perSub(sub_i,trig_type,trial_i) = 60 * mean(diff(beats_locs_Xs_before));
            hr_after_trigger_perSub(sub_i,trig_type,trial_i) = 60 * mean(diff(beats_locs_Xs_after))+ eps; % just to repress zeros

            hrv_before = std(diff(beats_locs_Xs_before));
            hrv_after = std(diff(beats_locs_Xs_after));
            hrv_before_trigger_perSub(sub_i,trig_type,trial_i) = hrv_before;
            hrv_after_trigger_perSub(sub_i,trig_type,trial_i) = hrv_after;
        end
    end
end


%% Compute state EMG

for sub_i=1:numel(subs_emg)
    sniff_sub_data = load(strcat(onlyTriggerAndEMG_dir,'\BBS',subs_emg{sub_i},' SNIFF_orig_onlyTriggerAndEMG.mat'));
    data = sniff_sub_data.subData;
    time = 1:size(data(4,1:end),2);
    time = time/sampfreq;
    emg1 = data(1,1:end);
    emg2 = data(2,1:end);

    triggerOnset_locs_filename = sprintf("%s\\sub-%s_triggerOnset_locs.mat",triggers_events_dir,subs_emg{sub_i});
    triggerOnset_widths_filename = sprintf("%s\\sub-%s_triggerOnset_widths.mat",triggers_events_dir,subs_emg{sub_i});
    idx_filename = sprintf("%s\\sub-%s_idx.mat",triggers_events_dir,subs_emg{sub_i});
    load(idx_filename);
    load(triggerOnset_locs_filename);
    load(triggerOnset_widths_filename);
    
    % filter EMG
    cutoff_frequency = 10;
    normalized_cutoff_frequency = cutoff_frequency / sampfreq / 2;
    filter_order = 10;  % Adjust the filter order as needed
    b = fir1(filter_order, normalized_cutoff_frequency, 'low');
    filtered_emg1 = filter(b, 1, emg1);
    filtered_emg2 = filter(b, 1, emg2);

    % emg z-score
    emg1_filtered_z_score = (filtered_emg1 - mean(filtered_emg1)) / std(filtered_emg1);
    emg2_filtered_z_score = (filtered_emg2 - mean(filtered_emg2)) / std(filtered_emg2);
    
    for trig_type=1:trigger_type_num
        curr_type_locs = triggerOnset_locs(idx==trig_type);
        curr_type_widths = triggerOnset_widths(idx==trig_type);
        for trial_i=1:numel(curr_type_locs)
            curr_trial_time = curr_type_locs(trial_i) - (curr_type_widths(trial_i)/2);
            curr_trial_ind = round(curr_trial_time*sampfreq);
            
            % EMG mean
            emg1_before_trigger_perSub(sub_i,trig_type,trial_i) = mean(emg1_filtered_z_score(curr_trial_ind-(sampfreq*sec_before) : curr_trial_ind));
            emg1_after_trigger_perSub(sub_i,trig_type,trial_i) = mean(emg1_filtered_z_score(curr_trial_ind: (curr_trial_ind+(sampfreq*sec_after))));
            emg2_before_trigger_perSub(sub_i,trig_type,trial_i) = mean(emg2_filtered_z_score(curr_trial_ind-(sampfreq*sec_before) : curr_trial_ind));
            emg2_after_trigger_perSub(sub_i,trig_type,trial_i) = mean(emg2_filtered_z_score(curr_trial_ind : (curr_trial_ind+(sampfreq*sec_after))));

            emg1_after2sec_trigger_perSub(sub_i,trig_type,trial_i,1) =   mean(emg1_filtered_z_score(curr_trial_ind : curr_trial_ind+(sampfreq*2)));
            emg1_after2sec_trigger_perSub(sub_i,trig_type,trial_i,2) =   mean(emg1_filtered_z_score(curr_trial_ind+(sampfreq*2) : curr_trial_ind+(sampfreq*4)));
            emg1_after2sec_trigger_perSub(sub_i,trig_type,trial_i,3) =   mean(emg1_filtered_z_score(curr_trial_ind+(sampfreq*4) : curr_trial_ind+(sampfreq*6)));
            emg1_after2sec_trigger_perSub(sub_i,trig_type,trial_i,4) =   mean(emg1_filtered_z_score(curr_trial_ind+(sampfreq*6) : curr_trial_ind+(sampfreq*8)));
            emg1_after2sec_trigger_perSub(sub_i,trig_type,trial_i,5) =   mean(emg1_filtered_z_score(curr_trial_ind+(sampfreq*8) : curr_trial_ind+(sampfreq*10)));

            emg2_after2sec_trigger_perSub(sub_i,trig_type,trial_i,1) =   mean(emg2_filtered_z_score(curr_trial_ind : curr_trial_ind+(sampfreq*2)));
            emg2_after2sec_trigger_perSub(sub_i,trig_type,trial_i,2) =   mean(emg2_filtered_z_score(curr_trial_ind+(sampfreq*2) : curr_trial_ind+(sampfreq*4)));
            emg2_after2sec_trigger_perSub(sub_i,trig_type,trial_i,3) =   mean(emg2_filtered_z_score(curr_trial_ind+(sampfreq*4) : curr_trial_ind+(sampfreq*6)));
            emg2_after2sec_trigger_perSub(sub_i,trig_type,trial_i,4) =   mean(emg2_filtered_z_score(curr_trial_ind+(sampfreq*6) : curr_trial_ind+(sampfreq*8)));
            emg2_after2sec_trigger_perSub(sub_i,trig_type,trial_i,5) =   mean(emg2_filtered_z_score(curr_trial_ind+(sampfreq*8) : curr_trial_ind+(sampfreq*10)));
            
            % EMG variability
            emg1v_before_trigger_perSub(sub_i,trig_type,trial_i) = std(emg1_filtered_z_score(curr_trial_ind-(sampfreq*sec_before) : curr_trial_ind));
            emg2v_before_trigger_perSub(sub_i,trig_type,trial_i) = std(emg2_filtered_z_score(curr_trial_ind-(sampfreq*sec_before) : curr_trial_ind));

            emg1v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,1) =   std(emg1_filtered_z_score(curr_trial_ind : curr_trial_ind+(sampfreq*2)));
            emg1v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,2) =   std(emg1_filtered_z_score(curr_trial_ind+(sampfreq*2) : curr_trial_ind+(sampfreq*4)));
            emg1v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,3) =   std(emg1_filtered_z_score(curr_trial_ind+(sampfreq*4) : curr_trial_ind+(sampfreq*6)));
            emg1v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,4) =   std(emg1_filtered_z_score(curr_trial_ind+(sampfreq*6) : curr_trial_ind+(sampfreq*8)));
            emg1v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,5) =   std(emg1_filtered_z_score(curr_trial_ind+(sampfreq*8) : curr_trial_ind+(sampfreq*10)));

            emg2v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,1) =   std(emg2_filtered_z_score(curr_trial_ind : curr_trial_ind+(sampfreq*2)));
            emg2v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,2) =   std(emg2_filtered_z_score(curr_trial_ind+(sampfreq*2) : curr_trial_ind+(sampfreq*4)));
            emg2v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,3) =   std(emg2_filtered_z_score(curr_trial_ind+(sampfreq*4) : curr_trial_ind+(sampfreq*6)));
            emg2v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,4) =   std(emg2_filtered_z_score(curr_trial_ind+(sampfreq*6) : curr_trial_ind+(sampfreq*8)));
            emg2v_after2sec_trigger_perSub(sub_i,trig_type,trial_i,5) =   std(emg2_filtered_z_score(curr_trial_ind+(sampfreq*8) : curr_trial_ind+(sampfreq*10)));

            emg1_erp_trigger_perSub(sub_i,trig_type,trial_i,:) = emg1_filtered_z_score(curr_trial_ind-(sampfreq*sec_before)+1 : curr_trial_ind+(sampfreq*sec_after));
            emg2_erp_trigger_perSub(sub_i,trig_type,trial_i,:) = emg2_filtered_z_score(curr_trial_ind-(sampfreq*sec_before) +1: curr_trial_ind+(sampfreq*sec_after));
        end
    end
end


%%
ndArray = hr_after_trigger_perSub - hr_before_trigger_perSub; % sub, cond, win

% Check for NaN and zero values
nanLocations = isnan(ndArray);  % Logical array where NaN values are true
% zeroLocations = eq(ndArray, 0);  % Logical array where zero values are true

linearIndices = find(nanLocations);
[sub1, sub2, sub3] = ind2sub(size(ndArray), linearIndices);
nanLocations =[sub1, sub2, sub3];

% linearIndices = find(zeroLocations);
% [sub1, sub2, sub3] = ind2sub(size(ndArray), linearIndices);
% zeroLocations =[sub1, sub2, sub3];

if numel(nanLocations)% || numel(zeroLocations)
    fprintf('there are some nans\n')% or zeros')
end

%% PLOT - BEFORE MINUS AFTER
show_line_per_sub = false;
% % % HR difference before and after each condition
%plot_per_cond(hr_after_trigger_perSub - hr_before_trigger_perSub, show_line_per_sub,conds_colors,conds_names,categories)
%  
% % % HRV difference before and after each condition
%plot_per_cond(hrv_after_trigger_perSub - hrv_before_trigger_perSub,show_line_per_sub,conds_colors,conds_names,categories)
% 
% % % EMG1 mean activity z-score difference before and after each condition
%plot_per_cond(emg1_after_trigger_perSub - emg1_before_trigger_perSub,show_line_per_sub,conds_colors,conds_names,categories)
% 
% % % EMG2 mean activity z-score difference before and after each condition
%plot_per_cond(emg2_after_trigger_perSub - emg2_before_trigger_perSub,show_line_per_sub,conds_colors,conds_names,categories)
%% PLOT -BEFORE AND AFTER

% % % HR before and after each condition
% plot_before_and_after_per_cond(hr_before_trigger_perSub, hr_after_trigger_perSub ,conds_colors,conds_names)
% %  
% % % HRV before and after each condition
plot_before_and_after_per_cond(hrv_before_trigger_perSub, hrv_after_trigger_perSub,conds_colors,conds_names)
% % 
% % % EMG1 mean activity z-score before and after each condition
%  plot_before_and_after_per_cond(emg1_before_trigger_perSub, emg1_after_trigger_perSub,conds_colors,conds_names)
% % 
% % % EMG2 mean activity z-score before and after each condition
% plot_before_and_after_per_cond(emg2_before_trigger_perSub, emg2_after_trigger_perSub,conds_colors,conds_names)

%% PLOT - BEFORE AND 5 x 2SEC RANGE
% % EMG1 mean activity z-score before and after each condition
plot_before_and_2sec_after_per_cond(emg1_before_trigger_perSub, emg1_after2sec_trigger_perSub,conds_colors,conds_names,sec_before)
% 
% % EMG2 mean activity z-score before and after each condition
%plot_before_and_2sec_after_per_cond(emg2_before_trigger_perSub, emg2_after2sec_trigger_perSub,conds_colors,conds_names,sec_before)

% % EMG1 std activity z-score before and after each condition
%plot_before_and_2sec_after_per_cond(emg1v_before_trigger_perSub, emg1v_after2sec_trigger_perSub,conds_colors,conds_names,sec_before)
% 
% % EMG2 std activity z-score before and after each condition
% plot_before_and_2sec_after_per_cond(emg2v_before_trigger_perSub, emg2v_after2sec_trigger_perSub,conds_colors,conds_names,sec_before)
%% PLOT - ERP, BEFORE AND AFTER TRIGGER

plot_erp_Xsec(emg1_erp_trigger_perSub,sampfreq,subs_emg,conds_colors,conds_names,categories, sec_before, sec_after)
%plot_erp_Xsec(emg2_erp_trigger_perSub,sampfreq,subs,conds_colors,conds_names,categories, sec_before, sec_after)

%% funcs

% mat [ #subs, #triggertype, #trials ]
function plot_per_cond(mat,show_ind_sub,conds_colors,conds_names,categories)
    range  =[1,2,3];
    % bars
    mean_per_trigger = mean(mat,[1,3]) ;
    b = bar(categories,mean_per_trigger, 'grouped','FaceColor','flat');
    b.CData(1,:) = conds_colors{1};
    b.CData(2,:) = conds_colors{2};
    b.CData(3,:) = conds_colors{3};
    
    hold on;

    mean_per_sub_per_trigger = mean(mat,3);
    
    if show_ind_sub
        % dots per sub
        mean_triger_per_Sub = mean(mat,[3]);
        plot(ones(numel(mean_triger_per_Sub(:,1)))*range(1),mean_triger_per_Sub(:,1),'.','MarkerSize',12,'Color','black','HandleVisibility','off')
        hold on;
        plot(ones(numel(mean_triger_per_Sub(:,2)))*range(2),mean_triger_per_Sub(:,2),'.','MarkerSize',12,'Color','black','HandleVisibility','off')
        hold on;
        plot(ones(numel(mean_triger_per_Sub(:,3)))*range(3),mean_triger_per_Sub(:,3),'.','MarkerSize',12,'Color','black','HandleVisibility','off')
        hold on

        % line per sub
        for sub_i=1:size(mat,1)
            plot(range,mean_per_sub_per_trigger(sub_i,:),'LineWidth',1,'Color',[0.2,0.2,0.2,0.3],'HandleVisibility','off')
            hold on;
        end
    end
    
    % error lines
    stderror = std(mean_per_sub_per_trigger,0,[1])/sqrt(size(mat,1));
    errorbar(range,mean_per_trigger,stderror,'color','black','LineStyle','none','HandleVisibility','off');
    hold on;
    
    h = zeros(3, 1);
    h(1) = plot(NaN,NaN,'color',conds_colors{1});
    h(2) = plot(NaN,NaN,'color',conds_colors{2});
    h(3) = plot(NaN,NaN,'color',conds_colors{3});
    legend(h, conds_names{1},conds_names{2},conds_names{3});

    xlabel('Condition')
    ylabel('')
    
    hold on;
    
end

function plot_before_and_after_per_cond(mat_before, mat_after,conds_colors,conds_names)
    mean_per_trigger_before = mean(mat_before,[1,3]) ;
    mean_per_trigger_after = mean(mat_after,[1,3]) ; 
    both = [mean_per_trigger_before; mean_per_trigger_after];
    categories=categorical(["Before";"After"]);
    b = bar(categories,both,'FaceColor','flat');
    b(1).CData = conds_colors{1};
    b(2).CData = conds_colors{2};
    b(3).CData = conds_colors{3};
    hold on

    mean_per_sub_per_trigger_before = mean(mat_before,3);
    mean_per_sub_per_trigger_after = mean(mat_after,3);
    % error lines
    stderror_before = std(mean_per_sub_per_trigger_before,0,[1])/sqrt(size(mat_before,1));
    stderror_after = std(mean_per_sub_per_trigger_after,0,[1])/sqrt(size(mat_after,1));
    both_std = [stderror_before; stderror_after];

    hold on

    [ngroups, nbars] = size(both);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    % Plot the errorbars
    errorbar(x',both,both_std,'k','linestyle','none');

    legend(conds_names)

    hold off
end

function plot_before_and_2sec_after_per_cond(mat_before, mat_after,conds_colors,conds_names,sec_before)
    mean_per_trigger_before = mean(mat_before,[1,3]);
    mean_per_trigger_after = squeeze(mean(mat_after,[1,3])) ;
    both = [mean_per_trigger_before; mean_per_trigger_after'];
    categories=categorical([sprintf("-%.1f-0",sec_before);"0-2";"2-4";"4-6";"6-8";"8-10"]);
    b = bar(categories,both,'FaceColor','flat');
    b(1).CData = conds_colors{1};
    b(2).CData = conds_colors{2};
    b(3).CData = conds_colors{3};
    hold on

    mean_per_sub_per_trigger_before = mean(mat_before,3);
    mean_per_sub_per_trigger_after = mean(mat_after,3);
    % error lines
    stderror_before = std(mean_per_sub_per_trigger_before,0,[1])/sqrt(size(mat_before,1));
    stderror_after = squeeze(std(mean_per_sub_per_trigger_after,0,[1])/sqrt(size(mat_after,1)));
    both_std = [stderror_before; stderror_after'];

    hold on

    [ngroups, nbars] = size(both);
    % Get the x coordinate of the bars
    x = nan(nbars, ngroups);
    for i = 1:nbars
        x(i,:) = b(i).XEndPoints;
    end
    % Plot the errorbars
    errorbar(x',both,both_std,'k','linestyle','none');

    legend(conds_names,'Location','northwest')

    hold off
end

function plot_erp_Xsec(mat,sampfreq,subs,conds_colors,conds_names,categories, sec_before, sec_after)
    m = squeeze(mean(mat,[3]));
    x = linspace(-sec_before,sec_after,sampfreq*(sec_after+sec_before)); 
    
    one_div_sqrt_samp_size = 1/sqrt(size(subs,2));
    cond1 = squeeze(m(:,1,:));
    cond2 = squeeze(m(:,2,:));
    cond3 = squeeze(m(:,3,:));
    shadedErrorBar2(x,cond1,{@mean, @(cond1) one_div_sqrt_samp_size*std(cond1)},'lineprops',{'Color',conds_colors{1},'DisplayName',conds_names{1}},'patchSaturation',0.4);
    hold on;
    shadedErrorBar2(x,cond2,{@mean, @(cond2) one_div_sqrt_samp_size*std(cond2)},'lineprops',{'Color',conds_colors{2},'DisplayName',conds_names{2}},'patchSaturation',0.4);
    hold on;
    shadedErrorBar2(x,cond3,{@mean, @(cond3) one_div_sqrt_samp_size*std(cond3)},'lineprops',{'Color',conds_colors{3},'DisplayName',conds_names{3}},'patchSaturation',0.4);
    legend(categories,'Location','northwest')
    xlabel('Time (s)')
    ylabel('EMG z-score')
end

function [sub_event_order, event_times] = get_sub_event_order(sub,input_dir)
    filePattern = fullfile(input_dir, strcat('*BBS',sub,'.txt'));
    fileList = dir(filePattern);
    if isempty(fileList)
        disp('No matching file found.');
    else
        filename = fullfile(input_dir, fileList(1).name);
        myTable = readtable(filename,"Delimiter",",");
        %disp(myTable);
    end
    
    % Create logical indices for each substring
    substring1 = "0;2;0;0;0;0";  
    substring2 = "0;1;0;0;0;0"; 
    substring3 = "0;3;0;0;0;0"; 
    column_type_name = "Var6"; 
    column_time_name = "Var3"; 
    logical_index1 = contains(myTable.(column_type_name), substring1);
    logical_index2 = contains(myTable.(column_type_name), substring2);
    logical_index3 = contains(myTable.(column_type_name), substring3);
    combined_logical_index = logical_index1 | logical_index2 | logical_index3;
    %event_times
    matching_rows = myTable(combined_logical_index, :);
    %disp(matching_rows);
    
    % Copy the column to an array
    table_type_column_eventrows = matching_rows.(column_type_name);
    event_times = matching_rows.(column_time_name);
    replacements = {
        '0;2;0;0;0;0', 2;
        '0;1;0;0;0;0', 1;
        '0;3;0;0;0;0', 3;
    };
    for i = 1:length(table_type_column_eventrows)
        for j = 1:size(replacements, 1)
            if strcmp(table_type_column_eventrows{i}, replacements{j, 1})
                table_type_column_eventrows{i} = replacements{j, 2};
                break; 
            end
        end
    end
    sub_event_order=cell2mat(table_type_column_eventrows);
end

function [minSum, offset, other_offsets_mean_sum] = get_min_diff_offset(small_array, big_array)
    triggerOnset_locs_diff = diff(big_array);
    event_times_diff = diff(small_array);
    
    minSum = Inf;
    offset = 0;
    other_offsets_mean_sum = 0;
    for i = 1:( 1 + length(triggerOnset_locs_diff) - length(event_times_diff))
        subA = triggerOnset_locs_diff(i:length(event_times_diff)+i-1);
    
        currentSum = sum(abs(subA - event_times_diff'));
        other_offsets_mean_sum=other_offsets_mean_sum+currentSum;
    
        if currentSum < minSum
            offset = i-1;
            minSum = currentSum;
        end
    end
    other_offsets_mean_sum = (other_offsets_mean_sum - minSum) / (length(triggerOnset_locs_diff) - length(event_times_diff));
    
    % Display the optimal offset and minimum sum
    % disp(['Optimal Offset: ', num2str(offset)]);
    % disp(['Minimum Sum: ', num2str(minSum)]);
end