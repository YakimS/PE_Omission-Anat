addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
eeglab;

%%
dir_ica_set = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sub15_all_files\ica_moring_night_sleep';
output_dir = '';

saveSelectedFieldsToMat(dir_ica_set,output_dir);

%% FUNCTIONS
function saveSelectedFieldsToMat(input_dir, output_dir)
    % Check if the output directory exists, if not, create it
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end
    
    % List all .set files in the input directory
    files = dir(fullfile(input_dir, '*.set'));
    
    % Process each file
    for i = 1:length(files)
        % Load the EEG data structure for the current .set file
        EEG_ICA = pop_loadset('filepath', input_dir, 'filename', char(files(i).name));
        
        % Create a structure with selected fields
        selectedFields = struct(...
            'chaninfo_icachansind', EEG_ICA.chaninfo.icachansind, ...
            'etc_icasphere_beforerms', EEG_ICA.etc.icasphere_beforerms, ...
            'etc_icaweights_beforerms', EEG_ICA.etc.icaweights_beforerms, ...
            'icaact', EEG_ICA.icaact, ...
            'icachansind', EEG_ICA.icachansind, ...
            'icasphere', EEG_ICA.icasphere, ...
            'icaweights', EEG_ICA.icaweights, ...
            'icawinv', EEG_ICA.icawinv, ...
            'reject_gcompreject', EEG_ICA.reject.gcompreject, ...
            'reject_rejchan', EEG_ICA.reject.rejchan ...
        );
        
        % Define the output MAT file name (same base name as the .set file)
        [~, setName, ~] = fileparts(files(i).name);
        matFileName = fullfile(output_dir, [setName '.mat']);
        
        % Save the structure to a .mat file
        save(matFileName, '-struct', 'selectedFields');
    end
end


