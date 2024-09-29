
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false, [1, 0, 1]);
N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
N3 = defineExpStruct("N3", "N3", "N3", false,[0, 1, 0]);
REM = defineExpStruct("REM", "REM", "REM", false,[1, 0, 0]);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0, 1]);


% [-2, 1.996]
ExOm = defineExpStruct("expomit", "ExOm", "Expected Omission", false, [0, 0, 0]);
UnexOm = defineExpStruct("unexpomit", "UnexOm", "Unexpected Omission", false, [0, 0, 0]);


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
addpath(sprintf('%s\\fieldtrip-20230223', libs_dir))
ft_defaults
addpath(sprintf('%s\\eeglab2023.0', libs_dir))
close;
addpath(libs_dir)
addpath(genpath('C:\Users\User\OneDrive\Documents\githubProjects'))

%% elec clusters
%channels_selection =  {'Cz','E31','E80','E55','E7','E106'};%mid-cent%{'E46','E47','E52','E53','E37'}; % left-posterior %{'Cz'};%{'E46','E47','52','53','37'}, 


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

% frontal
frontal_cluster = struct();
frontal_cluster.('short_s') = 'frontElec';
frontal_cluster.('long_s') = '5 front elect';
frontal_cluster.('elect_label') =  {'Fz','FPz','F3','F4','FCz'};
clusts_struct.('frontal5') = frontal_cluster;

% % % wn: intblk vs AO
% clust_wn_intblk_AO_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% clust_wn_intblk_AO = f.get_electdClust(f,'simple_contrast',clust_wn_intblk_AO_res_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
% clusts_struct.('clust_wn_intblk_AO_pos1') = clust_wn_intblk_AO.pos_1; 
% clusts_struct.('clust_wn_intblk_AO_neg1') = clust_wn_intblk_AO.neg_1; 

%% STCP: ExOm vs. UnexOm
ExpUnexpOm_output_dir = sprintf("%s\\ExpUnexpOm_res_blPreO",output_main_dir);
time = -2:0.004:1.996;
sovs = {Wnig,N2,N3,N1,REM}; 
conds = {ExOm,UnexOm};

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
cfg.test_latency = [0,1];
cfg.plot_latency= [-1,1];
maxPval = 0.05;
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.ylim_ = [-5,4];

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


%% TFR
output_dir = sprintf("%s\\ExpUnexpOm_res",output_main_dir); mkdir(output_dir); %
sovs = {Wnig,N1,N2,N3,REM}; 
time = -2:0.004:1.996;

timerange_test = [0,1];
freqrange_test =  {[1.5,4],[4,8],[8,13],[15,30],[30,70]};
timerange_plot = [-1,2];
is_bl_in_band = false;

for sov_i=1:numel(sovs)
    for freq_i=1:numel(freqrange_test)
        f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
        f.run_STCP_TFR_dependent(f,output_dir, {ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot,is_bl_in_band,'multitaper_zscored')
    end
end

%%
output_dir = sprintf("%s\\ExpUnexpOm_res",output_main_dir); mkdir(output_dir); %
sovs = {Wnig,N1,N2,N3,REM}; % 
time = -2:0.004:1.996;

timerange_test = [0,0.6];
freqrange_test =  [0.5,70];
timerange_plot = [-1,1];
is_plot_topoplot = true;

for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, ExOm,ft_cond_input_dir,ft_cond_output_dir,time);
    f.run_STCP_TFRMAP_dependent(f,output_dir,'multitaper_zscored', {ExOm,UnexOm},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot)
end

%% functions

function run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,electd_clust,output_dir,cfg)   
    for conds_i=1:numel(conds)
        sovs_pairs = uniquePairs(sovs);
        for sp_i = 1:numel(sovs_pairs) 
            cur_contrast_sovs = {sovs_pairs{sp_i}{1},sovs_pairs{sp_i}{2}};
            curr_contrast_conds = {conds{conds_i},conds{conds_i}};

            f.run_STCP_ERP_dependent(f,output_dir, curr_contrast_conds,cur_contrast_sovs, ...
                cfg.test_latency,cfg.test_latency, cfg.is_plot_topoplot,cfg.is_plot_video);
            
            f.plot_erp_per_contrast_and_sov(f,output_dir,curr_contrast_conds,cur_contrast_sovs,electd_clust)
        end
    end
end

function plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,electd_clust, output_dir,cfg)
    for cont_i=1:numel(contrasts)
        if contrasts{cont_i}{1}.isBaseline || contrasts{cont_i}{2}.isBaseline
            if contrasts{cont_i}{1}.isBaseline
                non_baselise_cond = 2;
            else 
                non_baselise_cond = 1;
            end

            cfg.withinSov_contrast_forSigLine = contrasts{cont_i};
            cfg.betweenSov_cond_forSigLine = contrasts{cont_i}{non_baselise_cond};
            f.plot_erp_per_cond_across_sovs(f,output_dir,contrasts{cont_i}{non_baselise_cond},sovs,electd_clust, cfg);
        end
    end
end


function f = get_funcs_instant(actual_subs,actual_sovs, examp_cond,ft_cond_input_dir,ft_cond_output_dir,time)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,examp_cond);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time,""); 
    timelock = imp.get_cond_timelocked(imp,{curr_sov_subs{1}},examp_cond,actual_sovs{1});
    label = timelock{1}.label;
    electrodes = timelock{1}.elec;
    imp.set_neighbours(imp,electrodes);
    
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
