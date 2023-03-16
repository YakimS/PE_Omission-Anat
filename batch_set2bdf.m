
% input_dir is a directory with all the .set files
% NOTICE: sometimes when opening the bdf file, it gives an error about the
% header. It is somehow fixed if you reopen it or rerun this code.
function batch_set2bdf(input_dir,output_dir)
    addpath('C:\Users\User\Cloud-Drive\AnatArzi\eeglab2022.1\functions');
    eeglab

    files_input_dir = dir(input_dir);
    fileNames_input = {files_input_dir.name};
    setFiles_input = fileNames_input(~cellfun(@(s)isempty(regexp(s,'.set', 'once')),fileNames_input));
    for set_file_ind=1:size(setFiles_input,2)
        bdf_filename = erase( setFiles_input{set_file_ind} , '.set' );
        output_filename = [output_dir '/' bdf_filename '.bdf'];
        if isfile(output_filename)
            string(strcat(setFiles_input{set_file_ind}, ' already exists in path:',  output_dir))
            continue
        end
        curr_set =  pop_loadset(setFiles_input{set_file_ind}, input_dir);
        pop_writeeeg(curr_set, output_filename,'TYPE','BDF');
        string(strcat([bdf_filename '.bdf'], ' writed_succesfully in path:',  output_dir))
    end
end