%% per sub, create trials table per cond,sov
subs = {"08","09","10","11","13","14","15","16","17","19","20","21","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38"};
sovs = {'wn','N1','N2','N3','REM','tREM','pREM'};
conds = ["O","OF","OR","intbkMid"];
input_folder_path = 'D:\OExpOut\processed_data\ft_processed';
outputPath = 'D:\OExpOut\event_statistics';


for iSub = 1:length(subs)
    trialsTable = array2table(zeros(length(conds), length(sovs)), 'VariableNames', sovs, 'RowNames', conds);

    files = dir(fullfile(input_folder_path, '*.mat'));
    for iFile = 1:length(files)
        data = load(fullfile(input_folder_path, files(iFile).name));
        [~, filename, ~] = fileparts(files(iFile).name);
        tokens = regexp(filename, 'timelocked_sov-(.+)_cond-(.+)_sub-(.+)', 'tokens');
        if isempty(tokens); continue; end % Skip if filename pattern does not match
        fileSOV = tokens{1}{1};
        fileCOND = tokens{1}{2};
        fileSUBJ = tokens{1}{3};

        if ismember(fileSUBJ, subs{iSub}) && ismember(fileSOV, sovs) && ismember(fileCOND, conds)
            trialsCount = data.timelocked_subcond.cfg.trials_timelocked_avg;
            trialsTable{fileCOND, fileSOV} = trialsCount;
        end
    end
    
    % Save
    saveFileName = sprintf("%s\\TrialsTable_sub-%s.mat", outputPath, subs{iSub});
    save(saveFileName, 'trialsTable');
end


%% per cond, create trials table per sov,sub
subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
sovs = {'wn','N1','N2','N3','REM','tREM','pREM'};
conds = {'AO','AOF','AOR'};
input_folder_path = 'D:\OExpOut\processed_data\ft_processed';
outputPath = 'D:\OExpOut\event_statistics';

subjectsTable = cell(length(conds), length(sovs));
subjectsTable = array2table(subjectsTable, 'VariableNames', sovs, 'RowNames', conds);

for iCond = 1:length(conds)
    trialsTable = array2table(zeros(length(sovs), length(subs)), 'VariableNames', subs, 'RowNames', sovs);
    files = dir(fullfile(input_folder_path, '*.mat'));
    for iFile = 1:length(files)
        % Load the file
        data = load(fullfile(input_folder_path, files(iFile).name));
        [~, filename, ~] = fileparts(files(iFile).name);
        tokens = regexp(filename, 'timelocked_sov-(.+)_cond-(.+)_sub-(.+)', 'tokens');
        if isempty(tokens); continue; end % Skip if filename pattern does not match
        fileSOV = tokens{1}{1};
        fileCOND = tokens{1}{2};
        fileSUBJ = tokens{1}{3};
        
        if strcmp(fileCOND, conds{iCond}) & ismember(fileSOV, sovs) & ismember(fileSUBJ, subs)
            trialsCount = data.timelocked_subcond.cfg.trials_timelocked_avg;
            trialsTable{find(strcmp(sovs, fileSOV)), find(strcmp(subs, fileSUBJ))} = trialsCount;

            if trialsCount < 50
                currentCell = subjectsTable{fileCOND, fileSOV};
                if isempty(currentCell{1})
                    subjectsTable{fileCOND, fileSOV} = {fileSUBJ};
                else
                    subjectsTable{fileCOND, fileSOV} = {[currentCell{1},',', fileSUBJ]};
                end
            end
        end
    end
    
    % Save
    saveFileName = sprintf("%s\\TrialsTable_cond-%s.mat", outputPath, conds{iCond});
    save(saveFileName, 'trialsTable');
    saveFileName = fullfile(outputPath, 'SubjectsTable_LessThan50Trials.mat');
    save(saveFileName, 'subjectsTable');
end



%% 
input_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\preProcessed';
events_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\imported\elaborated_events';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

numSubjects = numel(subs);
avgTimeBeforeBGINAll = zeros(5, numSubjects);
avgTimeAfterBGINAll = zeros(5, numSubjects);
avgTimeTrialAll = zeros(5, numSubjects);
avgTimeAfterLastPairAll = zeros(5, numSubjects);

for sub_i = 1:numel(subs)
    file_pattern = fullfile(input_set_dir, sprintf('*%s*.set',subs{sub_i}));
    files_set = dir(file_pattern);

    timeBeforeBGIN = [];
    timeAfterBGIN = [];
    timeTrial = [];
    timeAfterLastPair = [];
    for files_i = 1:length(files_set)
        if strcmp(subs{sub_i},'37') && contains(files_set(files_i).name,'night')
            continue;
        end

        if ~isempty(strfind(files_set(files_i).name, 'wake_morning'))
            file_sleepwake_name = 'morning';
        elseif ~isempty(strfind(files_set(files_i).name, 'wake_night'))
            file_sleepwake_name = 'night';
        else
            file_sleepwake_name = 'sleep';
        end

        if contains(files_set(files_i).name,'sleep')
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*%d*',subs{sub_i},file_sleepwake_name,files_i));
        else
            file_pattern = fullfile(events_dir, sprintf('*%s*%s*',subs{sub_i},file_sleepwake_name));
        end
        files_events = dir(file_pattern);
        if length(files_events) > 1
            error('More than one file found. Please check the file pattern or directory.');
        end
        sub_events_filepath = sprintf("%s\\%s",events_dir,files_events(1).name); % todo: make sure the right file is loadied by entering fileUM TO REGEX
        sub_events = load(sub_events_filepath);
        sub_events = sub_events.events;

         for i = 2:length(sub_events)-1 % Start from 2 to avoid indexing error
            if strcmp(sub_events(i).type, 'BGIN') && ~strcmp(sub_events(i-1).type, 'STRT')
                diff = sub_events(i).init_time - sub_events(i-1).init_time;                % Calculate time difference with previous event
                timeBeforeBGIN = [timeBeforeBGIN, diff];
                diff = sub_events(i+1).init_time - sub_events(i).init_time;                % Calculate time difference with next event
                timeAfterBGIN = [timeAfterBGIN, diff];
            end

            if strcmp(sub_events(i).TOA, 'A') && sub_events(i).tone_pos_in_trial == 1
                for j = i+1:min(i+23,length(sub_events))
                    if (strcmp(sub_events(j).TOA, 'T') || strcmp(sub_events(j).TOA, 'O'))  ...
                        && sub_events(j).trial_pos_in_block == sub_events(i).trial_pos_in_block ...
                        && sub_events(j).tone_pos_in_trial == 10
                        diff = sub_events(j).init_time - sub_events(i).init_time;% Calculate time difference and break the loop
                        timeTrial = [timeTrial, diff];
                        break;
                    end
                end
            end

            if (strcmp(sub_events(i).TOA, 'T') || strcmp(sub_events(i).TOA, 'O'))  ...
                        && sub_events(i).tone_pos_in_trial == 10
                for j = i+1:min(i+5,length(sub_events))
                    if strcmp(sub_events(j).TOA, 'A') ...
                        && sub_events(j).tone_pos_in_trial == 1 ...
                        && sub_events(i).trial_pos_in_block +1 == sub_events(j).trial_pos_in_block ...
                        diff = sub_events(j).init_time - sub_events(i).init_time;
                        timeAfterLastPair= [timeAfterLastPair, diff];
                        break;
                    end
                end
            end
        end
    end
    
    avgTimeAfterLastPairAll(:,sub_i) =get_box_stats_from_arr(timeAfterLastPair);
    avgTimeTrialAll(:,sub_i) =get_box_stats_from_arr(timeTrial);
    avgTimeBeforeBGINAll(:,sub_i) =get_box_stats_from_arr(timeBeforeBGIN);
    avgTimeAfterBGINAll(:,sub_i) =get_box_stats_from_arr(timeAfterBGIN);
end

colors = lines(numel(subs));
create_box_plot(avgTimeTrialAll,'Average Trial length for Each Subject');
create_box_plot(avgTimeBeforeBGINAll,'Average Time Before BGIN for Each Subject');
create_box_plot(avgTimeAfterBGINAll,'Average Time After BGIN for Each Subject');
create_box_plot(avgTimeAfterLastPairAll,'Average Time from end of last pair to the next first');

%%
function box_stats=get_box_stats_from_arr(arr)
    box_stats = [min(arr),prctile(arr, 25),median(arr),prctile(arr, 75),max(arr)];
end

function create_box_plot(data,title___)
    figure;
    boxplot(data);
    title(title___);
    xlabel('Subject Index');
    ylabel('Average Time (seconds)');
    hold off;
end