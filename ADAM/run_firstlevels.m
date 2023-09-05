
input_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\DATA';
%%  regualr + random perm (not leave-one-out)

subs = { '08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'}; 
subs = { '09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'}; 
main_output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resamp55_allSovs_subRandPerm';
sovs = {'N3','REM','wnight','wmorning','N1','N2'};
conds_string = {'OF','OR','T','A','O'};


%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                             wake_morning    wake_night        N1       N2      N3        REM
% 
% factor          OF              1               2             19       20      21         22             
% "trialtype"     OR              3               4             23       24      25         26               
%                 T               5               6             27       28      29         30                           
%                 A               7               8             31       32      33         34                            
%                 O               17              18            51       52      53         54   

data_table = [
    1, 2, 19, 20, 21, 22;
    3, 4, 23, 24, 25, 26;
    5, 6, 27, 28, 29, 30;
    7, 8, 31, 32, 33, 34;
%     9, 10, 35, 36, 37, 38;
%     11, 12, 39, 40, 41, 42;
%     13, 14, 43, 44, 45, 46;
%     15, 16, 47, 48, 49, 50;
    17, 18, 51, 52, 53, 54];

symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);


% GENERAL ANALYSIS CONFIGURATION SETTINGS
cfg = [];                                  
cfg.datadir = input_dir;                  
cfg.model = 'BDM';                         % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';                    % classify raw or time frequency representations ('tfr')
cfg.nfolds = 5;                            % for test 3
cfg.class_method = 'AUC';             	   
cfg.crossclass = 'no';                    % whether to compute temporal generalization
cfg.channelpool = 'ALL_NOSELECTION';       
cfg.resample = '55';                         % downsample, "no" or sampling rate units(<250hz) (useful for temporal generalization). For test 30
cfg.save_confidence = 'yes';
cfg.randompermutations = 30;%200;            % USE ONLY if you want to have within subject decoding significant line

contrasts = struct('name', {}, 'cond1', {}, 'cond2', {});


%%% Define contrasts
% OF vs OR, within sov
for sov_i=1:numel(sovs)
    sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
    trialtype_OR = table2array(symbol_factorArray('OR', :));
    trialtype_OF = table2array(symbol_factorArray('OF', :));
%     contrasts(end+1) = struct(  'name',sprintf( 'subset-%s_OR-vs-OF',sovs{sov_i}), ...
%                             'cond1', cond_string(trialtype_OR,sov_symbols), ...
%                             'cond2', cond_string(trialtype_OF,sov_symbols));

    contrasts(end+1) = struct(  'name',sprintf( 'subset-%s_OF-vs-OR',sovs{sov_i}), ...
                        'cond1', cond_string(trialtype_OF,sov_symbols), ...
                        'cond2', cond_string(trialtype_OR,sov_symbols));
end

% sov vs. sov, within O
% unique_pairs_sovs = nchoosek(sovs, 2);
% for i = 1:size(unique_pairs_sovs, 1)
%     pair = unique_pairs_sovs(i, :);
%     sov_1_str = pair{1};
%     sov_2_str = pair{2};
% 
%     sov_1_symbols = table2array(symbol_factorArray(:, sov_1_str))';
%     sov_2_symbols = table2array(symbol_factorArray(:, sov_2_str))';
%     trialtype_O = table2array(symbol_factorArray('O', :));
% 
%     contrasts(end+1) = struct(  'name', sprintf('subset-O_%s-vs-%s',sov_1_str,sov_2_str), ...
%                                 'cond1',  cond_string(trialtype_O,sov_1_symbols), ...
%                                 'cond2', cond_string(trialtype_O,sov_2_symbols));
% end
%%
% run
delete(gcp('nocreate'))
tic
ticBytes(gcp);
parfor (cont_i=1:numel(contrasts) ,4)
% tic
% for cont_i=1:numel(contrasts)
    for sub_i=1:numel(subs)
        sub_input_filename = sprintf("s_%s_allSovs.mat",subs{sub_i});
        splitted = split(contrasts(cont_i).name, "_");
        subset_name = splitted{1};
        contrast_name = splitted{2};
        output_path = sprintf('%s\\%s\\%s_%s',main_output_dir,subset_name,subset_name,contrast_name);

        % if the datafile existes, continue
        files = dir(sprintf("%s\\ALL_NOSELECTION",output_path));
        filenames = string({files.name});
        if any(contains(filenames, sub_input_filename))
            continue;
        end

        run_adam_MVPA_firstlevel(sub_input_filename, contrasts(cont_i).cond1, contrasts(cont_i).cond2, output_path,cfg);
    end
end
tocBytes(gcp)
toc
%%  regualr (not leave-one-out)
subs = { '08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'}; 
main_output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ADAM\RESULTS_resampNo_allSovs';
sovs = {'wnight','wmorning','N1','N2','N3','REM'};
conds_string = {'OF','OR','T','A','O'};


%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                             wake_morning    wake_night        N1       N2      N3        REM
% 
% factor          OF              1               2             19       20      21         22             
% "trialtype"     OR              3               4             23       24      25         26               
%                 T               5               6             27       28      29         30                           
%                 A               7               8             31       32      33         34                            
%                 O               17              18            51       52      53         54   

data_table = [
    1, 2, 19, 20, 21, 22;
    3, 4, 23, 24, 25, 26;
    5, 6, 27, 28, 29, 30;
    7, 8, 31, 32, 33, 34;
%     9, 10, 35, 36, 37, 38;
%     11, 12, 39, 40, 41, 42;
%     13, 14, 43, 44, 45, 46;
%     15, 16, 47, 48, 49, 50;
    17, 18, 51, 52, 53, 54];

% For testing
% subs = {'08','09','10','11'};
% sovs = {'wmorning','wnight'};
% conds_string = {'OF','OR'};
% 
% data_table = [
%     1, 2;
%     3, 4];
symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);


% GENERAL ANALYSIS CONFIGURATION SETTINGS
cfg = [];                                  
cfg.datadir = input_dir;                  
cfg.model = 'BDM';                         % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';                    % classify raw or time frequency representations ('tfr')
cfg.nfolds = 10;                            % for test 3
cfg.class_method = 'AUC';             	   
cfg.crossclass = 'yes';                    % whether to compute temporal generalization
cfg.channelpool = 'ALL_NOSELECTION';       
cfg.resample = 'no';                         % downsample, "no" or sampling rate units(<250hz) (useful for temporal generalization). For test 30
cfg.save_confidence = 'yes';
contrasts = struct('name', {}, 'cond1', {}, 'cond2', {});

%%% Define contrasts
% OF vs OR, within sov
for sov_i=1:numel(sovs)
    sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
    trialtype_OR = table2array(symbol_factorArray('OR', :));
    trialtype_OF = table2array(symbol_factorArray('OF', :));
    contrasts(end+1) = struct(  'name',sprintf( 'subset-%s_OR-vs-OF',sovs{sov_i}), ...
                            'cond1', cond_string(trialtype_OR,sov_symbols), ...
                            'cond2', cond_string(trialtype_OF,sov_symbols));

   contrasts(end+1) = struct(  'name',sprintf( 'subset-%s_OF-vs-OR',sovs{sov_i}), ...
                        'cond1', cond_string(trialtype_OF,sov_symbols), ...
                        'cond2', cond_string(trialtype_OR,sov_symbols));
end

% sov vs. sov, within O
% unique_pairs_sovs = nchoosek(sovs, 2);
% for i = 1:size(unique_pairs_sovs, 1)
%     pair = unique_pairs_sovs(i, :);
%     sov_1_str = pair{1};
%     sov_2_str = pair{2};
% 
%     sov_1_symbols = table2array(symbol_factorArray(:, sov_1_str))';
%     sov_2_symbols = table2array(symbol_factorArray(:, sov_2_str))';
%     trialtype_O = table2array(symbol_factorArray('O', :));
% 
%     contrasts(end+1) = struct(  'name', sprintf('subset-O_%s-vs-%s',sov_1_str,sov_2_str), ...
%                                 'cond1',  cond_string(trialtype_O,sov_1_symbols), ...
%                                 'cond2', cond_string(trialtype_O,sov_2_symbols));
% end
%%
% run
delete(gcp('nocreate'))
tic
ticBytes(gcp);
parfor (cont_i=1:numel(contrasts) ,4)
% tic
% for cont_i=1:numel(contrasts)
    for sub_i=1:numel(subs)
        sub_input_filename = sprintf("s_%s_allSovs.mat",subs{sub_i});
        splitted = split(contrasts(cont_i).name, "_");
        subset_name = splitted{1};
        contrast_name = splitted{2};
        output_path = sprintf('%s\\%s\\%s_%s',main_output_dir,subset_name,subset_name,contrast_name);

        % if the datafile existes, continue
        files = dir(sprintf("%s\\ALL_NOSELECTION",output_path));
        filenames = string({files.name});
        if any(contains(filenames, sub_input_filename))
            continue;
        end

        run_adam_MVPA_firstlevel(sub_input_filename, contrasts(cont_i).cond1, contrasts(cont_i).cond2, output_path,cfg);
    end
end
tocBytes(gcp)
toc

%% run leave-one-out

sovs = {'wm','wn','N1','N2','N3','REM'};%
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','38'};
interim_results_dir = 'C:\adam-loo'; % this should be as short as possible! otherwise the file path will be too long

% GENERAL ANALYSIS CONFIGURATION SETTINGS
cfg = [];                       % clear the config variable
cfg.datadir = input_dir;
cfg.model = 'BDM';              % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';         % classify raw or time frequency representations ('tfr')
cfg.nfolds = 1;
cfg.class_method = 'AUC';       % 'dprime', 'hr' (hit rate), or 'far' (FA rate)
cfg.crossclass = 'yes';
cfg.balance_events = 'yes';     % for within-class balancing
cfg.balance_classes = 'yes';    % for cross-class balancing
cfg.channelpool = 'ALL_NOSELECTION';
cfg.resample = 'no'; 
cfg.save_confidence = 'yes';

for sov_i=1:numel(sovs)
    curr_sov = sovs{sov_i};
    sov_input_filename = sprintf("loo_%s.mat",curr_sov);
    for sub_i=1:numel(subs)
        curr_sub = subs{sub_i};

        subs_numbers = str2double(subs);
        indices_to_include = ~ismember(subs_numbers, str2double(curr_sub));
        class1.train = subs_numbers(indices_to_include) + 50;  % OF
        class2.train = subs_numbers(indices_to_include);  % OR
        class1.test = str2num(curr_sub) + 50; % OF
        class2.test = str2num(curr_sub); % OR
        cfg.class_spec{1} = cond_string(class1.train ,';', class1.test);
        cfg.class_spec{2} = cond_string(class2.train ,';', class2.test);

        subset_name = sprintf('subset-%s',curr_sov);
        contrast_name = 'OF-vs-OR';
        output_path = sprintf('%s\\%s\\%s_%s',interim_results_dir,subset_name,subset_name,contrast_name);

        run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path,cfg);
    end
end
%%

function run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path,cfg)
    cfg.filenames = file_list_restrict({sov_input_filename},'loo_');             % specifies filenames (EEG in this case)
    cfg.outputdir = output_path;  % output location
    adam_MVPA_firstlevel(cfg);                 % run first level analysis
end

function run_adam_MVPA_firstlevel(sub_input_filename, cond_1, cond_2, path,cfg)
    cfg.filenames = file_list_restrict({sub_input_filename},'s_');             % specifies filenames (EEG in this case)
    cfg.class_spec{1} = cond_1;  % the first stimulus class
    cfg.class_spec{2} = cond_2;  % the second stimulus class
    cfg.outputdir = path;  % output location
    adam_MVPA_firstlevel(cfg);                 % run first level analysis
end