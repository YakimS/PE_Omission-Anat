function run_mvpa_firstlevel(analysis_type, input_dir, output_dir, contrasts, sovs, subs, varargin)
% RUN_MVPA_FIRSTLEVEL Runs first level MVPA analysis
% For LOO: contrasts = {cont_string}, sovs = sovs_string
% For regular: contrasts = {cont_string}, sovs = sovs_string
% For randperm: contrasts = {cont_string}, sovs = sovs_string
% varargin: 'parallel_workers', 4 (for regular analysis)
%           'randpermutations', 30 (for randperm analysis)

    % Handle optional parameters
    parallel_workers = 4; % default
    randpermutations = 30; % default
    if nargin > 6
        for i = 1:2:length(varargin)
            if strcmpi(varargin{i}, 'parallel_workers')
                parallel_workers = varargin{i+1};
            elseif strcmpi(varargin{i}, 'randpermutations')
                randpermutations = varargin{i+1};
            end
        end
    end
    
    switch lower(analysis_type)
        case 'loo'
            run_loo_analysis(input_dir, output_dir, contrasts, sovs, subs);
        case 'regular'
            run_regular_analysis(input_dir, output_dir, contrasts, sovs, subs, parallel_workers);
        case 'randperm'
            run_randperm_analysis(input_dir, output_dir, contrasts, sovs, subs, randpermutations);
        otherwise
            error('Analysis type not implemented yet: %s', analysis_type);
    end
end

function run_randperm_analysis(input_dir, output_dir, contrasts, sovs, subs, randpermutations)
    cfg = get_base_config(input_dir);
    cfg.nfolds = 5;
    cfg.crossclass = 'no';
    cfg.resample = 'no';
    cfg.save_confidence = 'yes';
    cfg.randompermutations = randpermutations;
    
    % Extract contrast strings if wrapped in cell
    if iscell(contrasts) && length(contrasts) == 1
        cont_string = contrasts{1};
    else
        cont_string = contrasts;
    end
    
    % Create symbol table for no-LOO design
    n_conditions = length(cont_string);
    n_sovs = length(sovs);
    symbol_table = create_symbol_table(n_conditions, n_sovs);
    symbol_factorArray = array2table(symbol_table, 'RowNames', cont_string, 'VariableNames', sovs);
    
    % Define contrasts within each SOV
    contrasts_structs = struct('name', {}, 'cond1', {}, 'cond2', {});
    
    % For each contrast pair
    for cont_i = 1:length(cont_string)-1
        for cont_j = cont_i+1:length(cont_string)
            % For each SOV
            for sov_i = 1:numel(sovs)
                sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
                trialtype_cond1 = table2array(symbol_factorArray(cont_string{cont_i}, :));
                trialtype_cond2 = table2array(symbol_factorArray(cont_string{cont_j}, :));
                
                contrasts_structs(end+1) = struct(...
                    'name', sprintf('subset-%s_%s-vs-%s', sovs{sov_i}, cont_string{cont_i}, cont_string{cont_j}), ...
                    'cond1', intersect(trialtype_cond1, sov_symbols), ...
                    'cond2',intersect(trialtype_cond2, sov_symbols));
            end
        end
    end
    
    % Run analysis for each subject
    for cont_i = 1:numel(contrasts_structs)
        for sub_i = 1:numel(subs)
            sub_input_filename = sprintf("s-%d_allSovs", sub_i);
            splitted = split(contrasts_structs(cont_i).name, '_');
            subset_name = splitted{1};
            contrast_name = splitted{2};
            output_path = sprintf('%s\\%s\\%s_%s', output_dir, subset_name, subset_name, contrast_name);
            
            % Check existing permutations
            existing_perms = check_existing_permutations(output_path, sub_i);
            if existing_perms < randpermutations
                cfg.randompermutations = randpermutations - existing_perms;
                fprintf("Running: sub %d, %s, only %d perms exist (need %d more)\n", ...
                    sub_i, subset_name, existing_perms, cfg.randompermutations);
                run_adam_MVPA_firstlevel_regular(sub_input_filename, contrasts_structs(cont_i).cond1, ...
                    contrasts_structs(cont_i).cond2, output_path, cfg);
            else
                fprintf("Done: sub %d, %s, all %d perms exist\n", sub_i, subset_name, randpermutations);
            end
        end
    end
end


function run_regular_analysis(input_dir, output_dir, cont_string, sovs, subs, parallel_workers)
    cfg = get_base_config(input_dir);
    cfg.nfolds = 10;
    cfg.crossclass = 'yes';
    cfg.resample = 'no';
    cfg.save_confidence = 'yes';
    
    % Create symbol table for no-LOO design
    n_conditions = length(cont_string);
    n_sovs = length(sovs);
    symbol_table = create_symbol_table(n_conditions, n_sovs);
    symbol_factorArray = array2table(symbol_table, 'RowNames', cont_string, 'VariableNames', sovs);
    
    % Define contrasts within each SOV
    contrasts_structs = struct('name', {}, 'cond1', {}, 'cond2', {});
    
    % For each contrast pair
    for cont_i = 1:length(cont_string)-1
        for cont_j = cont_i+1:length(cont_string)
            % For each SOV
            for sov_i = 1:numel(sovs)
                sov_symbols = table2array(symbol_factorArray(:, sovs{sov_i}))';
                trialtype_cond1 = table2array(symbol_factorArray(cont_string{cont_i}, :));
                trialtype_cond2 = table2array(symbol_factorArray(cont_string{cont_j}, :));
                
                contrasts_structs(end+1) = struct(...
                    'name', sprintf('subset-%s_%s-vs-%s', sovs{sov_i}, cont_string{cont_i}, cont_string{cont_j}), ...
                    'cond1', intersect(trialtype_cond1, sov_symbols), ...
                    'cond2', intersect(trialtype_cond2, sov_symbols));
                
            end
        end
    end
    
    % Run analysis with parallel processing
    delete(gcp('nocreate'));
    parfor (cont_i = 1:numel(contrasts_structs), parallel_workers)
        for sub_i = 1:numel(subs)
            sub_input_filename = sprintf("s-%d_allSovs.mat", sub_i);
            splitted = split(contrasts_structs(cont_i).name, '_');
            subset_name = splitted{1};
            contrast_name = splitted{2};
            output_path = sprintf('%s\\%s\\%s_%s', output_dir, subset_name, subset_name, contrast_name);
            
            % Check if file exists
            files = dir(sprintf("%s\\ALL_NOSELECTION", output_path));
            filenames = string({files.name});
            if any(contains(filenames, sub_input_filename))
                fprintf('Skipping: sub %d, %s_%s (already exists)\n', sub_i, subset_name, contrast_name);
                continue;
            end
            
            fprintf('Running: sub %d/%d, %s_%s\n', sub_i, numel(subs), subset_name, contrast_name);
            run_adam_MVPA_firstlevel_regular(sub_input_filename, contrasts_structs(cont_i).cond1, ...
                contrasts_structs(cont_i).cond2, output_path, cfg);
        end
    end
end


function run_loo_analysis(input_dir, loo_output_dir, cont_string, sovs, subs)
    cfg = get_base_config(input_dir);
    cfg.nfolds = 1;
    cfg.crossclass = 'yes';
    cfg.balance_events = 'yes';
    cfg.balance_classes = 'yes';
    cfg.resample = 'no';
    cfg.save_confidence = 'yes';
    
    % LOO uses sequential numbering: 
    % first condition 1-N, second condition (N+1)-2N
    n_subjects = numel(subs);
    condition_offsets = [0, n_subjects]; % Offsets for each condition
    
    % For each contrast pair
    for cont_i = 1:length(cont_string)-1
        for cont_j = cont_i+1:length(cont_string)
            
            % For each SOV
            for sov_i = 1:numel(sovs)
                curr_sov_short = sovs{sov_i};

                sov_input_filename = sprintf("loo_%s.mat", curr_sov_short);
                
                % For each subject as test set
                for sub_i = 1:numel(subs)
                    subs_numbers = 1:numel(subs);
                    indices_to_include = ~ismember(subs_numbers, sub_i);
                    
                    % Setup class specifications with correct offsets
                    % First contrast condition
                    class1.train = subs_numbers(indices_to_include) + condition_offsets(cont_i);
                    class1.test = sub_i + condition_offsets(cont_i);
                    
                    % Second contrast condition  
                    class2.train = subs_numbers(indices_to_include) + condition_offsets(cont_j);
                    class2.test = sub_i + condition_offsets(cont_j);
                    
                    cfg.class_spec{1} = cond_string(class1.train, ';', class1.test);
                    cfg.class_spec{2} = cond_string(class2.train, ';', class2.test);
                    
                    % Setup output path
                    subset_name = sprintf('subset-%s', curr_sov_short);
                    contrast_name = sprintf('%s-vs-%s', cont_string{cont_i}, cont_string{cont_j});
                    output_path = sprintf('%s\\%s\\%s_%s', loo_output_dir, subset_name, subset_name, contrast_name);
                    
                    % Check if output already exists
                    output_file = sprintf('%s\\ALL_NOSELECTION\\CLASS_PERF_loo_%s.mat', output_path, curr_sov_short);
                    if exist(output_file, 'file')
                        fprintf('Skipping: %s (already exists)\n', output_file);
                        continue;
                    end
                    
                    % Run analysis
                    fprintf('Running LOO: sub %d/%d, %s, %s\n', sub_i, numel(subs), curr_sov_short, contrast_name);
                    fprintf('  Class 1: train=%s, test=%d\n', mat2str(class1.train), class1.test);
                    fprintf('  Class 2: train=%s, test=%d\n', mat2str(class2.train), class2.test);
                    
                    run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path, cfg);
                end
            end
        end
    end
end

function cfg = get_base_config(input_dir)
    cfg = [];
    cfg.datadir = input_dir;
    cfg.model = 'BDM';
    cfg.raw_or_tfr = 'raw';
    cfg.class_method = 'AUC';
    cfg.channelpool = 'ALL_NOSELECTION';
end

% Helper function to create class specification strings
function str = cond_string(varargin)
    if nargin == 2
        % Simple case: two arrays
        str = sprintf('%d ', varargin{1});
        str = strtrim(str);
    elseif nargin == 3
        % Train/test split case with separator
        train_str = sprintf('%d ', varargin{1});
        test_str = sprintf('%d ', varargin{3});
        str = [strtrim(train_str), ' ', varargin{2}, ' ', strtrim(test_str)];
    else
        error('cond_string: unexpected number of arguments');
    end
end

function run_adam_MVPA_firstlevel_loo(sov_input_filename, output_path, cfg)
    cfg.filenames = file_list_restrict({sov_input_filename}, 'loo_');
    cfg.outputdir = output_path;
    adam_MVPA_firstlevel(cfg);
end

function run_adam_MVPA_firstlevel_regular(sub_input_filename, cond_1, cond_2, path, cfg)
    cfg.filenames = file_list_restrict({sub_input_filename}, 's-');
    cfg.class_spec{1} = cond_1;
    cfg.class_spec{2} = cond_2;
    cfg.outputdir = path;
    adam_MVPA_firstlevel(cfg);
end


function existing_perms = check_existing_permutations(output_path, sub_i)
    randperm_dir = sprintf("%s\\ALL_NOSELECTION\\randperm", output_path);
    if ~exist(randperm_dir, 'dir')
        existing_perms = 0;
        return;
    end
    
    randperm_files = dir(randperm_dir);
    pattern = sprintf('CLASS_PERF_s-%d_.*PERM(\\d+)', sub_i);
    perm_numbers = [];
    
    for i = 1:length(randperm_files)
        curr_file = randperm_files(i).name;
        tokens = regexp(curr_file, pattern, 'tokens');
        if ~isempty(tokens)
            perm_num = str2double(tokens{1}{1});
            perm_numbers = [perm_numbers, perm_num];
        end
    end
    
    if isempty(perm_numbers)
        existing_perms = 0;
    else
        existing_perms = max(perm_numbers);
    end
end