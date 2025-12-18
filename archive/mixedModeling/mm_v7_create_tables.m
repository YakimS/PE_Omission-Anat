addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab
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
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events';
subs = {'09','10','11','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

%%
blocktypes = {'random','fixed'};
timewin = {"0-48","48-100","100-148","148-200","200-248","248-300","300-348","348-400","400-444","0-100","100-200","200-300","300-400","0-224","224-444"};
seniority = cell(1, 12); % 1,2,3,4,5,6,7,8,9,10,11-20,21-30
for i = 1:12 
    seniority{i} = num2str(i);
end
blockpos = {'1','2'}; % first/second half
tonepos = {'6','7','8','9','10'};
%% load the two clusters electrodes
clustering_res = load ('C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm\wake_all_referenced\preStim_Vs_postStim\preVsPoststim_bl-100_O.mat');
posClustElect = find(any(clustering_res.posclusterslabelmat == 1, 2));
negClustElect = find(any(clustering_res.negclusterslabelmat == 1, 2));
%% Includes variable 'block_type'
[g b a e f c d] = ndgrid(1:numel(tonepos),1:numel(blockpos),1:numel(blocktypes),1:numel(timewin),1:numel(seniority),1:numel(referenced_filename_ses_types),1:numel(subs)); % c and d must stay last
mm_mat = [ subs(d(:)).'  referenced_filename_ses_types(c(:)).' blocktypes(a(:)).' timewin(e(:)).' seniority(f(:)).' blockpos(b(:)).'  tonepos(g(:)).'];
mm_mat = cell2struct(mm_mat, {'sub','ses','block_type','timeWin','seniority','blockpos','tonepos'},2);
% create elaborated event file for referenced event files
output_filename = sprintf('%s//mm_7_sub-OrOf-ses-posnegClust-tonepos-blockpos-senior12-manyTimeWin.csv',output_dir);
curr_sub = '00';
curr_ses = '00';
for mm_i=1:numel(mm_mat)
    % get referenced file
    if ~strcmp( mm_mat(mm_i).sub, curr_sub) || ~strcmp( mm_mat(mm_i).ses, curr_ses) 
        try % load sub files
            curr_ses = mm_mat(mm_i).ses;
            curr_sub = mm_mat(mm_i).sub;
            set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_ses,referenced_preproce_name);
            event_mat_filename = sprintf('%s//s_%s_%s_%s_elaboEvents.mat',referenced_elaboEvents_dir,curr_sub,curr_ses,referenced_preproce_name);
            if isfile(set_filename)
                eeglab_referenced =  pop_loadset(set_filename);
                elaborated_events = load(event_mat_filename);
                elaborated_events = elaborated_events.events;
            end
        catch ME
            strcat('could not get' ,set_filename)
            strcat('or' ,event_mat_filename)
        end
    end


    if strcmp(mm_mat(mm_i).('blockpos'),'1')
        block_pos_in_file_cond = [elaborated_events.('block_pos_in_file')] >= 12;
    else
        block_pos_in_file_cond = [elaborated_events.('block_pos_in_file')] < 12;
    end
    if str2double(mm_mat(mm_i).('seniority')) <= 10
        seniority_cond = [elaborated_events.('omission_type_seniority')] == str2double(mm_mat(mm_i).('seniority'));
    elseif str2double(mm_mat(mm_i).('seniority')) == 11
        seniority_cond = [elaborated_events.('omission_type_seniority')] >= 11 & [elaborated_events.('omission_type_seniority')] <= 20;
    else
        seniority_cond = [elaborated_events.('omission_type_seniority')] >= 21 & [elaborated_events.('omission_type_seniority')] <= 30;
    end
    indexes = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
        &  seniority_cond ...
        &  block_pos_in_file_cond ...
        & [elaborated_events.('tone_pos_in_trial')] == str2double(mm_mat(mm_i).('tonepos')) ...
        & strcmp({elaborated_events.('block_type')},mm_mat(mm_i).('block_type')));

    curr_timeWin = split(mm_mat(mm_i).('timeWin'),'-');
    timeWinInd_start = find(eeglab_referenced.times == str2double(curr_timeWin{1}));
    timeWinInd_end = find(eeglab_referenced.times == str2double(curr_timeWin{2}));

    pos_clust_activity = eeglab_referenced.data(posClustElect,timeWinInd_start:timeWinInd_end,indexes);
    mean_posClust = mean(pos_clust_activity,'all');
    if isnan(mean_posClust)
        mm_mat(mm_i).('ampAvg_pos') = 'NA';
    else
        mm_mat(mm_i).('ampAvg_pos') = mean_posClust;
    end

    neg_clust_activity = eeglab_referenced.data(negClustElect,timeWinInd_start:timeWinInd_end,indexes);
    mean_negClust = mean(neg_clust_activity,'all');
    if isnan(mean_negClust)
        mm_mat(mm_i).('ampAvg_neg') = 'NA';
    else
        mm_mat(mm_i).('ampAvg_neg') = mean_negClust;
    end
end
 mm_mat_tabel = struct2table(mm_mat);
 writetable(mm_mat_tabel, output_filename);

%% Doesn't includes variable 'block_type'. Instead includes differnce between fixed-rand
[g b e f c d] = ndgrid(1:numel(tonepos),1:numel(blockpos),1:numel(timewin),1:numel(seniority),1:numel(referenced_filename_ses_types),1:numel(subs)); % c and d must stay last
mm_mat = [ subs(d(:)).'  referenced_filename_ses_types(c(:)).' timewin(e(:)).' seniority(f(:)).' blockpos(b(:)).'  tonepos(g(:)).'];
mm_mat = cell2struct(mm_mat, {'sub','ses','timeWin','seniority','blockpos','tonepos'},2);
% create elaborated event file for referenced event files
output_filename = sprintf('%s//mm_7_sub-ses-posnegClust-tonepos-blockpos-senior12-manyTimeWin_diffRF.csv',output_dir);
curr_sub = '00';
curr_ses = '00';
for mm_i=1:numel(mm_mat)
    % get referenced file
    if ~strcmp( mm_mat(mm_i).sub, curr_sub) || ~strcmp( mm_mat(mm_i).ses, curr_ses) 
        try % load sub files
            curr_ses = mm_mat(mm_i).ses;
            curr_sub = mm_mat(mm_i).sub;
            set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_ses,referenced_preproce_name);
            event_mat_filename = sprintf('%s//s_%s_%s_%s_elaboEvents.mat',referenced_elaboEvents_dir,curr_sub,curr_ses,referenced_preproce_name);
            if isfile(set_filename)
                eeglab_referenced =  pop_loadset(set_filename);
                elaborated_events = load(event_mat_filename);
                elaborated_events = elaborated_events.events;
            end
        catch ME
            strcat('could not get' ,set_filename)
            strcat('or' ,event_mat_filename)
        end
    end

    if strcmp(mm_mat(mm_i).('blockpos'),'1')
        block_pos_in_file_cond = [elaborated_events.('block_pos_in_file')] >= 12;
    else
        block_pos_in_file_cond = [elaborated_events.('block_pos_in_file')] < 12;
    end
    if str2double(mm_mat(mm_i).('seniority')) <= 10
        seniority_cond = [elaborated_events.('omission_type_seniority')] == str2double(mm_mat(mm_i).('seniority'));
    elseif str2double(mm_mat(mm_i).('seniority')) == 11
        seniority_cond = [elaborated_events.('omission_type_seniority')] >= 11 & [elaborated_events.('omission_type_seniority')] <= 20;
    else
        seniority_cond = [elaborated_events.('omission_type_seniority')] >= 21 & [elaborated_events.('omission_type_seniority')] <= 30;
    end
    indexes_rand = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                    & seniority_cond ...
                    & block_pos_in_file_cond ...
                    & [elaborated_events.('tone_pos_in_trial')] == str2double(mm_mat(mm_i).('tonepos')) ...
                    & strcmp({elaborated_events.('block_type')},'random'));
    indexes_fixed = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                & seniority_cond ...
                & block_pos_in_file_cond ...
                & strcmp({elaborated_events.('block_type')},'random'));


    curr_timeWin = split(mm_mat(mm_i).('timeWin'),'-');
    timeWinInd_start = find(eeglab_referenced.times == str2double(curr_timeWin{1}));
    timeWinInd_end = find(eeglab_referenced.times == str2double(curr_timeWin{2}));


    pos_clust_activity_fixed = eeglab_referenced.data(posClustElect,timeWinInd_start:timeWinInd_end,indexes_fixed);
    pos_clust_activity_rand = eeglab_referenced.data(posClustElect,timeWinInd_start:timeWinInd_end,indexes_rand);
    mean_posClust_fixed = mean(pos_clust_activity_fixed,'all');
    mean_posClust_rand = mean(pos_clust_activity_rand,'all');
    if isnan(mean_posClust_rand - mean_posClust_fixed)
        mm_mat(mm_i).('ampAvg_pos_diffRF') = 'NA';
    else
        mm_mat(mm_i).('ampAvg_pos_diffRF') = mean_posClust_rand - mean_posClust_fixed;
    end

    neg_clust_activity_fixed = eeglab_referenced.data(negClustElect,timeWinInd_start:timeWinInd_end,indexes_fixed);
    neg_clust_activity_rand = eeglab_referenced.data(negClustElect,timeWinInd_start:timeWinInd_end,indexes_rand);
    mean_negClust_fixed = mean(neg_clust_activity_fixed,'all');
    mean_negClust_rand = mean(neg_clust_activity_rand,'all');
    if isnan(mean_negClust_rand - mean_negClust_fixed)
        mm_mat(mm_i).('ampAvg_neg_diffRF') = 'NA';
    else
        mm_mat(mm_i).('ampAvg_neg_diffRF') = mean_negClust_rand - mean_negClust_fixed;
    end
end
 mm_mat_tabel = struct2table(mm_mat);
 writetable(mm_mat_tabel, output_filename);