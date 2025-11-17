clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OffResponse')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = offresp_configuration('cp');
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OffResponse')

% % 
% % %%%%  get electrode cluster
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 
arbitrary_cond = get_cond_timelocked({subs{1}},v.LastOmiR,v.wn,dirs.ft_cond_input,dirs.ft_cond_output);
arbitrary_cond_elec = arbitrary_cond{1}.elec;
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;
% % % central
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '5 central elect';
central_cluster.('elect_label') =  {'E6','E13','E112','E7','E106'};
clusts_struct.('central5') = central_cluster;


if strcmp(ft_read_sens_string, "")
    cfg = {};
    cfg.method        =  'triangulation';
    cfg.feedback    = 'no';
    cond_names = fieldnames(o.timlocked);
    cfg.elec = o.timlocked.(cond_names{1}){1}.elec;
    neighbours = ft_prepare_neighbours(cfg);
else
    cfg = {};
    cfg.method = 'triangulation' ; 
    cfg.feedback    = 'no';
    cfg.elec= ft_read_sens(ft_read_sens_string );
    neighbours = ft_prepare_neighbours(cfg);
end

%% TCP ERP
res_output_dir = sprintf("%s\\EndOfBlock_new",dirs.output_main);
sovs = {v.wn, v.N2, v.N3, v.REM}; % 
contrasts = {{v.LastOmiR,v.LastOmiF}};

cfg = {};
cfg.dirs = dirs;
cfg.event_lines = events;
cfg.test_latency = [0.58,3];
cfg.plot_latency= [-1,3];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-10,10];
cfg.LineWidth = 8;
maxPval = 0.05;

cfg.ticksY = -10:1:10;
cfg.ticksX = -1:0.2:epoch_time(end);
cfg.axisFontSize = 20;
cfg.is_test = true;
cfg.is_svg_plot = true;


for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
        condSovPairs = {};
        condSovPairs{1} = {contrasts{cont_i}{1},sovs{sov_i}};
        condSovPairs{2} = {contrasts{cont_i}{2},sovs{sov_i}};

        plot_name = sprintf("conds-%s+%s_condsSov-%s+%s",contrasts{cont_i}{1}.short_s,contrasts{cont_i}{2}.short_s,sovs{sov_i}.short_s,sovs{sov_i}.short_s);
        plot_erp_per_condsSovPairs(res_output_dir,curr_subs, epoch_time, condSovPairs,clusts_struct,plot_name,dirs, cfg) ;
    end
end

% create time erps excel summary
file_pattern = sprintf('%s\\ERP_name-conds-LastOmiR+LastOmiF_condsSov-*_clust-AOR+AOF-wn+wn-neg-1.mat',res_output_dir);
TCP_results = generate_tcp_cluster_table(file_pattern);

%%

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'N1')
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
            elseif strcmp(sovs{sov_i}.import_s, 'wake_night')
                if strcmp(conds{cond_i}.import_s, 'BlockLastAOR')
                    curr_sov_subs(ismember(curr_sov_subs, { '29','30','32'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'BlockLastAOF')
                    curr_sov_subs(ismember(curr_sov_subs, { '33'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s, 'BlockLastAOR')
                curr_sov_subs(ismember(curr_sov_subs, { '15','17','21','23','27','34'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'BlockLastAOF')
                    curr_sov_subs(ismember(curr_sov_subs, { '16','32'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'REM')
                if strcmp(conds{cond_i}.import_s, 'BlockLastAOR')
                curr_sov_subs(ismember(curr_sov_subs, { '11','31','36'})) = [];
                elseif strcmp(conds{cond_i}.import_s, 'BlockLastAOF')
                    curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
                end
            end
        end
    end
end