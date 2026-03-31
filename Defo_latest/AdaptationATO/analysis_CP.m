clc
clear
%% Initialization section
addpath('C:\Users\User\Documents\GitHub\PE_Omission-Anat\Defo_latest\AdaptationATO')
[v, subs,dirs,epoch_time, events] = ADAPTATION_configuration();
addpath('C:\Users\User\Documents\GitHub\PE_Omission-Anat\Defo_latest\AdaptationATO')

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

%% Plot T1,T2,T3,T4 ERP across time 
comp_output_dir = sprintf("%s\\results",dirs.output_main);
conds = {v.Bl0T1, v.Bl0T4};
% sovs = {v.wn,v.N1,v.N2,v.N3,v.REM, v.N2EliwJKc,v.N2Eliwo,v.N2wo}; 
sovs = {v.REM};
%sovs = {v.wake_morning,v.wn,v.N1,v.N2,v.N3,v.REM,v.N2wo,v.N2wJSs,v.N2wJKc,v.N2Eliwo,v.N2EliwJSs,v.N2EliwJKc,v.pREM,v.tREM};
cfg = {};
cfg.ylim_ = [-28,8];
cfg.ticksY = cfg.ylim_(1):4:cfg.ylim_(2);
cfg.color_by_cond_or_sov = 'sov';
cfg.is_svg_plot = true;
cfg.test_successive_conds= 1;
curr_events = struct();
curr_events.tone = events.tone;
cfg.event_lines = curr_events; % ,n1_event,p2_event,n350_event

for sov_i =1:numel(sovs)
    condSovPairs = {};
    for cond_i=1:numel(conds)
        condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
    end
    curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},conds);
    plot_erp_per_condsSovPairs(comp_output_dir,curr_subs, epoch_time, condSovPairs,clusts_struct,sprintf("%s-T14",sovs{sov_i}.short_s),dirs ,cfg);
end


%% plot_erp_per_cond_across_sovs
comp_output_dir = sprintf("%s\\results",dirs.output_main);
conds = {v.Bl0T1,v.Bl0T2,v.Bl0T3,v.Bl0T4};
comps = {v.N100,v.P2,v.N350};
sovs_sets = {{v.pREM,v.tREM},{v.wn,v.N1,v.N2,v.N3,v.REM},{v.N2Eliwo,v.N2EliwJSs,v.N2EliwJKc},{v.N2wo,v.N2EliwJSs,v.N2EliwJKc}};
sovs_sets_names = {'rems','wn123rem','N2elis','N2woEventelis'};
% sovs_sets = {{v.wn,v.wake_morning}   , {v.wake_night_beg,
% v.wake_night_end,v.wake_morning_beg,v.wake_morning_end }}
%sovs_sets_names = {'wakes','wakesbegend'};

cfg=[];
cfg.ylim_ = [-28,8];
cfg.ticksY = cfg.ylim_(1):4:cfg.ylim_(2);
curr_events = struct();
curr_events.tone = events.tone;
cfg.plot_each_sub_comp_latency = comps;
cfg.plot_comp_mean_over_conds = conds;
cfg.color_by_cond_or_sov = 'sov';
cfg.is_svg_plot = true;
cfg.test_successive_conds= 0;

for sovset_i=1:numel(sovs_sets)
    sovs = sovs_sets{sovset_i};%
    for cond_i=1:numel(conds)
        condSovPairs = {};
        for sov_i =1:numel(sovs)
            condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
        end
        title =  sprintf("%s-%s",conds{cond_i}.short_s,sovs_sets_names{sovset_i});

        curr_subs = sub_exclu_per_sov(subs, sovs,{conds{cond_i}});
        plot_erp_per_condsSovPairs(comp_output_dir,curr_subs, epoch_time, condSovPairs,clusts_struct,title,dirs ,cfg);
    end
end

%% create time erps excel summary
file_pattern = sprintf('%s//ERP_name-*T1234_clust-centElec.mat',comp_output_dir);
results = generate_tcp_cluster_table(file_pattern);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                   % Exploratory %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Per sub: plot_erp_per_cond_across_sovs
comp_output_dir = sprintf("%s\\anatverirification",dirs.output_main);
sovs = {v.N2Eliwo,v.N2EliwJKc,v.N2EliwJSs}; 
conds = {v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4};
comps = {v.N100,v.P2,v.N350};

cfg=[];
cfg.is_plot_subs = true;
cfg.is_plot_ste = false;
cfg.ylim_ = [-12,6];
cfg.plot_each_sub_comp_latency = comps;
cfg.plot_comp_mean_over_conds = conds;
cfg.color_by_cond_or_sov = 'sov';
curr_events = {};
curr_events.tone = events.tone;
cfg.event_lines = curr_events;

for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},{conds{cond_i}});
        plot_erp_per_cond_across_sovs(dirs,comp_output_dir,epoch_time,curr_subs,conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);
    end
end

%% tones_diffs T_prev
comp_output_dir = sprintf("%s\\anatverirification",dirs.output_main);
sovs = {v.wn,v.N2,v.N3,v.REM}; % ,v.N1
tones_diffs={"low", "mid", "high"};

cfg = {};
% cfg.event_lines = {events.adaptor};
cfg.ylim_ = [-20,8];
cfg.ticksY = cfg.ylim_(1):4:cfg.ylim_(2);
cfg.color_by_cond_or_sov = 'sov';
cfg.is_svg_plot = true;
cfg.test_successive_conds= 0;
for pos = 1:4
    for sov_i =1:numel(sovs)
        condSovPairs = {};
        conds = {};
        for tones_i =1:numel(tones_diffs)
            import_name = sprintf("T_prev%s_%d",tones_diffs{tones_i},pos);
            condSovPairs{end+1} = {v.(import_name),sovs{sov_i}};
            conds{end+1} = v.(import_name);
        end
        title =  sprintf("%s-TDiff%d",sovs{sov_i}.short_s,pos);
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},conds);
        plot_erp_per_condsSovPairs(comp_output_dir,curr_subs, epoch_time,condSovPairs,clusts_struct,title ,dirs,cfg);
    end
end

%% toneHz analysis
THz_output_dir = sprintf("%s\\anatverirification\\THz",dirs.output_main);
sovs = {v.wn,v.N2,v.N3,v.REM}; % ,v.N1
tone_hz = [650,845,1428,1856,2413,3137,4079,5302];% T1098

% Collect all _X variables into a cell array
tone_pos_1_conds = {};
tone_pos_2_conds = {};
tone_pos_3_conds = {};
tone_pos_4_conds = {};
for i = tone_hz
   var_name = sprintf('v.Bl0T%d_1', i);
   tone_pos_1_conds{end+1} = eval(var_name);
   var_name = sprintf('v.Bl0T%d_2', i);
   tone_pos_2_conds{end+1} = eval(var_name);
   var_name = sprintf('v.Bl0T%d_3', i);
   tone_pos_3_conds{end+1} = eval(var_name);
   var_name = sprintf('v.Bl0T%d_4', i);
   tone_pos_4_conds{end+1} = eval(var_name);
end

cfg = {};
cfg.ylim_ = [-18,7];
cfg.color_by_cond_or_sov = 'sov';
% cfg.event_lines = {events.tone};
cfg.is_legend = false;
cfg.is_test = false;
tone_poses_conds = {tone_pos_1_conds,tone_pos_2_conds,tone_pos_3_conds,tone_pos_4_conds};
name_per_posescond = {"1","2","3","4"};

for sov_i =1:numel(sovs)
    for pose_i=1:numel(tone_poses_conds)
        condSovPairs = {};
        for cond_i=1:numel(tone_poses_conds{pose_i})
            condSovPairs{end+1} = {tone_poses_conds{pose_i}{cond_i},sovs{sov_i}};
        end
        title = sprintf("%s-allTPos%s",sovs{sov_i}.short_s,name_per_posescond{pose_i});
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},tone_poses_conds{pose_i});
        plot_erp_per_condsSovPairs(THz_output_dir,curr_subs, epoch_time,condSovPairs,clusts_struct,title ,dirs,cfg);
    end
end

%% analyze_event_prevalence
categories = {v.N2EliwJKc, v.N2EliwJSs, v.N2Eliwo};

conds_sets = {{v.Bl0T1, v.Bl0T2, v.Bl0T3, v.Bl0T4}};
conds_sets_names = {'T1-T4'};
% curr_subs = sub_exclu_per_sov(subs, categories,conds_sets{1});
[anova_results, param_results, nonparam_results] = analyze_event_prevalence(subs, {v.N2}, conds_sets, conds_sets_names, dirs, categories);

% conds_sets = {};
% conds_sets_names = {};
% % Loop through all tone frequencies
% for hz = tone_hz
%     % Create a set of conditions for this frequency (T1, T2, T3, T4)
%     current_set = {
%         v.(['Bl0T' num2str(hz) '_1']), 
%         v.(['Bl0T' num2str(hz) '_2']), 
%         v.(['Bl0T' num2str(hz) '_3']), 
%         v.(['Bl0T' num2str(hz) '_4'])
%     };
% 
%     % Add to our collection
%     conds_sets{end+1} = current_set;
%     conds_sets_names{end+1} = ['Bl0T' num2str(hz)];
% end
% [anova_results, param_results, nonparam_results] = analyze_event_prevalence(subs, {v.N2}, conds_sets, conds_sets_names, dirs.ft_cond_input, dirs.ft_cond_output, time, categories);


% conds_sets = {{v.Bl0T650_1,v.Bl0T845_1,v.Bl0T1098_1,v.Bl0T1428_1,v.Bl0T1856_1,v.Bl0T2413_1,v.Bl0T3137_1,v.Bl0T4079_1,v.Bl0T5302_1}};
% conds_sets = {{v.Bl0T650_2,v.Bl0T845_2,v.Bl0T1098_2,v.Bl0T1428_2,v.Bl0T1856_2,v.Bl0T2413_2,v.Bl0T3137_2,v.Bl0T4079_2,v.Bl0T5302_2}};
% conds_sets_names = {'Bl0T650_2-Bl0T5302_2'};
% [anova_results, param_results, nonparam_results] = analyze_event_prevalence(subs, {v.N2}, conds_sets, conds_sets_names, dirs, categories);
%%
sovs = {v.N2,v.N2EliwJKc, v.N2EliwJSs, v.N2Eliwo};
conds = {v.Bl0T650_1,v.Bl0T845_1,v.Bl0T1098_1,v.Bl0T1428_1,v.Bl0T1856_1,v.Bl0T2413_1,v.Bl0T3137_1,v.Bl0T4079_1,v.Bl0T5302_1,...
                v.Bl0T650_2,v.Bl0T845_2,v.Bl0T1098_2,v.Bl0T1428_2,v.Bl0T1856_2,v.Bl0T2413_2,v.Bl0T3137_2,v.Bl0T4079_2,v.Bl0T5302_2, ...
                v.Bl0T650_3,v.Bl0T845_3,v.Bl0T1098_3,v.Bl0T1428_3,v.Bl0T1856_3,v.Bl0T2413_3,v.Bl0T3137_3,v.Bl0T4079_3,v.Bl0T5302_3, ...
                v.Bl0T650_4,v.Bl0T845_4,v.Bl0T1098_4,v.Bl0T1428_4,v.Bl0T1856_4,v.Bl0T2413_4,v.Bl0T3137_4,v.Bl0T4079_4,v.Bl0T5302_4, ...
    };
T = generate_event_amount_table_for_R(subs, sovs, conds,  dirs.ft_cond_input, dirs.ft_cond_output, epoch_time);
writetable(T, 'out_to_lme_anal.csv');

%%
sovs = {v.N2,v.N2EliwJKc, v.N2EliwJSs, v.N2Eliwo};
conds = {v.T_prevhigh_1, v.T_prevhigh_2,v.T_prevhigh_3,v.T_prevhigh_4,...
        v.T_prevmid_1, v.T_prevmid_2, v.T_prevmid_3, v.T_prevmid_4, ...
        v.T_prevlow_1,v.T_prevlow_2,v.T_prevlow_3,v.T_prevlow_4,};
T = generate_event_amount_table_for_R(subs, sovs, conds,  dirs.ft_cond_input, dirs.ft_cond_output, epoch_time);
writetable(T, 'out_to_prev_lme_anal.csv');

sovs = {v.wn, v.N2, v.N3, v.REM}; 
diffconds = {{v.Bl0T1, v.Bl0T4}};

%% Plot both normalized and raw differences (default)
options.normalizedPlot = true;
options.rawPlot = true;
[diffs, norm_diffs, avg_norm, avg_raw] = normalize_and_plot_diff_erps( subs, sovs, diffconds, dirs.ft_cond_input, dirs.ft_cond_output, clusts_struct, time);


%% bl test 
% % % 
% % % bl_test_output_dir = sprintf("%s\\bl_test_res",dirs.output_main);
% % % time = -0.1:0.004:1.156;
% % % sovs = {Wnig,N2};
% % % 
% % % 
% % % cfg = {};
% % % cfg.event_lines = {adaptor_event,events.tone};
% % % cfg.test_latency = [0.58,1.16];
% % % cfg.plot_latency= [-0.1,1.16];
% % % maxPval = 0.05;
% % % cfg.is_plot_subs = false;
% % % cfg.is_plot_ste = true;
% % % cfg.ylim_ = [-3.5,4.5];
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}}, NblAT1,dirs.ft_cond_input,dirs.ft_cond_output,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{NblAT1,sovs{sov_i}}, {NblAT2,sovs{sov_i}},{NblAT3,sovs{sov_i}},{NblAT4,sovs{sov_i}}},clusts_struct,sprintf("NblAT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}}, AT1,dirs.ft_cond_input,dirs.ft_cond_output,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{AT1,sovs{sov_i}}, {AT2,sovs{sov_i}},{AT3,sovs{sov_i}},{AT4,sovs{sov_i}}},clusts_struct,sprintf("AT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % cfg = {};
% % % cfg.event_lines =  {events.tone};
% % % cfg.test_latency = [0,0.58];
% % % cfg.plot_latency= [-0.1,0.58];
% % % maxPval = 0.05;
% % % cfg.is_plot_subs = false;
% % % cfg.is_plot_ste = true;
% % % cfg.ylim_ = [-3.5,4.5];
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}}, NblT1,dirs.ft_cond_input,dirs.ft_cond_output,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{NblT1,sovs{sov_i}}, {NblT2,sovs{sov_i}},{NblT3,sovs{sov_i}},{NblT4,sovs{sov_i}}},clusts_struct,sprintf("NblT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}}, T1,dirs.ft_cond_input,dirs.ft_cond_output,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{T1,sovs{sov_i}}, {T2,sovs{sov_i}},{T3,sovs{sov_i}},{T4,sovs{sov_i}}},clusts_struct,sprintf("T1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end

%% -0.1 - 0.58  a1t1a2t2a3t3t4

% comp_output_dir = sprintf("%s\\comp_withincond_a1t1a2t2a3t3t4",dirs.output_main);
% sovs = {Wnig,N2,N3,REM};
% conds = {A500ofT500_1,T500_1,A500ofT500_2,T500_2,A500ofT500_3,T500_3,A500ofT500_4,T500_4};
% cfg = {};
% cfg.ylim_ = [-8,5];
% cfg.color_by_cond_or_sov = 'sov';
% 
% cfg.event_lines = {events.tone};
% 
% cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);
% cfg.ticksX = time(1):0.1:time(end);
% cfg.axisFontSize = 30;
% 
% for cond_i=1:numel(conds)
%     f = ADAPTATION_get_funcs_instant(subs,sovs, {conds{cond_i}},dirs.ft_cond_input,dirs.ft_cond_output,time);
%     condSovPairs = {};
%     for sov_i =1:numel(sovs)
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allSovs",conds{cond_i}.short_s) ,cfg);
% end
% 
% 
% for sov_i =1:numel(sovs)
%     condSovPairs = {};
%     for cond_i=1:numel(conds)
%          f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}},{conds{cond_i}},dirs.ft_cond_input,dirs.ft_cond_output,time);
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allATconds",sovs{sov_i}.short_s) ,cfg);
% end
% 
% 
% %
% conds = {A500_1_1st,A500_2_1st,A500_3_1st,A500_4_1st,A500ofT500_1,A500ofT500_2,A500ofT500_3,A500ofT500_4};
% cfg.ylim_ = [-8,5];
% cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);
% for cond_i=1:numel(conds)
%     f = ADAPTATION_get_funcs_instant(subs,sovs, {conds{cond_i}},dirs.ft_cond_input,dirs.ft_cond_output,time);
%     condSovPairs = {};
%     for sov_i =1:numel(sovs)
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allSovs",conds{cond_i}.short_s) ,cfg);
% end
% 
% 
% for sov_i =1:numel(sovs)
%     condSovPairs = {};
%     for cond_i=1:numel(conds)
%          f = ADAPTATION_get_funcs_instant(subs,{sovs{sov_i}},{conds{cond_i}},dirs.ft_cond_input,dirs.ft_cond_output,time);
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allAT1stconds",sovs{sov_i}.short_s) ,cfg);
% end


function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;

    % for cond_i=1:numel(conds)
    %     if strcmp(conds{cond_i}.import_s, 'NblT1098_1') || strcmp(conds{cond_i}.import_s, 'NblT1098_2') ||strcmp(conds{cond_i}.import_s, 'NblT1098_3') ||strcmp(conds{cond_i}.import_s, 'NblT1098_4') ...
    %         || strcmp(conds{cond_i}.import_s, 'T1098_1') || strcmp(conds{cond_i}.import_s, 'T1098_2') ||strcmp(conds{cond_i}.import_s, 'T1098_3') ||strcmp(conds{cond_i}.import_s, 'T1098_4')
    %         curr_sov_subs(ismember(curr_sov_subs, { '01'})) = [];
    %     end
    % end
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
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
    %         else
              if strcmp(sovs{sov_i}.import_s, 'N2EliwJKc')
                  if strcmp(conds{cond_i}.import_s, 'T3n500')
                      curr_sov_subs(ismember(curr_sov_subs, {'26'})) = [];
                  end
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
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T1856_2') || strcmp(conds{cond_i}.import_s, 'T3137_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'T1428_1') || strcmp(conds{cond_i}.import_s, 'T845_2') || strcmp(conds{cond_i}.import_s, 'T845_3') || strcmp(conds{cond_i}.import_s, 'T845_4')
                    
                    curr_sov_subs(ismember(curr_sov_subs, {'34'})) = [];
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
                end
    %         elseif strcmp(sovs{sov_i}.import_s, "tREM")
            elseif strcmp(sovs{sov_i}.import_s, "REM")
                if strcmp(conds{cond_i}.import_s, 'T650_1') || strcmp(conds{cond_i}.import_s, 'T650_2') ||strcmp(conds{cond_i}.import_s, 'T650_3') ||strcmp(conds{cond_i}.import_s, 'T650_4')
                    curr_sov_subs(ismember(curr_sov_subs, {'14'})) = [];
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
                end
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning_beg')
                if strcmp(conds{cond_i}.import_s, 'T3n500')
                    curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];
                end
    %         elseif strcmp(sovs{sov_i}.import_s, 'wake_night_beg')
    %             curr_sov_subs(ismember(curr_sov_subs, {'14' })) = [];
    % 
             end
        end
    end
end