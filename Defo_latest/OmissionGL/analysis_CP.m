clc
clear
%%
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionGL')
[v, subs,dirs,epoch_time, events,ft_read_sens_string] = GL_configuration('cp');
addpath('C:\Users\User\OneDrive\Documents\githubProjects\Defo_latest\OmissionGL')


%%%%  get electrode cluster
arbitrary_cond = get_cond_timelocked(subs,v.ExOm,v.wn,dirs.ft_cond_input,dirs.ft_cond_output);
arbitrary_cond_elec = arbitrary_cond{1}.elec;

clusts_struct = struct();
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;

% frontal
% central_cluster = struct();
% central_cluster.('short_s') = 'frontElec';
% central_cluster.('long_s') = '6 frontal elect';
% central_cluster.('elect_label') =  {'Fp1','Fp2','F3', 'F4','Fz','FPz'};
% clusts_struct.('frontal4') = central_cluster;

% Get cluster 1 mask and find electrodes active ≥50% of cluster time
% a = load('D:\GlobalLocal\analysis_res\new_pipeline_GL\STCP-ERP_conds-UnexOm+ExOm_condsSovs-wn+wn_subAvg.mat')
% aaa = a.metadata.stat;
% cluster1_mask = aaa.posclusterslabelmat == 1;
% electrode_participation = sum(cluster1_mask, 2) / sum(any(cluster1_mask, 1));
% significant_electrodes = aaa.label(electrode_participation >= 0.5);
sig_cluster_mosttime = struct();
sig_cluster_mosttime.('short_s') = 'sigMosttime';
sig_cluster_mosttime.('long_s') = 'Positive Cluster, >50% timerange';
sig_cluster_mosttime.('elect_label') =  {'C3','C4','P3','P4','O1','O2','T7','T8','P7','P8','Cz','Pz','Oz','FCz'};
clusts_struct.('sigMosttime') = sig_cluster_mosttime;


if strcmp(ft_read_sens_string, "")
    cfg = {};
    cfg.method        =  'triangulation';
    cfg.feedback    = 'no';
    cfg.elec = arbitrary_cond_elec;
    neighbours = ft_prepare_neighbours(cfg);
else
    cfg = {};
    cfg.method = 'triangulation' ; 
    cfg.feedback    = 'no';
    cfg.elec= ft_read_sens(ft_read_sens_string );
    neighbours = ft_prepare_neighbours(cfg);
end
%% %% STCP ERP
res_output_dir = sprintf("%s\\new_pipeline_GL",dirs.output_main);
sovs = {v.wn, v.N1, v.N2, v.N3, v.REM};

cfg = {};
cfg.test_latency = [0,0.9];
cfg.plot_latency= [-0.8,0.9];
cfg.is_svg_plot = true;
maxPval = 0.05;
contrast = {v.UnexOm,v.ExOm};

% stcp
for sov_i=1:numel(sovs)
    curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrast);
    run_STCP_ERP_dependent(curr_subs, res_output_dir,contrast,{sovs{sov_i},sovs{sov_i}}, epoch_time,dirs,neighbours,cfg)
end

% create STCP excel summary
file_pattern = sprintf('%s//STCP-ERP_conds-UnexOm+ExOm_condsSovs-*_subAvg.mat',res_output_dir);
STCP_results = generate_stcp_cluster_table(file_pattern);
%% TCP ERP
res_output_dir = sprintf("%s\\new_pipeline_GL",dirs.output_main);
sovs = {v.wn, v.N1, v.N2, v.N3, v.REM};
contrast = {v.UnexOm,v.ExOm};

cfg = {};
cfg.event_lines = events;
cfg.test_latency = [0,0.9];
cfg.plot_latency= [-0.8,0.9];
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-2,7];
cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);
cfg.ticksX =cfg.plot_latency(1):0.2:cfg.plot_latency(end);
cfg.axisFontSize = 20;
cfg.LineWidth = 8;
cfg.is_test = true;
cfg.is_svg_plot = true;

% plot mean ExOm,UnexOm contrast in all sovs
for sov_i=1:numel(sovs)
    curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrast);
    condSovPairs = {};
    condSovPairs{1} = {v.ExOm,sovs{sov_i}};
    condSovPairs{2} = {v.UnexOm,sovs{sov_i}};

    plot_name = sprintf("conds-%s+%s_condsSov-%s+%s",contrast{1}.short_s,contrast{2}.short_s,sovs{sov_i}.short_s,sovs{sov_i}.short_s);
    plot_erp_per_condsSovPairs(res_output_dir,curr_subs, epoch_time, condSovPairs,clusts_struct,plot_name,dirs, cfg) ;
end


% create time erps excel summary
file_pattern = sprintf('%s\\ERP_name-conds-UnexOm+ExOm_condsSov-*_clust-*sigMosttime*.mat',res_output_dir);
TCP_results = generate_tcp_cluster_table(file_pattern);

% ExOm vs. UnexOm vs. ExCtrl
conds = {v.ExCtrl,v.ExOm,v.UnexOm};
cfg.ylim_ = [-2,4];
cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);

% for sov_i=1:numel(sovs)
%     f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
%     for cond_i=1:numel(conds)
%         f.plot_erp_per_cond_across_sovs(f,ExpUnexpOm_output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);      
%     end
% end
% for cond_i=1:numel(conds)
%        f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
%        f.plot_erp_per_cond_across_sovs(f,ExpUnexpOm_output_dir,conds{cond_i},sovs,clusts_struct,cfg);    
% end
% for cond_i=1:numel(conds)
%     f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
%     condSovPairs = {};
%     for sov_i =1:numel(sovs)
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,ExpUnexpOm_output_dir,condSovPairs,clusts_struct,sprintf("%s-allSovs",conds{cond_i}.short_s) ,cfg);
% end
% for sov_i =1:numel(sovs)
%     f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
%     condSovPairs = {};
%     for cond_i=1:numel(conds)
%         condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
%     end
%     f.plot_erp_per_condsSovPairs(f,ExpUnexpOm_output_dir,condSovPairs,clusts_struct,sprintf("%s-allConds",sovs{sov_i}.short_s) ,cfg);
% end


% plot ExOm,UnexOm contrast in all sovs, per subject
sovs = {v.wn, v.N1, v.N2, v.N3, v.REM}; % , v.N1, v.N2, v.N3, v.REM
conds = {v.ExOm,v.UnexOm};
cfg.is_plot_subs = true;
for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
        % f = get_funcs_instant(subs,{sovs{sov_i}}, v.ExOm,dirs.ft_cond_input,dirs.ft_cond_output,epoch_time);
        plot_erp_per_cond_across_sovs(dirs,res_output_dir,epoch_time, subs, conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);
    end
end

%% TFR ERP
res_output_dir = sprintf("%s\\new_pipeline_GL",dirs.output_main); % \\old_tfr
sovs = {v.wn, v.N1, v.N2, v.N3, v.REM}; % , v.N1, v.N2, v.N3, v.REM

adaptor_event1 = struct();
adaptor_event1.("event_time") = -0.15;
adaptor_event1.("event_color") = [.2, .2 ,.2];
adaptor_event1.("event_text") = 'Adaptor';
adaptor_event2 = adaptor_event1;
adaptor_event2.("event_time") = -0.3;
adaptor_event3 = adaptor_event2;
adaptor_event3.("event_time") = -0.45;
adaptor_event4 = adaptor_event3;
adaptor_event4.("event_time") = -0.6;
omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {adaptor_event1,adaptor_event2,adaptor_event3,adaptor_event4,omission_event};

tfr_algos = {'hilbert_zscored'}; % 'hilbert','multitaper','multitaper_zscored'
freqrange_test =  [0.5,40];
timerange_test = [0,0.9];
timerange_plot = [-0.8,0.9];

contrasts = {{v.UnexOm,v.ExOm}}; 
for tfr_algo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        for cont_i=1:numel(contrasts)
            curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
            run_TFCP_TFRMAP_dependent(curr_subs,res_output_dir,tfr_algos{tfr_algo_i}, contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot,neighbours,event_lines,dirs)
        end
    end
end

file_pattern = sprintf('%s\\TFCP-hilbert_zscored_conds-UnexOm+ExOm_condsSovs-*40*clust-sigMosttime.mat',res_output_dir);
TFR_results = generate_tfr_cluster_table(file_pattern);

%% TFR
output_dir = sprintf("%s\\new_pipeline_GL",output_main_dir); mkdir(output_dir); %
sovs = {v.wn, v.N2, v.N3, v.REM, v.N1}; % , v.N1, v.N2, v.N3, v.REM
tfr_algos = {'hilbert_zscored'}; % 'hilbert','multitaper','multitaper_zscored'
contrast = {v.UnexOm,v.ExOm};

timerange_test = [0,0.898];
freqrange_test =  {[0.5,4],[4,8],[8,13],[13,30],[30,50],[50,70]};
timerange_plot = [-0.8,0.898];
is_bl_in_band = false;

for tfr_algo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        for freq_i=1:numel(freqrange_test)
            curr_subs = sub_exclu_per_sov(subs, {sovs{sov_i}},contrasts{cont_i});
            run_STCP_TFR_dependent(f,output_dir, contrast,{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot,is_bl_in_band,tfr_algos{tfr_algo_i})
        end
    end
end

%%
function curr_sov_subs = sub_exclu_per_sov(subs, sovs,cond)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i}.import_s, 'wake_night')
        elseif strcmp(sovs{sov_i}.import_s, 'N1')
        elseif strcmp(sovs{sov_i}.import_s, 'N2')
        elseif strcmp(sovs{sov_i}.import_s, 'N3')
        elseif strcmp(sovs{sov_i}.import_s, "REM")
        end
    end
end