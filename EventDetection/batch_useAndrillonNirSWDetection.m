
function batch_useAndrillonNirSWDetection(input_dir,output_dir)
    files_input_dir = dir(input_dir);
    fileNames_input = {files_input_dir.name};
    matFiles_input = fileNames_input(~cellfun(@(s)isempty(regexp(s,'.mat', 'once')),fileNames_input));

    for mat_file_ind=1:size(matFiles_input,2)
        % if file not already exists
        output_filename = strcat(output_dir,'/SW_AN_',matFiles_input{mat_file_ind});
        if isfile(output_filename)
            string(strcat(matFiles_input{mat_file_ind}, ' already exists in path:',  output_dir))
            continue
        end
        
        % load eeg
        loaded_mat=load(strcat(input_dir,"/",matFiles_input{mat_file_ind}));
        [data,SleepScoring_vector, sample_freq,electrode_name]=deal(loaded_mat.datafile_data ,loaded_mat.scoring_upsampled, loaded_mat.sample_freq,loaded_mat.electrode_name);
        
        % crete variables for function
        hdr = struct('Fs',double(sample_freq),'nChans', 1,'label',electrode_name);
        scoring = struct('windowSize',30,'scoring',SleepScoring_vector);

        % run thire code
        [allWaves, slowWaves] = SWsDetectionAlgorithm_fieldtrip(double(data),hdr, SleepScoring_vector);

        % save
        allWaves = allWaves{1};
        slowWaves = slowWaves{1};
        save(output_filename,"allWaves","slowWaves",'-double');
    end
end