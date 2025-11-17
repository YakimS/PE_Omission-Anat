function T = generate_event_amount_table_for_R(subs, sovs, conds, ft_cond_input_dir, ft_cond_output_dir, time)
    
    % Get functions with combined conditions
    f = ADAPTATION_get_funcs_instant(subs, sovs, conds, ft_cond_input_dir, ft_cond_output_dir, time);

    colNames = {'sub', 'sov', 'cond','trial_amount'};
    T = table([], [], [],[], 'VariableNames', colNames);


    % Process data for each condition and subject
    for sov_i = 1:numel(sovs)
        for cond_i = 1:numel(conds)
            for sub_i = 1:numel(f.imp.subs)
                try
                    curr_cond_timelockAll = f.imp.get_cond_timelocked(f.imp, {f.imp.subs{sub_i}}, conds{cond_i}, sovs{sov_i});
                    trial_amount = curr_cond_timelockAll{1}.cfg.trials_timelocked_avg;
                catch ME
                    if strcmp(ME.message,"This function requires 'raw+comp' or 'raw' data as input, see ft_datatype_raw.")
                        trial_amount=0;
                    elseif strcmp(ME.identifier,'MyComponent:LessThanFiveTrials')
                        trial_amount = str2double(regexp(ME.message, '\d+$', 'match', 'once'));
                    else
                        throw(ME)
                    end
                end
                newRow = {f.imp.subs{sub_i}, sovs{sov_i}.short_s, conds{cond_i}.short_s, trial_amount};
                T = [T; newRow];
            end
        end
    end
end

