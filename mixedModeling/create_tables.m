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
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

%%
A = {'random','fixed'};
B = {'1','2','3','4','5','6+'};
E = {'100-200','300-400'};

[a b e c d] = ndgrid(1:numel(A),1:numel(B),1:numel(E),1:numel(referenced_filename_ses_types),1:numel(subs));
mm_mat = [ subs(d(:)).'  referenced_filename_ses_types(c(:)).' A(a(:)).' B(b(:)).' E(e(:)).'];

mm_mat = cell2struct(mm_mat, {'sub','ses','randFixed','ordInBlock','timeWin'},2);
zeros = cell(1,size(events_imported,2));
zeros(:) = {0};
[mm_mat.('ampAvg')] = zeros{:};

%%
% create elaborated event file for referenced event files
output_filename = sprintf('%s//mm_sub-OrOf-blockOrder-mornNight.mat',output_dir);
if isfile(output_filename) string(strcat(' already exists in path:',  output_filename))
else
    %% get referenced file
    structrow = 0;
    curr_sub = '00';
    curr_ses = '00';
    for mm_ind=1:size(mm_mat,2)
        if ~strcmp( mm_mat(mm_ind).sub, curr_sub) || ~strcmp( mm_mat(mm_ind).ses, curr_ses) 
            try % load sub files
                set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,subs{sub_ind},referenced_filename_ses_types{filename_ses_type_ind},referenced_preproce_name);
                event_mat_filename = sprintf('%s//s_%s_%s_%s_elaboEvents.mat',referenced_output_dir,subs{sub_ind},referenced_filename_ses_types{filename_ses_type_ind},referenced_preproce_name);
                if isfile(set_filename)
                    eeglab_referenced =  pop_loadset(set_filename);
                    elaborated_events = load(event_mat_filename);
                end
            catch ME
                strcat('could not get' ,set_filename)
                strcat('or' ,event_mat_filename)
            end 
        end

        % get the events numbers corresponds to a combination of condition
        % get the events of these event numbers for the set file
        % average the response in a the time windows
        % insert it to the table
    end
    % save csv
end