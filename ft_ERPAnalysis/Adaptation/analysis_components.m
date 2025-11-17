clc
clear
%%
addpath('ADAPTATION_configuration.m')
[v, subs,dirs,time, events] = ADAPTATION_configuration();
addpath('C:\Users\User\OneDrive\Documents\githubProjects\ft_ERPAnalysis')

%%%%  get electrode cluster
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 
f = ADAPTATION_get_funcs_instant(subs,{v.wn}, {v.Bl0T1},dirs.ft_cond_input,dirs.ft_cond_output,time);
arbitrary_cond = f.imp.get_cond_timelocked(f.imp,f.imp.subs,v.Bl0T1,v.wn);
arbitrary_cond_elec = arbitrary_cond{1}.elec;
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;
% central
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '5 central elect';
central_cluster.('elect_label') =  {'E6','E13','E112','E7','E106'};
clusts_struct.('central5') = central_cluster;

%%
comps = {v.N100,v.P2,v.N350};%
comp_output_dir = sprintf("%s\\comp_withincond_Bl0Tno500",dirs.output_main);

sovs = {v.wake_night_beg, v.wake_night_mid1, v.wake_night_mid2, v.wake_night_mid3, ...
        v.wake_night_end, v.wake_morning_beg, v.wake_morning_end, v.wake_morning, ...
        v.wn, v.N1, v.N2, v.N3, v.REM, v.N2Eliwo, v.N2EliwJSs, v.N2EliwJKc, ...
        v.tREM, v.pREM};
conds_sets = {{v.Bl0T1,v.Bl0T2,v.Bl0T3,v.Bl0T4}}; % {T1n500_1st, T2n500_1st, T3n500_1st, T4n500_1st}
% conds_sets = {{NblT1,NblT2,NblT3,NblT4}}; %{NblT1n500_1st, NblT2n500_1st, NblT3n500_1st, NblT4n500_1st}
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
        f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}}, curr_conds,dirs.ft_cond_input,dirs.ft_cond_output,time);
        for comp_i=1:numel(comps)
            title =  sprintf("%s-%s-noOutliers",curr_conds_set_name,sovs{sov_i}.short_s);
            cfg.is_remove_no_peak_outliers = 1;
            [~] = plot_violin_comp_condSovPairs(f, dirs, comp_output_dir, condSovPairs, clusts_struct, comps{comp_i} ,title ,cfg);
        end
    end
end


%% Import component data to table
sovs = {v.wake_night_beg, v.wake_night_mid1, v.wake_night_mid2, v.wake_night_mid3, ...
        v.wake_night_end, v.wake_morning_beg, v.wake_morning_end, v.wake_morning, ...
        v.wn, v.N1, v.N2, v.N3, v.REM, v.N2Eliwo, v.N2EliwJSs, v.N2EliwJKc, ...
        v.tREM, v.pREM};
comps = {v.N100, v.P2, v.N350};
conds = {v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4};

[flat_table, ~, metadata] = create_component_amplitude_table(subs, sovs, comps, conds, central_cluster, dirs, time);

% Save the outputs
% save('component_amplitudes.mat', 'flat_table', 'nested_struct', 'metadata');
% writetable(flat_table, 'component_amplitudes.csv');

%%
excel_filename = 'component_ispeak_subs_counts.xlsx';
subs_count_per_compCondSov(flat_table,excel_filename);

%% create violing excel summary
comp_output_dir = sprintf("%s\\comp_withincond_Bl0Tno500",dirs.output_main);
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