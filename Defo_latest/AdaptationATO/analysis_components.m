clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\AdaptationATO')
[v, subs,dirs,epoch_time, events] = ADAPTATION_configuration();
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\AdaptationATO')
%%%%  get electrode cluster
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 
arbitrary_cond = get_cond_timelocked(subs,v.Bl0T1,v.wn,dirs.ft_cond_input,dirs.ft_cond_output);
arbitrary_cond_elec = arbitrary_cond{1}.elec;
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;
% central
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '5 central elect';
central_cluster.('elect_label') =  {'E6','E13','E112','E7','E106'};
clusts_struct.('central5') = central_cluster;


%%
comps = {v.N100,v.P2,v.N350};%
comp_output_dir = sprintf("%s\\new_pipeline_adapt",dirs.output_main);
sovs = { v.wn, v.N2, v.N3, v.REM,v.N1 };

% v.wake_night_beg, v.wake_night_mid1, v.wake_night_mid2, v.wake_night_mid3, ...
%         v.wake_night_end, v.wake_morning_beg, v.wake_morning_end, v.wake_morning, ...
%         , v.N2Eliwo, v.N2EliwJSs, v.N2EliwJKc, ...
%         v.tREM, v.pREM

conds_sets = {{v.Bl0T1,v.Bl0T2,v.Bl0T3,v.Bl0T4}}; % {T1n500_1st, T2n500_1st, T3n500_1st, T4n500_1st}{{NblT1,NblT2,NblT3,NblT4}}; %{NblT1n500_1st, NblT2n500_1st, NblT3n500_1st, NblT4n500_1st}
conds_sets_names = {"T1234"}; % ,"1stT1234"

cfg.ylim_ = [-30,20];
cfg.color_by_cond_or_sov = 'sov';
cfg.is_fdr_inside_comp = 1;
cfg.test_successive_conds= 1;
cfg.ticksY = cfg.ylim_(1):5:cfg.ylim_(2);
for sov_i=1:numel(sovs)
    for condset_i=1:numel(conds_sets)
        curr_conds = conds_sets{condset_i};
        curr_conds_set_name = conds_sets_names{condset_i};
        condSovPairs =  {};
        for cond_i=1:numel(curr_conds)
            condSovPairs{end+1}= {curr_conds{cond_i},sovs{sov_i}};
        end
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},curr_conds);
        for comp_i=1:numel(comps)
            title =  sprintf("%s-%s-noOutliers",curr_conds_set_name,sovs{sov_i}.short_s);
            cfg.is_remove_no_peak_outliers = 1;
            [~] = plot_violin_comp_condSovPairs(epoch_time, curr_subs, dirs, comp_output_dir, condSovPairs, clusts_struct, comps{comp_i} ,title ,cfg);
        end
    end
end


%% Import component data to table
sovs = { v.wn, v.REM,v.N1 };%  v.N2, v.N3, v.wake_night_beg, v.wake_night_mid1, v.wake_night_mid2, v.wake_night_mid3, ...
                            %    v.wake_night_end, v.wake_morning_beg, v.wake_morning_end, v.wake_morning, ...
                             %       v.wn, v.N1, v.N2, v.N3, v.REM, v.N2Eliwo, v.N2EliwJSs, v.N2EliwJKc, ...
                              %  v.tREM, v.pREM
comps = {v.N100, v.P2, v.N350};
conds = {v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4};

[flat_table, ~, metadata] = create_component_amplitude_table(subs, sovs, comps, conds, central_cluster, dirs, epoch_time);

% Save the outputs
% save('component_amplitudes.mat', 'flat_table', 'nested_struct', 'metadata');
% writetable(flat_table, 'component_amplitudes.csv');

%%
excel_filename = 'component_ispeak_subs_counts.xlsx';
subs_count_per_compCondSov(flat_table,excel_filename);

%% create violing excel summary
comp_output_dir = sprintf("%s\\new_pipeline_adapt",dirs.output_main);
file_pattern = sprintf('%s/Comp-*_name-T1234*_clust-centElec.mat', comp_output_dir);

% For component-erp analysis with file pattern
[res_fdrCorrected, res_fdrComponentwiseCorrected] = generate_component_erp_table(file_pattern);

% If you need to exclude certain conditions
[res_fdrCorrected, res_fdrComponentwiseCorrected] = generate_component_erp_table(file_pattern, {'Bl0T3', 'Bl0T4'});


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                                                    % Exploratory %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Explore N2 rebound effect per tone-freq by plotting T1234 violin plots for each freq
comp_output_dir = sprintf("%s\\comp_withincond_Bl0_perTone",dirs.output_main);
sovs_sets = {{v.N2}};
comps = {v.N100,v.P2,v.N350};%
tone_hz = [650,845,1098,1428,1856,2413,3137,4079,5302];
conds_sets = {};
conds_sets_names = {};
for hz = tone_hz
    current_set = {v.(['Bl0T' num2str(hz) '_1']), v.(['Bl0T' num2str(hz) '_2']),  v.(['Bl0T' num2str(hz) '_3']), v.(['Bl0T' num2str(hz) '_4'])};
    conds_sets{end+1} = current_set;
    conds_sets_names{end+1} = ['Bl0T' num2str(hz)];
end

cfg.ylim_ = [-25,20];
cfg.color_by_cond_or_sov = 'sov';
cfg.ticksY = cfg.ylim_(1):5:cfg.ylim_(2);
for sovset_i=1:numel(sovs_sets)
    for condset_i=1:numel(conds_sets)
        curr_conds = conds_sets{condset_i};
        curr_conds_set_name = conds_sets_names{condset_i};
        for sov_i=1:numel(sovs_sets{sovset_i})
             condSovPairs =  {};
            for cond_i=1:numel(curr_conds)
                condSovPairs{end+1}= {curr_conds{cond_i},sovs_sets{sovset_i}{sov_i}};
            end
            f = ADAPTATION_get_funcs_instant(subs,{sovs_sets{sovset_i}{sov_i}}, curr_conds,dirs.ft_cond_input,dirs.ft_cond_output,time);
            for comp_i=1:numel(comps)
                plot_name =  sprintf("%s-%s-noOutliers",curr_conds_set_name,sovs_sets{sovset_i}{sov_i}.short_s);
                cfg.is_remove_no_peak_outliers = 1;
                [~] = plot_violin_comp_condSovPairs(f, dirs, comp_output_dir, condSovPairs, clusts_struct, comps{comp_i} , plot_name ,cfg);
            end
        end
    end
end



%% Analyze Successive Condition *Differences* Across States of Vigilance
% This analysis examines how component amplitudes change between successive
% stimulus presentations (T1→T2, T2→T3, T3→T4) and compares these changes
% across different states of vigilance sets.

% Setup output directory
comp_output_dir = fullfile(dirs.output_main, 'comp_withincond_Bl0Tno500');

% Define experimental parameters
conditions = {v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4};  % Four tone presentations
components = {v.N100, v.P2, v.N350};                % ERP components to analyze
contrasts = {'T1minusT2', 'T2minusT3', 'T3minusT4'};           % Successive differences to compute

sovs_sets = {{v.wn,v.N1,v.N2,v.N3,v.REM}}; %{v.wn,v.wake_morning},{v.wn,v.N1,v.N2,v.N3,v.REM},{v.N2Eliwo,v.N2EliwJKc,v.N2EliwJSs},{v.N2wo,v.N2wJKc,v.N2wJSs},{v.wn,v.N2,v.N3,v.REM,v.N2Eliwo}
sovs_sets_names = {'wn123rem'};%'wakes','wn123rem','n2eli','n2wSovs','wn23remN2eliwo','rems','n2w',"wn23rem"

% Configure analysis parameters
cfg = struct();
cfg.color_by = 'sov';             
cfg.is_fdr_inside_comp = false;   
cfg.ylim = [-10, 10];              
cfg.yticks = -8:4:8;              
cfg.min_subjects = 5;      

% Run analysis for each SOV group
for sov_idx = 1:numel(sovs_sets)
    data_funcs = ADAPTATION_get_funcs_instant(subs, sovs_sets{sov_idx}, conditions, ...
                                             dirs.ft_cond_input, dirs.ft_cond_output, time);
    sovcondSet_name = sprintf("%s-%s","T1m2m3m4",sovs_sets_names{sovset_i}); %m3m4
    results = analyze_successive_condition_differences(comp_output_dir, ...
                                                      components, ...
                                                      contrasts, ...
                                                      sovs_sets{sov_idx}, ...
                                                      sovcondSet_name, ...
                                                      cfg);
end




function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;

    % for cond_i=1:numel(conds)
    %     if strcmp(conds{cond_i}.import_s, 'NblT1098_1') || strcmp(conds{cond_i}.import_s, 'NblT1098_2') ||strcmp(conds{cond_i}.import_s, 'NblT1098_3') ||strcmp(conds{cond_i}.import_s, 'NblT1098_4') ...
    %         || strcmp(conds{cond_i}.import_s, 'T1098_1') || strcmp(conds{cond_i}.import_s, 'T1098_2') ||strcmp(conds{cond_i}.import_s, 'T1098_3') ||strcmp(conds{cond_i}.import_s, 'T1098_4')
    %         curr_sov_subs(ismember(curr_sov_subs, { '01'})) = [];
    %     end
    % end
    % for sov_i=1:numel(sovs)
    %     for cond_i=1:numel(conds)
    %         if strcmp(sovs{sov_i}.import_s, 'wake_night')
    %             if strcmp(conds{cond_i}.import_s, 'Nbl1stT500_1') || strcmp(conds{cond_i}.import_s, 'Nbl1stA500_1') || ...
    %                 strcmp(conds{cond_i}.import_s, '1stT500_1') || strcmp(conds{cond_i}.import_s, '1stA500_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '01'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'04','06','07','12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06','07','12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'07','12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev21_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev37_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','04'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev37_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','04'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','33','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'33','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'33','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','26','37','38'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','26','38'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','26','38'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N1')
    %             if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T650_2')|| strcmp(conds{cond_i}.import_s, 'T650_3')|| strcmp(conds{cond_i}.import_s, 'T650_4')
    %                    curr_sov_subs(ismember(curr_sov_subs, {'03','04','08','09','11','33','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1098_1') || strcmp(conds{cond_i}.import_s, 'T1098_2') || strcmp(conds{cond_i}.import_s, 'T1098_3')|| strcmp(conds{cond_i}.import_s, 'T1098_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'38'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1428_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1428_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1856_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'20','25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1856_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1856_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1856_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'20','25'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T2413_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3137_1') ||strcmp(conds{cond_i}.import_s, 'T3137_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'10'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3137_3') ||strcmp(conds{cond_i}.import_s, 'T3137_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'10'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
    %             curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
    %         elseif strcmp(sovs{sov_i}.import_s, 'wake')
    %             curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2')
    %             if strcmp(conds{cond_i}.import_s, 'T_prev13_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','06','07','12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','06'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev16_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev16_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev21_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'07'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev28_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'23','26'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev28_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'12','23','26'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','27','35'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','27','35'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'20','25','31'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'20','25','31'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'04','08','11','29'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'04','08','11','29'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05'})) = [];   
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2wo')
    %                if strcmp(conds{cond_i}.import_s, '1stT1n500')
    %                    curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
    %                elseif strcmp(conds{cond_i}.import_s, 'T650_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_2')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_3')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_4')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                end
    %          elseif strcmp(sovs{sov_i}.import_s, 'N2Eliwo')
    %                if strcmp(conds{cond_i}.import_s, '1stT1n500')
    %                    curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
    %                elseif strcmp(conds{cond_i}.import_s, 'T650_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_2')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_3')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                 elseif strcmp(conds{cond_i}.import_s, 'T650_4')
    %                     curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %                end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2woKc') && strcmp(conds{cond_i}.import_s, 'NblT4')
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2wKc')
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2EliwJKc')
    %             if strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2EliwJSs')
    %             if strcmp(conds{cond_i}.import_s, 'T1n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T2n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'12'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2EliwSsKc')
    %             if strcmp(conds{cond_i}.import_s, 'T1n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','06','12','14','27','29','31','32','34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T2n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','04','06','10','12','14','16','26','27','29','31','32','34','35','36','37'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '02','03','04','06','08','09','11','12','15','16','21','23','26','27','28','29','32','33','34','35','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T4n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '02','04','06','08','09','12','13','14','15','16','17','19','23','26','29','30','31','32','34','35','36','37'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2wSsKc')
    %             if strcmp(conds{cond_i}.import_s, 'T1n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06','14','34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T2n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '12','16','34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '08','12','26','32','34','35','27'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T4n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'12', '26','34'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2wSs')
    %         elseif strcmp(sovs{sov_i}.import_s, 'N2wJSs')
    %             if strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '12'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'N3')
    %             if strcmp(conds{cond_i}.import_s, 'T_prev13_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','05','06','07','08','12','14','16','27','30','32','34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev13_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','05','06','07','08','12','14','16','27','30','32','34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev16_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'17'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev16_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'17'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev21_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'35'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev21_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'35'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev28_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'27','37'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev28_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'37'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev37_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'03','21'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev37_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'03','21'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'04','19','25','28','31'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev48_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'04','19','25','28','31','36'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','10','15'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev62_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'02','10','15','23'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'23','24','29','36','38'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prev81_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'24','29','38'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T650_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'06','14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T845_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T845_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T845_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1428_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1856_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3137_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T1n500') ||strcmp(conds{cond_i}.import_s, 'T2n500') ||strcmp(conds{cond_i}.import_s, 'T3n500')||strcmp(conds{cond_i}.import_s, 'T4n500')
    %                 % curr_sov_subs(ismember(curr_sov_subs, {'06'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','14'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','05','14'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, "tREM")
    %         elseif strcmp(sovs{sov_i}.import_s, "REM")
    %             if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T650_2') ||strcmp(conds{cond_i}.import_s, 'T650_3') ||strcmp(conds{cond_i}.import_s, 'T650_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T3137_1')
    %                 % curr_sov_subs(ismember(curr_sov_subs, {'07','14'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','05','10','29','31','33'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'05','10','29','31','33'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','10','29','31','33'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevlow_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','10','29','31','33'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_3')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'21'})) = [];
    %              elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_1')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'21','28'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_2')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'01','21','28'})) = [];
    %             elseif strcmp(conds{cond_i}.import_s, 'T_prevmid_4')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'21'})) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'wake_morning_beg')
    %             if strcmp(conds{cond_i}.import_s, 'T3n500')
    %                 curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];
    %             end
    %         elseif strcmp(sovs{sov_i}.import_s, 'wake_night_beg')
    %             curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];
    % 
    %         end
    %     end
    % end
end
