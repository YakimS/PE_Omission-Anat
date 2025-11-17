function f = ATO_get_funcs_instant(actual_subs,actual_sovs, conds,ft_cond_input_dir,ft_cond_output_dir,time)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,conds);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time,'GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'; 
    timelock = imp.get_cond_timelocked(imp,{curr_sov_subs{1}},conds{1},actual_sovs{1});
    label = timelock{1}.label;
    electrodes = timelock{1}.elec;
    f = funcs_(imp, label,electrodes,time);
end

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'N1')
                curr_sov_subs(ismember(curr_sov_subs, { '33','36'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s, 'lastAT')
                    curr_sov_subs(ismember(curr_sov_subs, {'15'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, "tREM")
                curr_sov_subs(ismember(curr_sov_subs, {'36'})) = [];
            end
        end
    end
end
