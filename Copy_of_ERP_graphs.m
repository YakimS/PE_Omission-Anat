addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs'
eeglab nogui;

%%
referenced_preproce_name =  'referenced';
referenced_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ERP_graphs';
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
centralClust =[5,6,11,80,85];   %E6,E7,E13,E106,E112

%% Cond between states of vigilance
sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
sovs = {'wake_night','N2','N3','REM'};

variable = 'TOA';
value = 'T';

sovs_var_name = 'sleep_stage';
curr_sovs = sovs;

subject_data = struct();

for sub_i=1:numel(subs)
    curr_sub = subs{sub_i};
    currSub_erps_var = struct(); % 
    currSub_erps_var_neg = struct(); %zeros([138,numel(wanted_variable),0]);
    subject_data.(strcat('sub',curr_sub)) = struct();
    for sov_i=1:numel(curr_sovs)
        % get set file
        if func_is_sov_sleep(curr_sovs{sov_i})
            curr_file_ses = 'sleep';
        else
            curr_file_ses = curr_sovs{sov_i};
        end
        if strcmp(curr_sub,'23') && strcmp(curr_sovs{sov_i},'wake_morning') ...
            || strcmp(curr_sub,'37') && strcmp(curr_sovs{sov_i},'wake_night')
            continue;
        end
        if ~(func_is_sov_sleep(curr_sovs{sov_i}) && sov_i>1 && func_is_sov_sleep(curr_sovs{sov_i-1}))
            try 
                set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_file_ses,referenced_preproce_name);
                event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents+outliers.mat',referenced_elaboEvents_dir,curr_sub,curr_file_ses,referenced_preproce_name);
                if isfile(set_filename)
                    eeglab_referenced =  pop_loadset(set_filename);
                    elaborated_events = load(event_mat_filename);
                    elaborated_events = elaborated_events.events;
                end
                got_files = true;
            catch ME
                strcat('could not get' ,set_filename)
                strcat('or' ,event_mat_filename)
                got_files = false;
            end
            if ~got_files  continue;  end
        end

        % get the indexes of the current variable value for this ses and sub
        if  strcmp(curr_sovs{sov_i}, "REM")
            sov_indexs = strcmp({elaborated_events.("sleep_stage")},"Rt") | strcmp({elaborated_events.("sleep_stage")},"Rp");
        else
            sov_indexs = strcmp({elaborated_events.("sleep_stage")},curr_sovs{sov_i});
        end

        if isnumeric(value)
            specific_cond_indexs = [elaborated_events.(variable)] == value;
        else
            specific_cond_indexs = strcmp({elaborated_events.(variable)},value);
        end

        indexes_value = find(specific_cond_indexs & ...
            [elaborated_events.('is_outlier_trial')] == 0 & ...
            sov_indexs);

        if isempty(indexes_value) fprintf("big problem?");  end


        % get the data of these indexes in the cluster electodes
        pos_clust_activity = eeglab_referenced.data(centralClust,:,indexes_value);
        
        mean_cent_clust_activity = squeeze(mean(pos_clust_activity,1, 'omitnan'));

        curr_var_val_name = curr_sovs{sov_i};
        if ~isfield(currSub_erps_var, curr_var_val_name)
            currSub_erps_var.(curr_var_val_name) = zeros([138,0]);                
        end
        subj_erp_in_sov = [currSub_erps_var.(curr_var_val_name).'; mean_cent_clust_activity.'];
        subj_erp_in_sov = subj_erp_in_sov.';

        subject_data.(strcat('sub',curr_sub)).(curr_sovs{sov_i}) = struct();
        subject_data.(strcat('sub',curr_sub)).(curr_sovs{sov_i}).('T_N1range_mean') = mean(subj_erp_in_sov(40:50,:),1); % eeglab_referenced.times(40:50)
        subject_data.(strcat('sub',curr_sub)).(curr_sovs{sov_i}).('T_P2range_mean') = mean(subj_erp_in_sov(59:69,:),1); % eeglab_referenced.times(59:69)
        subject_data.(strcat('sub',curr_sub)).(curr_sovs{sov_i}).('T_ERP') = subj_erp_in_sov;
    end
end

%%
function is_sov_sleep=func_is_sov_sleep(sov)
    if strcmp(sov, 'wake_night') || strcmp(sov, 'wake_morning')
        is_sov_sleep = false;
    else
        is_sov_sleep = true;
    end
end




