function f = ADAPTATION_get_funcs_instant(actual_subs,actual_sovs, conds,ft_cond_input_dir,ft_cond_output_dir,time)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,conds);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time,'GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'; 
    timelock = imp.get_cond_timelocked(imp,{curr_sov_subs{1}},conds{1},actual_sovs{1});
    label = timelock{1}.label;
    electrodes = timelock{1}.elec;
    f = funcs_(imp, label,electrodes,time);
end


function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;

    for cond_i=1:numel(conds)
        if strcmp(conds{cond_i}.import_s, 'NblT1098_1') || strcmp(conds{cond_i}.import_s, 'NblT1098_2') ||strcmp(conds{cond_i}.import_s, 'NblT1098_3') ||strcmp(conds{cond_i}.import_s, 'NblT1098_4') ...
            || strcmp(conds{cond_i}.import_s, 'T1098_1') || strcmp(conds{cond_i}.import_s, 'T1098_2') ||strcmp(conds{cond_i}.import_s, 'T1098_3') ||strcmp(conds{cond_i}.import_s, 'T1098_4')
            curr_sov_subs(ismember(curr_sov_subs, { '01'})) = [];
        end
    end
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'wake_night')
                if strcmp(conds{cond_i}.import_s, 'Nbl1stT500_1') || strcmp(conds{cond_i}.import_s, 'Nbl1stA500_1') || ...
                    strcmp(conds{cond_i}.import_s, '1stT500_1') || strcmp(conds{cond_i}.import_s, '1stA500_1')
                    curr_sov_subs(ismember(curr_sov_subs, { '01'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'04','06','07','12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'06','07','12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'07','12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev21_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev37_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','04'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev37_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','04'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','33','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'33','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'33','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','26','37','38'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','26','38'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','26','38'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N1')
                if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T650_2')|| strcmp(conds{cond_i}.import_s, 'T650_3')|| strcmp(conds{cond_i}.import_s, 'T650_4')
                       curr_sov_subs(ismember(curr_sov_subs, {'03','04','08','09','11','33','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1098_1') || strcmp(conds{cond_i}.import_s, 'T1098_2') || strcmp(conds{cond_i}.import_s, 'T1098_3')|| strcmp(conds{cond_i}.import_s, 'T1098_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'38'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1428_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1428_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1856_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'20','25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1856_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1856_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1856_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'20','25'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T2413_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3137_1') ||strcmp(conds{cond_i}.import_s, 'T3137_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'10'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3137_3') ||strcmp(conds{cond_i}.import_s, 'T3137_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'10'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'N2')
                if strcmp(conds{cond_i}.import_s, 'T_prev13_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','06','07','12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','06'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev16_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev16_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev21_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'07'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev28_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'23','26'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev28_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'12','23','26'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','27','35'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','27','35'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'20','25','31'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'20','25','31'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'04','08','11','29'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'04','08','11','29'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'05'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'05'})) = [];   
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N2wo')
                   if strcmp(conds{cond_i}.import_s, '1stT1n500')
                       curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
                   elseif strcmp(conds{cond_i}.import_s, 'T650_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_2')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_3')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_4')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                   end
             elseif strcmp(sovs{sov_i}.import_s, 'N2Eliwo')
                   if strcmp(conds{cond_i}.import_s, '1stT1n500')
                       curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
                   elseif strcmp(conds{cond_i}.import_s, 'T650_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_2')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_3')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                    elseif strcmp(conds{cond_i}.import_s, 'T650_4')
                        curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                   end
            elseif strcmp(sovs{sov_i}.import_s, 'N2woKc') && strcmp(conds{cond_i}.import_s, 'NblT4')
            elseif strcmp(sovs{sov_i}.import_s, 'N2wKc')
            elseif strcmp(sovs{sov_i}.import_s, 'N2EliwJKc')
                if strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N2EliwJSs')
                if strcmp(conds{cond_i}.import_s, 'T1n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T2n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N2EliwSsKc')
                if strcmp(conds{cond_i}.import_s, 'T1n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','06','12','14','27','29','31','32','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T2n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','04','06','10','12','14','16','26','27','29','31','32','34','35','36','37'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, { '02','03','04','06','08','09','11','12','15','16','21','23','26','27','28','29','32','33','34','35','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T4n500')
                    curr_sov_subs(ismember(curr_sov_subs, { '02','04','06','08','09','12','13','14','15','16','17','19','23','26','29','30','31','32','34','35','36','37'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N2wSsKc')
                if strcmp(conds{cond_i}.import_s, 'T1n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'06','14','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T2n500')
                    curr_sov_subs(ismember(curr_sov_subs, { '12','16','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, { '08','12','26','32','34','35','27'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T4n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'12', '26','34'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N2wSs')
            elseif strcmp(sovs{sov_i}.import_s, 'N2wJSs')
                if strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, { '12'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s, 'T_prev13_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','05','06','07','08','12','14','16','27','30','32','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','05','06','07','08','12','14','16','27','30','32','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev16_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'17'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev16_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'17'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev21_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'35'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev21_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'35'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev28_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'27','37'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev28_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'37'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev37_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'03','21'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev37_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'03','21'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'04','19','25','28','31'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'04','19','25','28','31','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','10','15'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'02','10','15','23'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'23','24','29','36','38'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'24','29','38'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T650_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'06','14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T845_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T845_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T845_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1428_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1856_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3137_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1n500') ||strcmp(conds{cond_i}.import_s, 'T2n500') ||strcmp(conds{cond_i}.import_s, 'T3n500')||strcmp(conds{cond_i}.import_s, 'T4n500')
                    % curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','14'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','05','14'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, "tREM")
            elseif strcmp(sovs{sov_i}.import_s, "REM")
                if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T650_2') ||strcmp(conds{cond_i}.import_s, 'T650_3') ||strcmp(conds{cond_i}.import_s, 'T650_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T3137_1')
                    % curr_sov_subs(ismember(curr_sov_subs, {'07','14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','05','10','29','31','33'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'05','10','29','31','33'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','10','29','31','33'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','10','29','31','33'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_3')
                    curr_sov_subs(ismember(curr_sov_subs, {'21'})) = [];
                 elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_1')
                    curr_sov_subs(ismember(curr_sov_subs, {'21','28'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_2')
                    curr_sov_subs(ismember(curr_sov_subs, {'01','21','28'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'21'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning_beg')
                if strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'wake_night_beg')
                curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];

            end
        end
    end
end
