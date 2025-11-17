
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false, [0.9, 0.1, 0.9]);
N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
N3 = defineExpStruct("N3", "N3", "N3", false,[0.1, 0.9, 0.1]);
REM = defineExpStruct("REM", "REM", "REM", false,[0.9, 0.1, 0.1]);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0.7, 1]);


% [-2, 1.996]
ExOm = defineExpStruct("expomit", "ExOm", "deviant omission", false, [0, 0, 0]);
UnexOm = defineExpStruct("unexpomit", "UnexOm", "control 4", false, [0, 0, 0]);
ExCtrl = defineExpStruct("expomitctrl", "ExCtrl", "control 5", false, [0, 0, 0]);


%%%%%%%%
output_main_dir = "D:\GlobalLocal\analysis_res";
ft_cond_input_dir = "D:\GlobalLocal\ft_subSovCond_blPreO";
ft_cond_output_dir = "D:\GlobalLocal\ft_processed_blPreO";
libs_dir = 'D:\matlab_libs';

%%%%%%

subs = {'1989RTKS','1991AGPE','1993AGRI','1993MRAB','1994LUAA','1994MREG','1994PTBV','1995ALKL','1995DNFR','1995GBKA','1995PTAF','1995RMBN','1995RTKL','1996RTHL','1996USRY','1997AIWG','1997ALKL','1997KRGT','1997MRBAE','1997RMDB','1998AADE','1998BRTI','1998IAKN','1999RTLY','1999VTSA','2000DLAL','2000UEAB'};

%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
restoredefaultpath 
addpath(sprintf('%s\\fieldtrip-20241219', libs_dir)) % fieldtrip-20230223
ft_defaults
addpath(sprintf('%s\\eeglab2024.2', libs_dir)) %%eeglab2023.0'
close;
addpath(libs_dir)
addpath(genpath('C:\Users\User\OneDrive\Documents\githubProjects'))

%% elec clusters

time = -2:0.004:1.996;
f = get_funcs_instant(subs,{Wnig}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
arbitrary_cond = f.imp.get_cond_timelocked(f.imp,f.imp.subs,ExOm,Wnig);
arbitrary_cond_elec = arbitrary_cond{1}.elec;

clusts_struct = struct();
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;

% central
central_cluster = struct();
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '4 central elect';
central_cluster.('elect_label') =  {'Cz','C3','C4','FCz'};
clusts_struct.('central4') = central_cluster;

% all
allElec_cluster = struct();
allElec_cluster.('short_s') = 'allElec';
allElec_cluster.('long_s') = 'all elect';
allElec_cluster.('elect_label') =  arbitrary_cond_elec.label;
clusts_struct.('allElec') = allElec_cluster;


% % frontal
% frontal_cluster = struct();
% frontal_cluster.('short_s') = 'frontElec';
% frontal_cluster.('long_s') = '9 front elect';
% frontal_cluster.('elect_label') =  {'Fz','FPz','F3','F4','FCz','Fp1','Fp2','F7','F8'};
% clusts_struct.('frontal5') = frontal_cluster;


% 
% % frontopariatal
% fronParia_cluster = struct();
% fronParia_cluster.('short_s') = 'frnPrtElc';
% fronParia_cluster.('long_s') = '14 front-pariatal elect';
% fronParia_cluster.('elect_label') =  {'Fp1','Fp2','F3','F4','P3','P4','F7','F8','P7','P8','Fz','Pz','FPz','FCz'};
% clusts_struct.('frontal5') = fronParia_cluster;
% 


% % % wn: intblk vs AO
% clust_wn_intblk_AO_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% clust_wn_intblk_AO = f.get_electdClust(f,'simple_contrast',clust_wn_intblk_AO_res_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
% clusts_struct.('clust_wn_intblk_AO_pos1') = clust_wn_intblk_AO.pos_1; 
% clusts_struct.('clust_wn_intblk_AO_neg1') = clust_wn_intblk_AO.neg_1; 

%% STCP: ExOm vs. UnexOm 
ExpUnexpOm_output_dir = sprintf("%s\\ExpUnexpOm_res_blPreO",output_main_dir);
time = -2:0.004:1.996;
sovs = {Wnig,N1,N2,N3,REM}; 
conds = {ExOm,UnexOm};

omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [0,0,0];
omission_event.('event_text_color') = [0,0,0];
omission_event.("event_text") = 'Omission';
event_lines = {omission_event};
adaptor_event = struct();
adaptor_event.("event_time") = [-0.15,-0.05];
adaptor_event.("event_color") = [.85, .85 ,.85];
adaptor_event.('event_text_color') = [0,0,0];
adaptor_event.("event_text") = 'A';
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = [-0.3,-0.2];
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = [-0.45,-0.35];
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = [-0.6,-0.5];
event_lines{end+1} = adaptor_event;

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0,0.85];
cfg.plot_latency= [-0.85,0.85];
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-1,5];
maxPval = 0.05;

cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);
cfg.ticksX = time(1):0.2:time(end);
cfg.axisFontSize = 20;
cfg.LineWidth = 8;
cfg.is_test = true;
cfg.is_svg_plot = true;

% stcp
for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
    f.run_STCP_ERP_dependent(f,ExpUnexpOm_output_dir,{ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}}, cfg)
end

% plot mean ExOm,UnexOm contrast in all sovs
for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
    f.plot_erp_per_contrast_and_sov(f,ExpUnexpOm_output_dir,{ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},clusts_struct, cfg);
    
    wn_electd_clust = f.get_electdClust(f,'simple_contrast',ExpUnexpOm_output_dir,{ExOm,UnexOm},{Wnig,Wnig},maxPval);
    f.plot_erp_per_contrast_and_sov(f,ExpUnexpOm_output_dir,{ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},wn_electd_clust, cfg);

    curr_electd_clust = f.get_electdClust(f,'simple_contrast',ExpUnexpOm_output_dir,{ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},maxPval);
    f.plot_erp_per_contrast_and_sov(f,ExpUnexpOm_output_dir,{ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);
end


% plot ExOm,UnexOm contrast in all sovs, per subject
sovs = {Wnig,N2,N3,N1,REM}; 
cfg.is_plot_subs = true;
for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
        f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
        f.plot_erp_per_cond_across_sovs(f,ExpUnexpOm_output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);
    end
end


%% ExOm vs. UnexOm vs. ExCtrl

ExpUnexpOm_output_dir = sprintf("%s\\ExpUnexpOm_res_blPreO",output_main_dir);
sovs = {N1,N2,N3,REM}; 
time = -2:0.004:1.996;
cfg.is_plot_subs = false;
conds = {ExCtrl,ExOm,UnexOm};

omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {omission_event};
adaptor_event = struct();
adaptor_event.("event_time") = -0.15;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.3;
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.45;
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.6;
event_lines{end+1} = adaptor_event;

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0,0.85];
cfg.plot_latency= [-0.85,0.85];
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-2,4];
cfg.ticksY = cfg.ylim_(1):1:cfg.ylim_(2);
cfg.ticksX = time(1):0.2:time(end);
cfg.axisFontSize = 20;
cfg.LineWidth = 8;

for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
    for cond_i=1:numel(conds)
        f.plot_erp_per_cond_across_sovs(f,ExpUnexpOm_output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct,cfg);      
    end
end

for cond_i=1:numel(conds)
       f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
       f.plot_erp_per_cond_across_sovs(f,ExpUnexpOm_output_dir,conds{cond_i},sovs,clusts_struct,cfg);    
end

for cond_i=1:numel(conds)
    f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
    condSovPairs = {};
    for sov_i =1:numel(sovs)
        condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
    end
    f.plot_erp_per_condsSovPairs(f,ExpUnexpOm_output_dir,condSovPairs,clusts_struct,sprintf("%s-allSovs",conds{cond_i}.short_s) ,cfg);
end

for sov_i =1:numel(sovs)
    f = get_funcs_instant(subs,sovs, conds{cond_i},ft_cond_input_dir,ft_cond_output_dir,time);
    condSovPairs = {};
    for cond_i=1:numel(conds)
        condSovPairs{end+1} = {conds{cond_i},sovs{sov_i}};
    end
    f.plot_erp_per_condsSovPairs(f,ExpUnexpOm_output_dir,condSovPairs,clusts_struct,sprintf("%s-allConds",sovs{sov_i}.short_s) ,cfg);
end

%% TFR
output_dir = sprintf("%s\\ExpUnexpOm_res_blPreO",output_main_dir); mkdir(output_dir); %
sovs = {Wnig,N2,N3,REM,N1}; 
tfr_algos = {'hilbert_zscored','multitaper_zscored'}; % 'hilbert','multitaper'
time = -2:0.004:1.996;

timerange_test = [0,0.848];
freqrange_test =  {[0.5,4],[4,8],[8,13],[13,30],[30,50],[50,70]};
timerange_plot = [-0.848,0.848];
is_bl_in_band = false;

for tfr_algo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        for freq_i=1:numel(freqrange_test)
            f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
            f.run_STCP_TFR_dependent(f,output_dir, {ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot,is_bl_in_band,tfr_algos{tfr_algo_i})
        end
    end
end

%%
output_dir = sprintf("%s\\ExpUnexpOm_res_blPreO",output_main_dir); mkdir(output_dir); %
sovs = {Wnig,REM,N2,N3,N1}; % 
tfr_algos = {'hilbert_zscored','multitaper_zscored'}; % 'hilbert','multitaper'

freqrange_test =  [0.5,45];
timerange_test = [0,0.848];
timerange_plot = [-0.848,0.848];

time = -2:0.004:1.996;
omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {omission_event};
adaptor_event = struct();
adaptor_event.("event_time") = -0.15;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.3;
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.45;
event_lines{end+1} = adaptor_event;
adaptor_event.("event_time") = -0.6;
event_lines{end+1} = adaptor_event;

for tfr_algo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
        f.run_STCP_TFRMAP_dependent(f,output_dir,tfr_algos{tfr_algo_i}, {ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot,event_lines)
    end
end

%% functions

function f = get_funcs_instant(actual_subs,actual_sovs, examp_cond,ft_cond_input_dir,ft_cond_output_dir,time)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,examp_cond);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time,""); 
    timelock = imp.get_cond_timelocked(imp,{curr_sov_subs{1}},examp_cond,actual_sovs{1});
    label = timelock{1}.label;
    electrodes = timelock{1}.elec;
    imp.set_neighbours(imp,electrodes);
    
    f = funcs_(imp, label,electrodes,time);
end

function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline,color)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
    expStruct.color = color;
end

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
