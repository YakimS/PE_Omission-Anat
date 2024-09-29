
input_dir = 'C:\mvpa\GL\preprocessed';
main_output_dir = 'C:\mvpa\GL\FirstLevel';

loo_output_dir = 'C:\loo\GL'; % this should be as short as possible! otherwise the file path will be too long
contrasts = {{'expomit','unexpomit'}};
sovs = {'wnight','N1','N2','N3','REM'};
conds_string = {'expomit','unexpomit'};
subs = {'1989RTKS','1991AGPE','1993AGRI','1993MRAB','1994LUAA','1994MREG','1994PTBV','1995ALKL','1995DNFR','1995GBKA','1995PTAF','1995RMBN','1995RTKL','1996RTHL','1996USRY','1997AIWG','1997ALKL','1997KRGT','1997MRBAE','1997RMDB','1998AADE','1998BRTI','1998IAKN','1999RTLY','1999VTSA','2000DLAL','2000UEAB'};


%%%%%%%%%%%%%%%%%%%%%%% my design %%%%%%%%%%%%%%%%%%%%%%
%                               
%                                 factor "ses"
%                                    wake_night        N1               N2       N3     REM
% 
% factor          expomit               1               2             3        4       5                 
% "trialtype"     unexpomit             6               7             8        9      10         

%                   
data_table = [
    1,  2, 3, 4, 5;
    6,  7, 8, 9, 10];

symbol_factorArray = array2table(data_table, 'RowNames',conds_string , 'VariableNames', sovs);

%%  regualr + random perm (not leave-one-out)
output_dir = sprintf("%s\\RESULTS_resamp100_subRandPerm",main_output_dir);
cfg = [];                                  
cfg.datadir = input_dir;                  
cfg.model = 'BDM';                         % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';                    % classify raw or time frequency representations ('tfr')
cfg.nfolds = 5;                            % for test 3
cfg.class_method = 'AUC';             	   
cfg.crossclass = 'no';                    % whether to compute temporal generalization
cfg.channelpool = 'ALL_NOSELECTION';       
cfg.resample = 100;                         % downsample, "no" or sampling rate units(<250hz) (useful for temporal generalization). For test 30
cfg.save_confidence = 'yes';
cfg.randompermutations = 30;%200;            % USE ONLY if you want to have within subject decoding significant line

contrasts_structs = struct('name', {}, 'cond1', {}, 'cond2', {});

%%% Define contrasts
% contrasts, within sov
for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
        trialtype_cond1 = table2array(symbol_factorArray(contrasts{cont_i}{1}, :));
        trialtype_cond2 = table2array(symbol_factorArray(contrasts{cont_i}{2}, :));
    
        contrasts_structs(end+1) = struct(  'name',sprintf( 'subset-%s_%s-vs-%s',sovs{sov_i},contrasts{cont_i}{1},contrasts{cont_i}{2}), ...
                            'cond1', cond_string(trialtype_cond2,sov_symbols), ...
                            'cond2', cond_string(trialtype_cond1,sov_symbols));
    end
end

%%% sov vs. sov, within condition
% unique_pairs_sovs = nchoosek(sovs, 2);
% for bsc_i=1:numel(between_sovs_conds)
%     for i = 1:size(unique_pairs_sovs, 1)
%         pair = unique_pairs_sovs(i, :);
%         sov_1_str = pair{1};
%         sov_2_str = pair{2};
%     
%         sov_1_symbols = table2array(symbol_factorArray(:, sov_1_str))';
%         sov_2_symbols = table2array(symbol_factorArray(:, sov_2_str))';
%         trialtype_O = table2array(symbol_factorArray(between_sovs_conds{bsc_i}, :));
%     
%         contrasts_structs(end+1) = struct(  'name', sprintf('subset-%s_%s-vs-%s',between_sovs_conds{bsc_i},sov_1_str,sov_2_str), ...
%                                     'cond1',  cond_string(trialtype_O,sov_1_symbols), ...
%                                     'cond2', cond_string(trialtype_O,sov_2_symbols));
%     end
% end

%%%%%%%%%%%%%%%    run    %%%%%%%%%%%%%%%%%
% delete(gcp('nocreate'))
% tic
% ticBytes(gcp);
% parfor (cont_i=1:numel(contrasts) ,4)
tic
for cont_i=1:numel(contrasts_structs)
    for sub_i=1:numel(subs)
        sub_input_filename = sprintf("s-%d_allSovs.mat",sub_i);
        splitted = split(contrasts_structs(cont_i).name, "_");
        subset_name = splitted{1};
        contrast_name = splitted{2};
        output_path = sprintf('%s\\%s\\%s_%s',output_dir,subset_name,subset_name,contrast_name);

        % if the datafile existes, continue
        files = dir(sprintf("%s\\ALL_NOSELECTION",output_path));
        filenames = string({files.name});
        if any(contains(filenames, sub_input_filename))
            continue;
        end

        run_adam_MVPA_firstlevel(sub_input_filename, contrasts_structs(cont_i).cond1, contrasts_structs(cont_i).cond2, output_path,cfg);
    end
end
% tocBytes(gcp)
toc
%%  regualr (not leave-one-out)
output_dir = sprintf("%s\\RESULTS_resamp100",main_output_dir);

cfg = [];                                  
cfg.datadir = input_dir;                  
cfg.model = 'BDM';                         % backward decoding ('BDM') or forward encoding ('FEM')
cfg.raw_or_tfr = 'raw';                    % classify raw or time frequency representations ('tfr')
cfg.nfolds = 10;%10;                            % for test 3
cfg.class_method = 'AUC';             	   
cfg.crossclass = 'yes';                    % whether to compute temporal generalization
cfg.channelpool = 'ALL_NOSELECTION';       
cfg.resample = 100;%100;                         % downsample, "no" or sampling rate units(<250hz) (useful for temporal generalization). For test 30
cfg.save_confidence = 'yes';
contrasts_structs = struct('name', {}, 'cond1', {}, 'cond2', {});

%%% Define contrasts
% contrasts, within sov
for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
        trialtype_cond1 = table2array(symbol_factorArray(contrasts{cont_i}{1}, :));
        trialtype_cond2 = table2array(symbol_factorArray(contrasts{cont_i}{2}, :));
    
       contrasts_structs(end+1) = struct(  'name',sprintf( 'subset-%s_%s-vs-%s',sovs{sov_i},contrasts{cont_i}{1},contrasts{cont_i}{2}), ...
                            'cond1', cond_string(trialtype_cond2,sov_symbols), ...
                            'cond2', cond_string(trialtype_cond1,sov_symbols));
    end
end


% sov vs. sov, within condition
% unique_pairs_sovs = nchoosek(sovs, 2);
% for bsc_i=1:numel(between_sovs_conds)
%     for i = 1:size(unique_pairs_sovs, 1)
%         pair = unique_pairs_sovs(i, :);
%         sov_1_str = pair{1};
%         sov_2_str = pair{2};
%     
%         sov_1_symbols = table2array(symbol_factorArray(:, sov_1_str))';
%         sov_2_symbols = table2array(symbol_factorArray(:, sov_2_str))';
%         trialtype_O = table2array(symbol_factorArray(between_sovs_conds{bsc_i}, :));
%     
%         contrasts_structs(end+1) = struct(  'name', sprintf('subset-%s_%s-vs-%s',between_sovs_conds{bsc_i},sov_1_str,sov_2_str), ...
%                                     'cond1',  cond_string(trialtype_O,sov_1_symbols), ...
%                                     'cond2', cond_string(trialtype_O,sov_2_symbols));
%     end
% end


%%%%%%%%%%%%%%%    run    %%%%%%%%%%%%%%%%%
% delete(gcp('nocreate'))
% tic
% ticBytes(gcp);
% parfor (cont_i=1:numel(contrasts) ,4)
% tic
for cont_i=1:numel(contrasts_structs)
    for sub_i=1:numel(subs)
        sub_input_filename = sprintf("s-%d_allSovs.mat",sub_i);
        splitted = split(contrasts_structs(cont_i).name, "_");
        subset_name = splitted{1};
        contrast_name = splitted{2};
        output_path = sprintf('%s\\%s\\%s_%s',output_dir,subset_name,subset_name,contrast_name);

        % if the datafile existes, continue
        files = dir(sprintf("%s\\ALL_NOSELECTION",output_path));
        filenames = string({files.name});
        if any(contains(filenames, sub_input_filename))
            continue;
        end

        run_adam_MVPA_firstlevel(sub_input_filename, contrasts_structs(cont_i).cond1, contrasts_structs(cont_i).cond2, output_path,cfg);
    end
end
% tocBytes(gcp)
% toc

%% run leave-one-out

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
cfg.resample = 100;%100;             % downsample, "no" or sampling rate units(<250hz) (useful for temporal generalization). For test 30
cfg.save_confidence = 'yes';

for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        curr_sov = sovs{sov_i};
        if strcmp(curr_sov,'wnight')
            curr_sov = 'wn';
        end
        sov_input_filename = sprintf("loo_%s.mat",curr_sov);
        for sub_i=1:numel(subs)
    
            subs_numbers = 1:numel(subs);
            indices_to_include = ~ismember(subs_numbers, sub_i);
            class1.train = subs_numbers(indices_to_include) + 50;  % OF
            class2.train = subs_numbers(indices_to_include);  % OR
            class1.test = sub_i + 50; % OF
            class2.test = sub_i; % OR
            cfg.class_spec{1} = cond_string(class1.train ,';', class1.test);
            cfg.class_spec{2} = cond_string(class2.train ,';', class2.test);
    
            subset_name = sprintf('subset-%s',curr_sov);
            contrast_name = sprintf('%s-vs-%s',contrasts{cont_i}{1},contrasts{cont_i}{2});
            output_path = sprintf('%s\\%s\\%s_%s',loo_output_dir,subset_name,subset_name,contrast_name);
    
            run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path,cfg);
        end
    end
end
%%

function run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path,cfg)
    cfg.filenames = file_list_restrict({sov_input_filename},'loo_');             % specifies filenames (EEG in this case)
    cfg.outputdir = output_path;  % output location
    adam_MVPA_firstlevel(cfg);                 % run first level analysis
end

function run_adam_MVPA_firstlevel(sub_input_filename, cond_1, cond_2, path,cfg)
    cfg.filenames = file_list_restrict({sub_input_filename},'s-');             % specifies filenames (EEG in this case)
    cfg.class_spec{1} = cond_1;  % the first stimulus class
    cfg.class_spec{2} = cond_2;  % the second stimulus class
    cfg.outputdir = path;  % output location
    adam_MVPA_firstlevel(cfg);                 % run first level analysis
end