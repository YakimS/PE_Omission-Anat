restoredefaultpath
addpath C:\Users\User\Cloud-Drive\BigFiles\libs\fieldtrip-20230223
ft_defaults
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;
%%
sub_15_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sub15_all_files';
sub_15_detected_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sub15_all_files\New folder';

EEG_orig=get_EEG_by_dir_and_suffix(sub_15_dir, 'orig.set');
EEG_ica_int=get_EEG_by_dir_and_suffix(sub_15_dir, 'int.set');
EEG_ica=get_EEG_by_dir_and_suffix(sub_15_dir, 'ICA.set');
EEG_prepro=get_EEG_by_dir_and_suffix(sub_15_dir, 'preProcessed.set');
EEG_rotr=get_EEG_by_dir_and_suffix(sub_15_dir, '_rotr.set');
EEG_removed=get_EEG_by_dir_and_suffix(sub_15_dir, '_removed.set');
EEG_epochs=get_EEG_by_dir_and_suffix(sub_15_dir, '_epochs.set');
EEG_detected=get_EEG_by_dir_and_suffix(sub_15_detected_dir, '_epochs.set');
EEG_reref=get_EEG_by_dir_and_suffix(sub_15_dir, '_referenced.set');
EEG_my_ICA=get_EEG_by_dir_and_suffix(sub_15_dir, 'preProcessed_ICA_SHAYKM.set');
EEG_my_markedRej=get_EEG_by_dir_and_suffix(sub_15_dir, 'preProcessed_ICA_markedRej_SHAYKM.set');
EEG_my_donerej=get_EEG_by_dir_and_suffix(sub_15_dir, 'preProcessed_ICA_doneRej_SHAYKM.set');

%%
diff = display_compareStructs(EEG_prepro, EEG_epochs);

% Field Root.epoch is empty in one of the structures
% Field Root.event.codes is empty in one of the structures
% Difference at Root.event.duration
% Field missing at Root.event.epoch
% Difference at Root.event.init_index
% Difference at Root.event.init_time
% Difference at Root.event.latency
% Difference at Root.event.type
% Difference at Root.event.urevent
% Field Root.event.value is empty in one of the structures
% Difference at Root.eventdescription
% Difference at Root.pnts
% Difference at Root.setname
% Difference at Root.times
% Difference at Root.trials
% Difference at Root.xmax
% Difference at Root.xmin

% Difference at Root.filename
% Difference at Root.comments
% Difference at Root.data
% Difference at Root.datfile


%%
diff = display_compareStructs(EEG_ica_int, EEG_reref);

% Difference at Root.chaninfo.icachansind
% Difference at Root.data
% Difference at Root.etc.icaweights_beforerms
% Difference at Root.icaact
% Difference at Root.icachansind
% Difference at Root.icaweights
% Difference at Root.icawinv
% Field missing at Root.reject.rejchan

% Difference at Root.datfile
% Difference at Root.filename

%%
diff = display_compareStructs(EEG_removed, EEG_ica_int);

% Difference at Root.chaninfo.icachansind
% Field missing at Root.chaninfo.ndchanlocs.ref
% Field missing at Root.chaninfo.ndchanlocs.urchan
% Field Root.chaninfo.nodatchans is empty in one of the structures
% Field Root.chanlocs.ref is empty in one of the structures
% Difference at Root.epoch.eventduration
% Difference at Root.etc.icasphere_beforerms
% Difference at Root.etc.icaweights_beforerms
% Difference at Root.event.latency
% Difference at Root.icaact
% Difference at Root.icachansind
% Difference at Root.icasphere
% Difference at Root.icaweights
% Difference at Root.icawinv
% Difference at Root.nbchan
% Difference at Root.pnts
% Difference at Root.srate
% Difference at Root.times
% Difference at Root.urevent.latency
% Difference at Root.xmax

% Difference at Root.data
% Difference at Root.datfile
% Difference at Root.filename
% Difference at Root.setname
% Difference at Root.ref

%%
diff = display_compareStructs(EEG_rotr, EEG_ica);

% Field Root.chaninfo.icachansind is empty in one of the structures
% Field missing at Root.etc.icasphere_beforerms
% Field missing at Root.etc.icaweights_beforerms
% Field Root.icaact is empty in one of the structures
% Field Root.icachansind is empty in one of the structures
% Field Root.icasphere is empty in one of the structures
% Field Root.icaweights is empty in one of the structures
% Field Root.icawinv is empty in one of the structures
% Field Root.reject.gcompreject is empty in one of the structures

% Difference at Root.datfile
% Difference at Root.filename
% Difference at Root.history
%%
diff = display_compareStructs(EEG_removed, EEG_ica);
% Difference at Root.data
% Difference at Root.etc.icaweights_beforerms
% Difference at Root.icaact
% Difference at Root.icaweights
% Difference at Root.icawinv
% Difference at Root.reject.gcompreject
% Field missing at Root.reject.rejchan

% Difference at Root.datfile
% Difference at Root.setname
% Difference at Root.filename
% Difference at Root.history
%%
diff = display_compareStructs(EEG_rotr, EEG_removed);

% Field Root.chaninfo.icachansind is empty in one of the structures
% Field missing at Root.etc.icasphere_beforerms
% Field missing at Root.etc.icaweights_beforerms
% Field Root.icaact is empty in one of the structures
% Field Root.icachansind is empty in one of the structures
% Field Root.icasphere is empty in one of the structures
% Field Root.icaweights is empty in one of the structures
% Field Root.icawinv is empty in one of the structures
% Field Root.reject.gcompreject is empty in one of the structures
% Field missing at Root.reject.rejchan

% Difference at Root.filename
% Difference at Root.history
% Difference at Root.setname
% Difference at Root.data
% Difference at Root.datfile
%%
diff = display_compareStructs(EEG_rotr, EEG_detected);

% Difference at Root.data
% Field missing at Root.reject.rejchan
% Field missing at Root.rejepoch
% Difference at Root.trials

% Difference at Root.datfile
% Difference at Root.filename
%%
diff = display_compareStructs(EEG_prepro, EEG_orig);
% Difference at Root.filepath
% Field missing at Root.reject.rejchan
        % delected has a field with array with 

%%
diff_epoched_and_detected = display_compareStructs(EEG_detected, EEG_epochs);
% Difference at Root.filepath
% Field missing at Root.reject.rejchan
        % delected has a field with array with 
%%
diff_prepro_and_after_ica = display_compareStructs(EEG_prepro, EEG_my_ICA);
%     Field Root.chaninfo.icachansind is empty in one of the structures
            % The prepro is [] and the ICA is 1x92 double = 1:92
% Field Root.datfile is empty in one of the structures

% Field missing at Root.etc.icasphere_beforerms
% Field missing at Root.etc.icaweights_beforerms
            % these two fields in prePro is completely absent. In ICA are
            % 92x92 double arrays
% Difference at Root.filename
% Difference at Root.history
            % "EEG = pop_runica(EEG, 'icatype', 'runica',
            % 'extended',1,'interrupt','on')" added to the ICA file
% Field Root.icaact is empty in one of the structures
% Field Root.icachansind is empty in one of the structures
% Field Root.icasphere is empty in one of the structures
% Field Root.icaweights is empty in one of the structures
% Field Root.icawinv is empty in one of the structures
        % yes, in prepro they are [].
% Field Root.reject.gcompreject is empty in one of the structures
        % [] in prepro, 1x92 zeros in ICA


%%
diff_ica_and_after_marked = display_compareStructs(EEG_my_ICA, EEG_my_markedRej);
% Difference at Root.filename
% Difference at Root.history
    % not an interesting difference. Showing the actions of ploting and saving
% % %     % EEG.etc.eeglabvers = '2023.0'; 
% % %     % this tracks which version of EEGLAB is being used, you may ignore it
% % %     % EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
% % %     % EEG = pop_saveset( EEG, 'savemode','resave');
% % %     % EEG = pop_saveset( EEG, 'filename','s_15_wake_morning_preProcessed_ICA_SHAYKM.set','filepath','C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\sub15_all_files\\');
% % %     % pop_eegplot( EEG, 0, 1, 1);
% % %     % pop_selectcomps(EEG, [1:92] );
% Difference at Root.reject.gcompreject
        %  1x92 zeros in ICA, 1x92 with zeros everywhere except in the place of the component to reject 
%%
% However, if we want to remove components, we use the Tools → Remove components menu item, which calls the pop_subcomp.m function.
diff_marked_and_after_doneRej = display_compareStructs(EEG_my_markedRej, EEG_my_donerej);

% Difference at Root.comments
% Difference at Root.data
% Difference at Root.etc.icaweights_beforerms
    % there are differneces in the values of the 92x92 array
% Difference at Root.filename
% Difference at Root.history
    % EEG.etc.eeglabvers = '2023.0'; 
    % this tracks which version of EEGLAB is being used, you may ignore it
    % EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
    % EEG = pop_saveset( EEG, 'savemode','resave');
    % EEG = pop_saveset( EEG, 'filename','s_15_wake_morning_preProcessed_ICA_SHAYKM.set','filepath','C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\sub15_all_files\\');
    % pop_eegplot( EEG, 0, 1, 1);
    % pop_selectcomps(EEG, [1:92] );
    % EEG = pop_saveset( EEG, 'filename','s_15_wake_morning_preProcessed_ICA_markedRej_SHAYKM.set','filepath','C:\\Users\\User\\OneDrive - huji.ac.il\\AnatArzData\\Data\\sub15_all_files\\');
    %IMPORTANT! % EEG = pop_subcomp( EEG, [], 0); 
    % EEG.setname='s_15_wake_morning_preProcessed_ICA_doneRej_SHAYKM';
% Difference at Root.icaact
    % before 92xtimepoints, now 86xtimepoints (there was 6 comp to remove)
% Difference at Root.icaweights
    % before 92x92, not 86x92 (there was 6 comp to remove)
% Difference at Root.icawinv
    % before 92x92, not 92x86 (there was 6 comp to remove)
% Difference at Root.reject.gcompreject
    % turned in 1x86 all zeros
% Difference at Root.setname


%% transform prepro data to donerej data using code
newEEG = EEG_prepro;

% preform ICA
newEEG.chaninfo.icachansind = EEG_my_ICA.chaninfo.icachansind;
newEEG.etc.icasphere_beforerms = EEG_my_ICA.etc.icasphere_beforerms;
newEEG.etc.icaweights_beforerms = EEG_my_ICA.etc.icaweights_beforerms;
newEEG.icaact = EEG_my_ICA.icaact;
newEEG.icachansind = EEG_my_ICA.icachansind;
newEEG.icasphere = EEG_my_ICA.icasphere;
newEEG.icaweights = EEG_my_ICA.icaweights;
newEEG.icawinv = EEG_my_ICA.icawinv;
newEEG.reject.gcompreject = EEG_my_ICA.reject.gcompreject;
newEEG = eeg_checkset(newEEG); % critical

% mark rej ICA
newEEG.reject.gcompreject([2,3,4,7,8,18]) = 1;
newEEG = eeg_checkset(newEEG); % critical

% done rej ICA
newEEG = pop_subcomp( newEEG, [], 0); 
newEEG = eeg_checkset(newEEG); % critical

% Difference at Root.etc.icaweights_beforerms
    % same as my_ICA. therefore didnt changed after subcomp.

% Difference at Root.icaweights
    % it looks the same*
% Difference at Root.icawinv
    % it looks the same*
% Difference at Root.setname
% Difference at Root.comments
% Difference at Root.filename
% Difference at Root.history
% Field Root.datfile is empty in one of the structures

listDifferences(newEEG.icaweights, EEG_my_donerej.icaweights)
listDifferences(newEEG.icawinv, EEG_my_donerej.icawinv)

% * In MATLAB, floating-point numbers are typically stored as double-precision numbers, which can lead to small rounding errors. When you perform comparisons between such numbers, these tiny differences can result in unexpected behavior, such as two seemingly identical numbers being considered different.


%% try mimicking the GUI rejection with injection of parameters and then code rejection
newEEG = EEG_prepro;

% preform ICA
newEEG.chaninfo.icachansind = EEG_my_ICA.chaninfo.icachansind;
newEEG.etc.icasphere_beforerms = EEG_my_ICA.etc.icasphere_beforerms;
newEEG.etc.icaweights_beforerms = EEG_my_ICA.etc.icaweights_beforerms;
newEEG.icaact = EEG_my_ICA.icaact;
newEEG.icachansind = EEG_my_ICA.icachansind;
newEEG.icasphere = EEG_my_ICA.icasphere;
newEEG.icaweights = EEG_my_ICA.icaweights;
newEEG.icawinv = EEG_my_ICA.icawinv;
newEEG.reject.gcompreject = EEG_my_ICA.reject.gcompreject;
newEEG = eeg_checkset(newEEG); % critical


% Field Root.chaninfo.icachansind is empty in one of the structures
% Field missing at Root.etc.icasphere_beforerms
% Field missing at Root.etc.icaweights_beforerms
% Field Root.icaact is empty in one of the structures
% Field Root.icachansind is empty in one of the structures
% Field Root.icasphere is empty in one of the structures
% Field Root.icaweights is empty in one of the structures
% Field Root.icawinv is empty in one of the structures
% Field Root.reject.gcompreject is empty in one of the structures

% Difference at Root.datfile
% Difference at Root.filename
% Difference at Root.history


% done rej ICA
newEEG = pop_subcomp( newEEG,[2,3,4,7,8,18], 0); 
newEEG = eeg_checkset(newEEG); % critical

diff_doneRej_and_myDoneRej = display_compareStructs(newEEG, EEG_my_donerej);

listDifferences(newEEG.icaweights, EEG_my_donerej.icaweights)
listDifferences(newEEG.icawinv, EEG_my_donerej.icawinv)

% Difference at Root.etc.icaweights_beforerms           
    %root mean square (RMS)  
    % read more here https://github.com/sccn/eeglab/issues/172,
    % and here: https://sccn.ucsd.edu/wiki/Makoto's_preprocessing_pipeline (run find "icaweights_beforerms")

% Difference at Root.icaweights
% Difference at Root.icawinv
% Difference at Root.setname
% Difference at Root.filename
% Difference at Root.history
% Difference at Root.comments
% Field Root.datfile is empty in one of the structures

%% FUNCTIONS
function differences = compareStructs(struct1, struct2, path)
    if nargin < 3
        path = 'Root'; % Initialize path for tracking
    end

    % Initialize a cell array to hold the differences
    differences = {};

    % Get field names from both structures
    fields1 = fieldnames(struct1);
    fields2 = fieldnames(struct2);

    % Combine the field names and make them unique
    allFields = unique([fields1; fields2]);

    % Iterate over each field and compare
    for i = 1:length(allFields)
        field = allFields{i};
        currentPath = [path, '.', field]; % Construct the path for the current field

        % Check existence of the field in both structures
        fieldExistsInStruct1 = isfield(struct1, field);
        fieldExistsInStruct2 = isfield(struct2, field);

        if fieldExistsInStruct1 && fieldExistsInStruct2
            % Compare values
            value1 = struct1.(field);
            value2 = struct2.(field);

            % Check for empty structs (1x0 struct)
            if isempty(value1) && isempty(value2)
                % Both are empty structs, considered equal, do nothing
            elseif isempty(value1) || isempty(value2)
                % One is empty and the other is not
                differences{end+1} = sprintf('Field %s is empty in one of the structures', currentPath);
            elseif isstruct(value1) && isstruct(value2)
                % If both are non-empty structures, compare recursively
                subDiffs = compareStructs(value1, value2, currentPath);
                differences = [differences, subDiffs]; % Append differences
            elseif ~isequal(value1, value2)
                % If values are different and not structures
                differences{end+1} = sprintf('Difference at %s', currentPath);
            end
        elseif fieldExistsInStruct1 || fieldExistsInStruct2
            % If the field is missing in one of the structures
            differences{end+1} = sprintf('Field missing at %s', currentPath);
        end
    end
end

function listDifferences(array1, array2, tolerance)
    if nargin < 3
        tolerance = 1e-6; % Default tolerance level
    end

    % Check if the sizes of the arrays are different
    if ~isequal(size(array1), size(array2))
        disp('Arrays have different sizes.');
        return;
    end

    % Flag to track if any difference is found
    differenceFound = false;

    % Iterate through each element
    for i = 1:size(array1, 1)
        for j = 1:size(array1, 2)
            if abs(array1(i,j) - array2(i,j)) > tolerance
                fprintf('Difference at (%d, %d): Array1 has %f, Array2 has %f\n', ...
                        i, j, array1(i,j), array2(i,j));
                differenceFound = true;
            end
        end
    end

    % Check if no difference was found
    if ~differenceFound
        disp('No difference');
    end
end

function diff=display_compareStructs(struct1, struct2)
    diff = compareStructs(struct1, struct2);
    for diff_i=1:numel(diff)
        display(diff{diff_i})
    end
end

function EEG=get_EEG_by_dir_and_suffix(directo, suffix_)
    file_pattern = fullfile(directo, sprintf('*%s',suffix_));
    files = dir(file_pattern);
    EEG = pop_loadset('filepath',directo,'filename',char(files(1).name));
end
