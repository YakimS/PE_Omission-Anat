addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
%%
imported_preproce_name =  'orig';
referenced_preproce_name =  'referenced';
imported_filename_ses_types = {'sleep1','sleep2','sleep3','sleep4','sleep5','wake_morning','wake_night'};
referenced_filename_ses_types = {'wake_morning','wake_night'};
imported_input_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\imported';
imported_output_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\imported\elaborated_events';
referenced_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
referenced_event_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\mix_modeling';
referenced_elaboEventsoutliers_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

%%
blocktypes = {'random','fixed'};
timewin = {"0-100","100-200","200-300","300-400","400-444"};
o_trials_per_subSes = 240;

%% load the two clusters electrodes
clustering_res = load ('C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm\wake_all_referenced\preStim_Vs_postStim\preVsPoststim_bl-100_O.mat');
posClustElect = find(any(clustering_res.posclusterslabelmat == 1, 2));
negClustElect = find(any(clustering_res.negclusterslabelmat == 1, 2));
%% Includes variable 'block_type'
columns = {'sub','ses','timeWin','trialID','block_type','seniority','blockpos','opos','ampAvg_pos','ampAvg_neg'};
mm_mat = cell(numel(subs)*numel(referenced_filename_ses_types)*o_trials_per_subSes*numel(timewin),numel(columns));
mm_mat = cell2struct(mm_mat, columns,2);
% create elaborated event file for referenced event files
output_filename = sprintf('%s//mm_9_sub-ses-lessTimeWin_traits_posnegClust.csv',output_dir);
mm_i = 1;
got_files = false;
for sub_i=1:numel(subs)
    for ses_i=1:numel(referenced_filename_ses_types)
        curr_ses = referenced_filename_ses_types{ses_i};
        curr_sub = subs{sub_i};
        try 
            % get referenced file
            set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_ses,referenced_preproce_name);
            event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents+outliers.mat',referenced_elaboEventsoutliers_dir,curr_sub,curr_ses,referenced_preproce_name);
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
        if strcmp(subs{sub_i},'23') && strcmp(referenced_filename_ses_types{ses_i},'wake_morning')
            continue;
        end
        if ~got_files  continue;  end

        % get o data of sub in ses & put it in a table
        o_events_indexes = find( strcmp({elaborated_events.('TOA')},'O')  == 1 & ...
            [elaborated_events.('is_outlier_trial')] == 0);
        for o_i=1:size(o_events_indexes,2)
            for j=1:numel(timewin)
                curr_timeWin = split(timewin{j},'-');
                timeWinInd_start = find(eeglab_referenced.times == str2double(curr_timeWin{1}));
                timeWinInd_end = find(eeglab_referenced.times == str2double(curr_timeWin{2}));
    
                pos_clust_activity = eeglab_referenced.data(posClustElect,timeWinInd_start:timeWinInd_end,o_events_indexes(o_i));
                mean_posClust = mean(pos_clust_activity,'all');
                neg_clust_activity = eeglab_referenced.data(negClustElect,timeWinInd_start:timeWinInd_end,o_events_indexes(o_i));
                mean_negClust = mean(neg_clust_activity,'all');

                mm_mat(mm_i).('ampAvg_neg') = mean_negClust;
                mm_mat(mm_i).('ampAvg_pos') = mean_posClust;

                mm_mat(mm_i).('opos') = elaborated_events(o_events_indexes(o_i)).tone_pos_in_trial;
                mm_mat(mm_i).('blockpos') = elaborated_events(o_events_indexes(o_i)).block_pos_in_file;
                mm_mat(mm_i).('seniority') = elaborated_events(o_events_indexes(o_i)).omission_type_seniority;
                mm_mat(mm_i).('block_type') = elaborated_events(o_events_indexes(o_i)).block_type;
                mm_mat(mm_i).('trialID') = sprintf('%s_%s_%d',curr_sub,curr_ses,elaborated_events(o_events_indexes(o_i)).event_id);
                mm_mat(mm_i).('timeWin') =timewin{j};
                mm_mat(mm_i).('ses') = curr_ses;
                mm_mat(mm_i).('sub') = curr_sub;
                mm_i = mm_i + 1;
            end
        end
    end
end
 mm_mat_tabel = struct2table(mm_mat);
 writetable(mm_mat_tabel, output_filename);

