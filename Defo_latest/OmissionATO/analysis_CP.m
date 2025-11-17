clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = ATO_configuration('cp');
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionATO')

% % 
% % %%%%  get electrode cluster
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 
arbitrary_cond = get_cond_timelocked(subs,v.AOmiF,v.wn,dirs.ft_cond_input,dirs.ft_cond_output);
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
%% STCP ERP
res_output_dir = sprintf("%s\\new_pipeline",dirs.output_main);
sovs = {v.wn, v.N2, v.N3, v.REM}; % , v.N1, v.N2, v.N3, v.REM
contrasts = {{v.AOmiR,v.AOmiF},{v.AOmi,v.intblksmpAO}};

cfg = {};
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_svg_plot = true;


for cont_i=1:numel(contrasts)
     for sov_i=1:numel(sovs)
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
        run_STCP_ERP_dependent(curr_subs, res_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}}, epoch_time,dirs,neighbours,cfg)
    end
end

% create STCP excel summary
file_pattern = sprintf('%s//STCP-ERP_conds-AOR+AOF_condsSovs-*_subAvg.mat',res_output_dir);
STCP_results = generate_stcp_cluster_table(file_pattern);

%% TCP ERP
res_output_dir = sprintf("%s\\new_pipeline",dirs.output_main);
sovs = {v.wn, v.N2, v.N3, v.REM}; % , v.N1, v.N2, v.N3, v.REM
contrasts = {{v.AOmiR,v.AOmiF},{v.AOmi,v.intblksmpAO}};

cfg = {};
cfg.dirs = dirs;
cfg.event_lines = events;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-1.2,4];
cfg.LineWidth = 8;
maxPval = 0.05;

cfg.ticksY = -1:1:4;
cfg.ticksX = 0:0.2:epoch_time(end);
cfg.axisFontSize = 20;
cfg.is_test = true;
cfg.is_svg_plot = true;


for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
        clust_wn_currContrast = get_electdClust('simple_contrast',res_output_dir,contrasts{cont_i},{v.wn,v.wn},maxPval);
        condSovPairs = {};
        condSovPairs{1} = {contrasts{cont_i}{1},sovs{sov_i}};
        condSovPairs{2} = {contrasts{cont_i}{2},sovs{sov_i}};

        plot_name = sprintf("conds-%s+%s_condsSov-%s+%s",contrasts{cont_i}{1}.short_s,contrasts{cont_i}{2}.short_s,sovs{sov_i}.short_s,sovs{sov_i}.short_s);
        plot_erp_per_condsSovPairs(res_output_dir,curr_subs, epoch_time, condSovPairs,clust_wn_currContrast,plot_name,dirs, cfg) ;

        clust_currSov_currContrast = get_electdClust('simple_contrast',res_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},maxPval);
        plot_erp_per_condsSovPairs(res_output_dir,curr_subs, epoch_time, condSovPairs,clust_currSov_currContrast,plot_name,dirs, cfg);
    end
end

% create time erps excel summary
file_pattern = sprintf('%s\\ERP_name-conds-AOR+AOF_condsSov-*_clust-AOR+AOF-wn+wn-neg-1.mat',res_output_dir);
TCP_results = generate_tcp_cluster_table(file_pattern);

%% TFR ERP
res_output_dir = sprintf("%s\\new_pipeline",dirs.output_main);
sovs = {v.wn, v.N2, v.N3, v.REM}; % , v.N1, v.N2, v.N3, v.REM, v.N1

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Adaptor';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {adaptor_event,omission_event};
tfr_algos = {'hilbert_zscored'}; % 'hilbert','multitaper','multitaper_zscored'

timerange_test = [0.58,1.16];
freqrange_test =  [0.5,40];
timerange_plot = [-0.1,1.16];

contrasts = {{v.AOmiR,v.AOmiF},{v.intblksmpAO,v.AOmi}}; %
for tfr_algo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        for cont_i=1:numel(contrasts)
            curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
            clust_wn_currContrast = get_electdClust('simple_contrast',res_output_dir,{v.AOmiR,v.AOmiF},{v.wn,v.wn},0.05);
            run_TFCP_TFRMAP_dependent(curr_subs,res_output_dir,tfr_algos{tfr_algo_i}, contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clust_wn_currContrast,timerange_plot,neighbours,event_lines,dirs)
        end
    end
end

file_pattern = sprintf('%s\\TFCP-hilbert_zscored_conds-AOR+AOF_condsSovs-*clust-AOR+AOF-wn+wn-neg-1.mat',res_output_dir);
TFR_results = generate_tfr_cluster_table(file_pattern);

%%

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'N1')
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
            elseif strcmp(sovs{sov_i}.import_s, 'wake')
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s, 'AOR')
                    curr_sov_subs(ismember(curr_sov_subs, { '11'})) = [];
                end
            elseif strcmp(sovs{sov_i}.import_s, 'REM')
                if strcmp(conds{cond_i}.import_s, 'AOF')
                elseif strcmp(conds{cond_i}.import_s, 'AOR')
                end
            elseif strcmp(sovs{sov_i}.import_s, "tREM")
            end
        end
    end
end