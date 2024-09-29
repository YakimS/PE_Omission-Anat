
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false, [1, 0, 1]);
N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
N2wo = defineExpStruct("N2wo", "N2wo", "N2 w/o events", false,[0.7, 0.6, 0]);
N2woSs = defineExpStruct("N2woSs", "N2woSs", "N2 w/o spindles", false,[0.8, 0.6, 0]);
N2woKc = defineExpStruct("N2woKc", "N2woKc", "N2 w/o k-complex", false,[0.9, 0.6, 0]);
N3 = defineExpStruct("N3", "N3", "N3", false,[0, 1, 0]);
REM = defineExpStruct("REM", "REM", "REM", false,[1, 0, 0]);
tREM = defineExpStruct("tREM", "tREM", "tREM", false,[1, 0, 0]);
pREM = defineExpStruct("pREM", "pREM", "pREM", false,[1, 0, 0]);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0, 1]);
Wmor = defineExpStruct("wake_morning", "wm", "Wake Post", false,[0.5, 0.8, 1]); 
Wake = defineExpStruct("wake", "WAll", "Wake Pre+Post", false,[0.6, 0.9, 1]); % Short must be WAll for ft_importer

% components
N100 = defineExpComponent("N100", "N100", [0.05,0.15],false);
P2 = defineExpComponent("P2", "P2", [0.15,0.25],true);
N350 = defineExpComponent("N350", "N350", [0.3,0.5],false);

% conds [-0.1,0.58]
NblT1 = defineExpStruct("NblT1", "NblT1", "1st tone", false, [56/256, 166/256, 165/256]);
NblT2 = defineExpStruct("NblT2", "NblT2", "2nd tone", false,  [115/256, 175/256, 72/256]);
NblT3 = defineExpStruct("NblT3", "NblT3", "3rd tone", false, [237/256, 173/256, 8/256]);
NblT4 = defineExpStruct("NblT4", "NblT4", "4th tone", false,  [255/256, 124/256, 5/256]);
% 
% T1 = defineExpStruct("T1", "T1", "1st tone", false);
% T2 = defineExpStruct("T2", "T2", "2nd tone", false);
% T3 = defineExpStruct("T3", "T3", "3rd tone", false);
% T4 = defineExpStruct("T4", "T4", "4th tone", false);

% [-0.1, 1.16]
% AblT1 = defineExpStruct("AblT1", "AblT1", "1st tone", false);
% AblT2 = defineExpStruct("AblT2", "AblT2", "2nd tone", false);
% AblT3 = defineExpStruct("AblT3", "AblT3", "3rd tone", false);
% AblT4 = defineExpStruct("AblT4", "AblT4", "4th tone", false);
% 
% AT1 = defineExpStruct("AT1", "AT1", "1st tone", false, [56/256, 166/256, 165/256]);
% AT2 = defineExpStruct("AT2", "AT2", "2nd tone", false,  [115/256, 175/256, 72/256]);
% AT3 = defineExpStruct("AT3", "AT3", "3rd tone", false, [237/256, 173/256, 8/256]);
% AT4 = defineExpStruct("AT4", "AT4", "4th tone", false,  [255/256, 124/256, 5/256]);

% NblAT1 = defineExpStruct("NblAT1", "NblAT1", "1st tone", false);
% NblAT2 = defineExpStruct("NblAT2", "NblAT2", "2nd tone", false);
% NblAT3 = defineExpStruct("NblAT3", "NblAT3", "3rd tone", false);
% NblAT4 = defineExpStruct("NblAT4", "NblAT4", "4th tone", false);

%%%%%%%%
output_main_dir = "D:\OExpOut\adapt_res";
ft_cond_input_dir = "D:\OExpOut\processed_data\ft_subSovCond";
ft_cond_output_dir = "D:\OExpOut\processed_data\ft_processed";
libs_dir = 'D:\matlab_libs';

%%%%%%
%
subs = {'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};

%%%%%%%%%%%%%%%%%%%%%%%%%%
restoredefaultpath
addpath(sprintf('%s\\fieldtrip-20230223', libs_dir))
ft_defaults
addpath(sprintf('%s\\eeglab2023.0', libs_dir))
close;
addpath(libs_dir)
addpath(genpath('C:\Users\User\OneDrive\Documents\githubProjects'))

%% elec clusters
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 

time = -0.1:0.004:1.156;
f = get_funcs_instant(subs,{Wnig}, {NblT1},ft_cond_input_dir,ft_cond_output_dir,time);
arbitrary_cond = f.imp.get_cond_timelocked(f.imp,f.imp.subs,NblT1,Wnig);
arbitrary_cond_elec = arbitrary_cond{1}.elec;

clusts_struct = struct();
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;

% central
central_cluster = struct();
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '5 central elect';
central_cluster.('elect_label') =  {'E6','E13','E112','E7','E106'};
clusts_struct.('central5') = central_cluster;

%% -0.1 - 0.58
comp_output_dir = sprintf("%s\\comp_withincond",output_main_dir);
time = -0.1:0.004:0.576;
sovs = {Wnig,N2,N3,REM};
comps = {N100,P2,N350};% 
conds = {NblT1,NblT2,NblT3,NblT4};
cfg = {};
cfg.ylim_ = [-8,8];
cfg.color_by_cond_or_sov = 'cond';

for cond_i=1:numel(conds)
    f = get_funcs_instant(subs,sovs, {conds{cond_i}},ft_cond_input_dir,ft_cond_output_dir,time);
    condSovPairs = {};
    for sov_i =1:numel(sovs)
        condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
    end
    f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allSovs",conds{cond_i}.short_s) ,cfg);
end

sovs = {Wnig,N2,N3,REM,N2wo};
for sov_i =1:numel(sovs)
    condSovPairs = {};
    for cond_i=1:numel(conds)
         f = get_funcs_instant(subs,{sovs{sov_i}},{conds{cond_i}},ft_cond_input_dir,ft_cond_output_dir,time);
        condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
    end
    f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-NblT1234",sovs{sov_i}.short_s) ,cfg);
end

N2_sovs = {N2,N2woKc,N2woSs,N2wo};
condSovPairs = {};
for cond_i=1:numel(conds)
    f = get_funcs_instant(subs,N2_sovs, {conds{cond_i}},ft_cond_input_dir,ft_cond_output_dir,time);
    condSovPairs = {};
    for sov_i =1:numel(N2_sovs)
        condSovPairs{end+1} = {conds{cond_i},N2_sovs{sov_i}};
    end
    f.plot_erp_per_condsSovPairs(f,comp_output_dir,condSovPairs,clusts_struct,sprintf("%s-allN2Sovs",conds{cond_i}.short_s) ,cfg);
end


cfg.color_by_cond_or_sov = 'sov';
sovs = {Wnig,N2wo,N2woSs,N2woKc,N2,N3,REM};
for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, {NblT1,NblT2,NblT3,NblT4},ft_cond_input_dir,ft_cond_output_dir,time);
    for comp_i=1:numel(comps)
        s_s =  sprintf("NblT1234-%s",sovs{sov_i}.short_s);
        condSovPairs = {{NblT1,sovs{sov_i}},{NblT2,sovs{sov_i}},{NblT3,sovs{sov_i}}, {NblT4,sovs{sov_i}}};
        f.plot_violin_comp_condSovPairs(f, comp_output_dir, condSovPairs, clusts_struct, comps{comp_i} ,conds, s_s ,cfg);
    end
end

sovs = {Wnig,N2,N3,REM};
conds = {NblT1,NblT2,NblT3,NblT4};
cfg=[];
cfg.is_plot_subs = true;
cfg.is_plot_ste = false;
cfg.ylim_ = [-12,5];

n1_event = struct();
n1_event.("event_time") = N100.latency;
n1_event.("event_color") = [.2, .2 ,.2, 0.05];
n1_event.("event_text") = N100.long_s;
p2_event = struct();
p2_event.("event_time") = P2.latency;
p2_event.("event_color") = [.2, .2 ,.2,  0.05];
p2_event.("event_text") = P2.long_s;
n350_event = struct();
n350_event.("event_time") = N350.latency;
n350_event.("event_color") = [.2, .2 ,.2,  0.05];
n350_event.("event_text") = N350.long_s;
event_lines = {n1_event,p2_event,n350_event};
cfg.event_lines = event_lines;
cfg.plot_comp = comps;
cfg.plot_comp_mean_over_conds = conds;

for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
         f = get_funcs_instant(subs,{sovs{sov_i}}, {conds{cond_i}},ft_cond_input_dir,ft_cond_output_dir,time);
        f.plot_erp_per_cond_across_sovs(f,comp_output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);
    end
end

%% Wilcoxon between violin gaps sovs
res_dir = "D:\\OExpOut\\adapt_res\\comp";

sovs = {N3, N2, Wnig, REM};
conds = {NblT1, NblT2, NblT3, NblT4};
comps = {N100, P2, N350};

output_filename = fullfile(res_dir, 'WilcoxonTestResults.txt');
fileID = fopen(output_filename, 'w');

fprintf(fileID, 'Wilcoxon Signed-Rank Test Results\n');
fprintf(fileID, '---------------------------------\n\n');

for comp_i = 1:numel(comps)
    fprintf(fileID, 'Component: %s\n', comps{comp_i}.short_s);
    fprintf(fileID, '=================================\n\n');

    p_values = zeros(length(sovs), length(sovs), length(conds) - 1); % 3D matrix to store p-values
    z_values = zeros(length(sovs), length(sovs), length(conds) - 1); % 3D matrix to store test statistics
    
    for sov1_i = 1:length(sovs)
        for sov2_i = sov1_i + 1:length(sovs) % Only unique combinations
            all_diff_sov1 = []; % Initialize for storing all condition differences for sov1
            all_diff_sov2 = []; % Initialize for storing all condition differences for sov2
            for cond_i = 1:length(conds) - 1
                % Extract data for each condition and state
                sov_1_mat = load(sprintf("%s\\Comp-%s_name-NblT1234-%s_clust-centElec.mat", res_dir, comps{comp_i}.short_s, sovs{sov1_i}.short_s));
                sov_2_mat = load(sprintf("%s\\Comp-%s_name-NblT1234-%s_clust-centElec.mat", res_dir, comps{comp_i}.short_s, sovs{sov2_i}.short_s));
                data_sov1 = sov_1_mat.meta.data;
                data_sov2 = sov_2_mat.meta.data;
    
                diff_sov1 = data_sov1(:, cond_i) - data_sov1(:, cond_i + 1);
                diff_sov2 = data_sov2(:, cond_i) - data_sov2(:, cond_i + 1);
    
                % Perform Wilcoxon signed-rank test for each tone difference
                [p, ~, stats] = signrank(diff_sov1(:), diff_sov2(:));
    
                % Store the results
                p_values(sov1_i, sov2_i, cond_i) = p;
                z_values(sov1_i, sov2_i, cond_i) = stats.zval;
    
                % Determine significance stars
                if p < 0.001
                    stars = '***';
                elseif p < 0.01
                    stars = '**';
                elseif p < 0.05
                    stars = '*';
                else
                    stars = '';
                end

                % Create name for the current condition difference
                curr_cond_diff_name = sprintf("%s-%s", conds{cond_i}.short_s, conds{cond_i+1}.short_s);
                
                % Write the result to the file with significance stars
                fprintf(fileID, '%s vs. %s for cond %s: p-value = %.4f, z-value = %.4f %s\n', ...
                    sovs{sov1_i}.short_s, sovs{sov2_i}.short_s, curr_cond_diff_name, p, stats.zval, stars);

                % Concatenate all condition differences for the additional Wilcoxon test
                all_diff_sov1 = [all_diff_sov1; diff_sov1(:)]; % Accumulate differences
                all_diff_sov2 = [all_diff_sov2; diff_sov2(:)]; % Accumulate differences
            end

            % Additional Wilcoxon signed-rank test between all condition differences
            [p_all, ~, stats_all] = signrank(all_diff_sov1, all_diff_sov2);
            
            % Determine significance stars for the additional test
            if p_all < 0.001
                stars_all = '***';
            elseif p_all < 0.01
                stars_all = '**';
            elseif p_all < 0.05
                stars_all = '*';
            else
                stars_all = '';
            end

            % Write the additional Wilcoxon test result to the file
            fprintf(fileID, 'Wilcoxon test for all differences between %s and %s: p-value = %.4f, z-value = %.4f %s\n\n', ...
                sovs{sov1_i}.short_s, sovs{sov2_i}.short_s, p_all, stats_all.zval, stars_all);
        end
    end
    
    % Write p-values and z-values matrices to the file
    fprintf(fileID, '\nP-values for all combinations:\n');
    fprintf(fileID, '-----------------------------\n');
    for cond_i = 1:length(conds) - 1
        curr_cond_diff_name = sprintf("%s-%s", conds{cond_i}.short_s, conds{cond_i+1}.short_s);
        fprintf(fileID, 'Condition %s:\n', curr_cond_diff_name);
        disp_matrix = squeeze(p_values(:, :, cond_i));
        fprintf(fileID, '%f ', disp_matrix);
        fprintf(fileID, '\n');
    end
    
    fprintf(fileID, '\nZ-values for all combinations:\n');
    fprintf(fileID, '-----------------------------\n');
    for cond_i = 1:length(conds) - 1
        fprintf(fileID, 'Condition %s:\n', conds{cond_i}.short_s);
        disp_matrix = squeeze(z_values(:, :, cond_i));
        fprintf(fileID, '%f ', disp_matrix);
        fprintf(fileID, '\n');
    end
    
    fprintf(fileID, '\n=================================\n\n');
end

fclose(fileID);
fprintf('Results saved to %s successfully.\n', output_filename);


%% mixed modeling
sovs = {Wnig,N2,N3,REM};
conds = {NblT1,NblT2,NblT3,NblT4};
comps = {N100,P2,N350};% 
f.lme_comp(f, comps, sovs, conds, conds,clusts_struct,comp_output_dir)


%% bl test 
% % % 
% % % bl_test_output_dir = sprintf("%s\\bl_test_res",output_main_dir);
% % % time = -0.1:0.004:1.156;
% % % sovs = {Wnig,N2};
% % % 
% % % adaptor_event = struct();
% % % adaptor_event.("event_time") = 0;
% % % adaptor_event.("event_color") = [.2, .2 ,.2];
% % % adaptor_event.("event_text") = 'Adaptor';
% % % tone_event = struct();
% % % tone_event.("event_time") = 0.6;
% % % tone_event.("event_color") = [.2, .2 ,.2];
% % % tone_event.("event_text") = 'Tone';
% % % event_lines = {adaptor_event,tone_event};
% % % 
% % % cfg = {};
% % % cfg.event_lines = event_lines;
% % % cfg.test_latency = [0.58,1.16];
% % % cfg.plot_latency= [-0.1,1.16];
% % % maxPval = 0.05;
% % % cfg.is_plot_subs = false;
% % % cfg.is_plot_ste = true;
% % % cfg.ylim_ = [-3.5,4.5];
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = get_funcs_instant(subs,{sovs{sov_i}}, NblAT1,ft_cond_input_dir,ft_cond_output_dir,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{NblAT1,sovs{sov_i}}, {NblAT2,sovs{sov_i}},{NblAT3,sovs{sov_i}},{NblAT4,sovs{sov_i}}},clusts_struct,sprintf("NblAT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = get_funcs_instant(subs,{sovs{sov_i}}, AT1,ft_cond_input_dir,ft_cond_output_dir,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{AT1,sovs{sov_i}}, {AT2,sovs{sov_i}},{AT3,sovs{sov_i}},{AT4,sovs{sov_i}}},clusts_struct,sprintf("AT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % time = -0.1:0.004:0.576;
% % % 
% % % tone_event = struct();
% % % tone_event.("event_time") = 0;
% % % tone_event.("event_color") = [.2, .2 ,.2];
% % % tone_event.("event_text") = 'Tone';
% % % event_lines = {tone_event};
% % % 
% % % cfg = {};
% % % cfg.event_lines = event_lines;
% % % cfg.test_latency = [0,0.58];
% % % cfg.plot_latency= [-0.1,0.58];
% % % maxPval = 0.05;
% % % cfg.is_plot_subs = false;
% % % cfg.is_plot_ste = true;
% % % cfg.ylim_ = [-3.5,4.5];
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = get_funcs_instant(subs,{sovs{sov_i}}, NblT1,ft_cond_input_dir,ft_cond_output_dir,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{NblT1,sovs{sov_i}}, {NblT2,sovs{sov_i}},{NblT3,sovs{sov_i}},{NblT4,sovs{sov_i}}},clusts_struct,sprintf("NblT1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
% % % 
% % % for sov_i=1:numel(sovs)
% % %     f = get_funcs_instant(subs,{sovs{sov_i}}, T1,ft_cond_input_dir,ft_cond_output_dir,time);
% % %     f.plot_erp_per_condsSovPairs(f,bl_test_output_dir,{{T1,sovs{sov_i}}, {T2,sovs{sov_i}},{T3,sovs{sov_i}},{T4,sovs{sov_i}}},clusts_struct,sprintf("T1234-%s",sovs{sov_i}.short_s) ,cfg);
% % % end
%% functions

function f = get_funcs_instant(actual_subs,actual_sovs, conds,ft_cond_input_dir,ft_cond_output_dir,time)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,conds);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time,'GSN-HydroCel-129.sfp'); % if Cz is ref, use GSN-HydroCel-128.sfp. If not, use 'GSN-HydroCel-129.sfp'; 
    timelock = imp.get_cond_timelocked(imp,{curr_sov_subs{1}},conds{1},actual_sovs{1});
    label = timelock{1}.label;
    electrodes = timelock{1}.elec;
    f = funcs_(imp, label,electrodes,time);
end

function Y = uniquePairs(X)
    n = numel(X); % Number of elements in X
    Y = {}; % Initialize empty cell array for pairs

    for i = 1:n-1
        for j = i+1:n
            % Create each unique pair and add to Y
            Y{end+1} = {X{i}, X{j}};
        end
    end
end

function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline,color)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
    expStruct.color = color;
end

% isPositive is 1 or -1
function expStruct = defineExpComponent(short_s, long_s, latency,isPositive)
    expStruct = struct();
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.latency = latency;
    expStruct.isPositive = isPositive;
end

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'wake_night')
            elseif strcmp(sovs{sov_i}.import_s, 'N1')
    %             curr_sov_subs(ismember(curr_sov_subs, { '33'})) = [];
    %             curr_sov_subs(ismember(curr_sov_subs, { '36'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'N2')
            elseif strcmp(sovs{sov_i}.import_s, 'N2woKc') && strcmp(conds{cond_i}.import_s, 'NblT4')
                curr_sov_subs(ismember(curr_sov_subs, { '28'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
            elseif strcmp(sovs{sov_i}.import_s, "tREM")
                curr_sov_subs(ismember(curr_sov_subs, {'36'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, "REM")
            end
        end
    end
end
