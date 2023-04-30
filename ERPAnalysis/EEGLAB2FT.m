
restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath C:\Users\User\Cloud-Drive\AnatArzi\eeglab2023.0

%     ft_data = eeglab2fieldtrip(eeglabsub_eeg,'comp','none'); % I editted "eeglab2fieldtrip". search "ShaYKM"

%% create .set per TOA condition

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {'O','T','A'};

sleep_files_name_suffix = strcat('sleep_',preproc_stage);
wake_night_files_name_suffix = strcat('wake_night_',preproc_stage);
wake_morning_files_name_suffix = strcat('wake_morning_',preproc_stage);
suf_i = wake_morning_files_name_suffix;

for condition_ind = 1:size(conditions_string,2)
    for sub_ind=1:size(subs,2)
        set_file_output_name =   strcat('s_',subs(sub_ind),'_', suf_i,'_',conditions_string{condition_ind},'.set');
        set_file_name =   strcat('s_',subs(sub_ind),'_',suf_i,'.set');
        if isOutputFile(set_file_output_name, set_per_cond_dir)  continue; end
           
        eeglabsub_eeg =  pop_loadset(set_file_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
        events_cond_i = find(contains(events_type_arr,conditions_string{condition_ind},'IgnoreCase',true));
        
        if isempty(events_cond_i) continue;  end

        eeglabsub_eeg = pop_selectevent( eeglabsub_eeg, 'event',events_cond_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg = eeg_checkset( eeglabsub_eeg ); 

        pop_saveset(eeglabsub_eeg,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end



%% create .set OF OR conditions 

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {'OF','OR'};

sleep_files_name_suffix = strcat('sleep_',preproc_stage);
wake_night_files_name_suffix = strcat('wake_night_',preproc_stage);
wake_morning_files_name_suffix = strcat('wake_morning_',preproc_stage);
suf_i = wake_morning_files_name_suffix;

for sub_ind=1:size(subs,2)
    for condition_ind = 1:size(conditions_string,2)
        set_file_output_name =   strcat('s_',subs(sub_ind), '_',suf_i,'_',conditions_string{condition_ind},'.set');
        set_file_input_name =   strcat('s_',subs(sub_ind),'_',suf_i,'.set');
        if isOutputFile(set_file_output_name, set_per_cond_dir) continue; end
    
        eeglabsub_eeg =  pop_loadset(set_file_input_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
    
        if strcmp("OR",conditions_string{condition_ind})
            events_cond_i = find(contains(events_type_arr,'O') & ...
            (contains(events_type_arr,'_8')|contains(events_type_arr,'_7')|contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4'))...
            );
        elseif strcmp("OF",conditions_string{condition_ind}) 
            events_cond_i = find(contains(events_type_arr,'O') & contains(events_type_arr,'_9'));
        else  Exeption('wrong condition string');   
        end

        if isempty(events_cond_i)  continue; end
        
        eeglabsub_eeg_event = pop_selectevent( eeglabsub_eeg, 'event',events_cond_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg_event = eeg_checkset( eeglabsub_eeg_event ); 
        pop_saveset(eeglabsub_eeg_event,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end

%% create .set OR less than.... conditions 

ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {'ORl6','ORl7'};

sleep_files_name_suffix = strcat('sleep_',preproc_stage);
wake_night_files_name_suffix = strcat('wake_night_',preproc_stage);
wake_morning_files_name_suffix = strcat('wake_morning_',preproc_stage);
suf_i = wake_night_files_name_suffix;

for sub_ind=1:size(subs,2)
    for condition_ind = 1:size(conditions_string,2)
        set_file_output_name =   strcat('s_',subs(sub_ind), '_',suf_i,'_',conditions_string{condition_ind},'.set');
        set_file_input_name =   strcat('s_',subs(sub_ind),'_',suf_i,'.set');
        if isOutputFile(set_file_output_name, set_per_cond_dir) continue; end
    
        eeglabsub_eeg =  pop_loadset(set_file_input_name, ref_input_dir);
        events_type_arr = {eeglabsub_eeg.event.type};
    
        if strcmp("ORl6",conditions_string{condition_ind})
            events_cond_i = find(contains(events_type_arr,'O') & (contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4')));
        elseif strcmp("ORl7",conditions_string{condition_ind})
            events_cond_i = find(contains(events_type_arr,'O') & (contains(events_type_arr,'_7')|contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4')));
        else  Exeption('wrong condition string');   
        end

        if isempty(events_cond_i)  continue; end
        
        eeglabsub_eeg_event = pop_selectevent( eeglabsub_eeg, 'event',events_cond_i,'deleteevents','off','deleteepochs','on','invertepochs','off');
        eeglabsub_eeg_event = eeg_checkset( eeglabsub_eeg_event ); 
        pop_saveset(eeglabsub_eeg_event,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
    end
end

%% create .set OEf2 - OEf6 / ORFirst5 / OFFirst5 / ORf4-ORf6 conditions 
ref_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';

subs = {'08','09','10','12','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
preproc_stage = 'referenced';
conditions_string = {"ORFirst5", "ORf6", "ORFirst5","OEf6"};

sleep_files_name_suffix = strcat('sleep_',preproc_stage);
wake_night_files_name_suffix = strcat('wake_night_',preproc_stage);
wake_morning_files_name_suffix = strcat('wake_morning_',preproc_stage);
choosenSuffixs = {wake_morning_files_name_suffix, wake_night_files_name_suffix};

for suf_i = 1:size(choosenSuffixs,2)
    for sub_ind=1:size(subs,2)
        for condition_ind = 1:size(conditions_string,2)
            % get variables 
            set_file_output_name =   strcat('s_',subs(sub_ind),'_' ,choosenSuffixs(suf_i),'_',conditions_string{condition_ind},'.set');
            set_file_input_name =   strcat('s_',subs(sub_ind),'_',choosenSuffixs(suf_i),'.set');
            if isOutputFile(set_file_output_name,set_per_cond_dir) continue; end
        
            eeglabsub_eeg =  pop_loadset(set_file_input_name, ref_input_dir);
            events_type_arr = {eeglabsub_eeg.event.type};
            
            % find specific events
            if strcmp("OEf2",conditions_string{condition_ind})
                events_id_OE = OF_event_senioriry(eeglabsub_eeg,2); 
            elseif strcmp("OEf3",conditions_string{condition_ind}) 
                events_id_OE = OF_event_senioriry(eeglabsub_eeg,3);
            elseif strcmp("OEf4",conditions_string{condition_ind}) 
                events_id_OE = OF_event_senioriry(eeglabsub_eeg,4);
            elseif strcmp("OEf5",conditions_string{condition_ind}) 
                events_id_OE = OF_event_senioriry(eeglabsub_eeg,5);
            elseif strcmp("OEf6",conditions_string{condition_ind}) 
                events_id_OE = OF_event_senioriry(eeglabsub_eeg,6);
            elseif strcmp("OFFirst5",conditions_string{condition_ind}) 
                events_id_OE = OF_event_ReverseSenioriry(eeglabsub_eeg,6);

            elseif strcmp("ORFirst5",conditions_string{condition_ind}) 
                events_id_OE = OR_event_ReverseSenioriry(eeglabsub_eeg,6);
            elseif strcmp("ORf6",conditions_string{condition_ind}) 
                events_id_OE = OR_event_senioriry(eeglabsub_eeg,5);

            else  Exeption('wrong condition string');    
            end
    
            if isempty(events_id_OE)  continue; end
            
            % select events and save
            eeglabsub_eeg_event = pop_selectevent( eeglabsub_eeg, 'event',events_id_OE,'deleteevents','off','deleteepochs','on','invertepochs','off');
            eeglabsub_eeg_event = eeg_checkset( eeglabsub_eeg_event ); 
            pop_saveset(eeglabsub_eeg_event,'filepath',set_per_cond_dir,'filename',set_file_output_name{1},'version','7.3');
        end
    end
end

%% convert .set to .mat with ft struct per condition using ft_preprocessing (the recommended method by ft toturial)

set_per_cond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\TimeAnalysis\referenced_per_cond';
ft_percond_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\data_in_ft_cond_fomat';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
conditions_string = {"OFFirst5", "ORf6", "ORFirst5","OEf6"}; %{'OEf6', 'OFFirst5','OEf2','OEf3','OEf4','OEf5','OF','OR','A','O','T','ORl6','ORl7'};

preproc_stage = 'referenced';
sleep_files_name_suffix = strcat('sleep_',preproc_stage);
wake_night_files_name_suffix = strcat('wake_night_',preproc_stage);
wake_morning_files_name_suffix = strcat('wake_morning_',preproc_stage);
choosenSuffixs = {wake_morning_files_name_suffix, wake_night_files_name_suffix};

for suf_i = 1:size(choosenSuffixs,2)
    for sub_ind=1:size(subs,2)
        for condition_ind = 1:size(conditions_string,2) 
            ft_file_name =   strcat('s_',subs(sub_ind), '_',choosenSuffixs(suf_i),'_',conditions_string{condition_ind},'.mat');
            ft_sub_full_filepath = strcat(ft_percond_dir,'/',choosenSuffixs(suf_i),'/',ft_file_name);
            if isOutputFile(ft_file_name, strcat(ft_percond_dir,'/',choosenSuffixs(suf_i))) continue; end
    
            set_file_name =   strcat('s_',subs(sub_ind),'_',choosenSuffixs(suf_i),'_',conditions_string{condition_ind},'.set');
            set_sub_full_filepath = strcat(set_per_cond_dir,'/',set_file_name);
    
            cfg = []; 
            cfg.dataset = set_sub_full_filepath{1};
            cfg.continuous = 'no';
            ft_data = ft_preprocessing(cfg);
            
            save(ft_sub_full_filepath{1},"ft_data");
        end
    end
end

%% util funcs
function isAlreadyExist = isOutputFile(output_file,output_dir)
    fullpath = strcat(output_dir,'\', output_file);
    fullpath = fullpath{1};
    if isfile(fullpath)
        string(strcat(output_file, ' already exists in path:',  fullpath))
        isAlreadyExist = true;
    else
        isAlreadyExist = false;
    end
end

% e.g. seniority 4 means that there was 3 OF trials before the filtered
% once. i.e. the 4th onwards.
function events_id_OE = OF_event_senioriry(eeglabsub_eeg,senioriry)
    events_type_arr = {eeglabsub_eeg.event.type};
    eventID_OFs = find(contains(events_type_arr,'O') & contains(events_type_arr,'_9'));
    events_inittime_arr = {eeglabsub_eeg.event.init_time};
    
    OFs_times = events_inittime_arr(eventID_OFs);
    is_OF_senior = -1* ones(size(eventID_OFs,2),1);
    
    length_of_mini_trial = 13; %sec
    trials_back = senioriry-1;
    
    for of_i = trials_back+1:size(eventID_OFs,2)    % go through the OF events         = OF_X
        for trials_back_j =1:trials_back            % look at the b trials = OF_Y
            is_senior = true;                      
            curr_OF_time = OFs_times{of_i};
            if OFs_times{of_i-trials_back_j} < curr_OF_time - (length_of_mini_trial*trials_back)
                is_senior = false;                % If: (for each OF_Y) OF_Y.time < OF_X.time - time of b trials. Mark this OF as unexpected. Else, mark as expected.
                break;
            end
        end
        is_OF_senior(of_i) = is_senior;
    end

    is_OF_senior(is_OF_senior~=1) = 0;
    events_id_OE = eventID_OFs(is_OF_senior==1);
end

function events_id_OE = OF_event_ReverseSenioriry(eeglabsub_eeg,senioriry)
    events_id_OE = OF_event_senioriry(eeglabsub_eeg,senioriry);

    events_type_arr = {eeglabsub_eeg.event.type};
    eventID_OFs = find(contains(events_type_arr,'O') & contains(events_type_arr,'_9'));

    events_id_OE = setdiff(eventID_OFs,events_id_OE);
end

function events_id_OR = OR_event_senioriry(eeglabsub_eeg,senioriry)
    events_type_arr = {eeglabsub_eeg.event.type};
    eventID_ORs = find(contains(events_type_arr,'O') & ...
            (contains(events_type_arr,'_8')|contains(events_type_arr,'_7')|contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4'))...
            );
    events_inittime_arr = {eeglabsub_eeg.event.init_time};
    
    ORs_times = events_inittime_arr(eventID_ORs);
    is_OR_senior = -1* ones(size(eventID_ORs,2),1);
    
    length_of_mini_trial = 13; %sec 
    trials_back = senioriry-1;
    
    for of_i = trials_back+1:size(eventID_ORs,2)    % go through the OR events         = OF_X
        for trials_back_j =1:trials_back            % look at the b trials = OR_Y
            is_senior = true;                      
            curr_OR_time = ORs_times{of_i};
            if ORs_times{of_i-trials_back_j} < curr_OR_time - ((length_of_mini_trial * 1.5) *trials_back) % it's *1.5 becuase the differnce between 2 OR can be as long as a trial and a half
                is_senior = false;                % If: (for each OF_Y) OF_Y.time < OF_X.time - time of b trials. Mark this OF as unexpected. Else, mark as expected.
                break;
            end
        end
        is_OR_senior(of_i) = is_senior;
    end

    is_OR_senior(is_OR_senior~=1) = 0;
    events_id_OR = eventID_ORs(is_OR_senior==1);
end

function events_id_OR = OR_event_ReverseSenioriry(eeglabsub_eeg,senioriry)
    events_id_OR = OR_event_senioriry(eeglabsub_eeg,senioriry);

    events_type_arr = {eeglabsub_eeg.event.type};
    eventID_ORs = find(contains(events_type_arr,'O') & ...
        (contains(events_type_arr,'_8')|contains(events_type_arr,'_7')|contains(events_type_arr,'_6')|contains(events_type_arr,'_5')|contains(events_type_arr,'_4'))...
        );
    events_id_OR = setdiff(eventID_ORs,events_id_OR);
end



