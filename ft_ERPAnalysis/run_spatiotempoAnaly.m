
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false);
N2 = defineExpStruct("N2", "N2", "N2", false);
N3 = defineExpStruct("N3", "N3", "N3", false);
REM = defineExpStruct("REM", "REM", "REM", false);
tREM = defineExpStruct("tREM", "tREM", "tREM", false);
pREM = defineExpStruct("pREM", "pREM", "pREM", false);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false);
Wmor = defineExpStruct("wake_morning", "wm", "Wake Post", false);
Wake = defineExpStruct("wake", "wake", "Wake Pre+Post", false);

% [-0.1, 1.16]
AOmi = defineExpStruct("AO", "AO", "Omission", false);
AOmiR = defineExpStruct("AOR", "AOR", "Unpredictable Omission", false);
AOmiF = defineExpStruct("AOF", "AOF", "Predictable Omission", false);
AblOmi = defineExpStruct("AblO", "AblO", "Omission", false);
intblksmpAO = defineExpStruct("intblksmpAO", "intblksmpAO", "Baseline", true);
intblksmpAblO = defineExpStruct("intblksmpAblO", "intblksmpAblO", "Baseline", true);
intblksmpAOR = defineExpStruct("intblksmpAOR", "intblksmpAOR", "Baseline", true);
intblksmpAOF = defineExpStruct("intblksmpAOF", "intblksmpAOF", "Baseline", true);

noN2EventsAO = defineExpStruct("noN2EventsAO", "noN2EventsAO", "Omission w/o ss&kc", false);
noN2EventsAOF = defineExpStruct("noN2EventsAOF", "noN2EventsAOF", "Omission fixed w/o ss&kc", false);
noN2EventsAOR = defineExpStruct("noN2EventsAOR", "noN2EventsAOR", "Omission random w/o ss&kc", false);
noN2KcompAO = defineExpStruct("noN2KcompAO", "noN2KcompAO", "Omission w/o kc", false);
noN2KcompAOF = defineExpStruct("noN2KcompAOF", "noN2KcompAOF", "Predictable Omission w/o kc", false);
noN2KcompAOR = defineExpStruct("noN2KcompAOR", "noN2KcompAOR", "Unpredictable Omission w/o kc", false);
noN2SsAO = defineExpStruct("noN2SsAO", "noN2SsAO", "Omission w/o ss", false);

% [-1.6, 2.66]
AOmiftr = defineExpStruct("AOtfr", "AOtfr", "Omission", false);
AOmiRtfr = defineExpStruct("AOFtfr", "AOFtfr", "Unpredictable Omission", false);
AOmiFtfr = defineExpStruct("AORtfr", "AORtfr", "Predictable Omission", false);
intblksmpAOtfr = defineExpStruct("intblksmpAOtfr", "intblksmpAOtfr", "Baseline", true);

% [-1.5, 2.5] (note! They are opposite - T5thTfr is T1stTfr and vice versa)
T5thTfr = defineExpStruct("T5thTfr", "T5thTfr", "1st trial tone", false);
T1stTfr = defineExpStruct("T1stTfr", "T1stTfr", "5th trial tone", false);


% [-0.1, 6]
lastAOF = defineExpStruct("lastAOF", "lastAOF", "Last A OF", false);
lastAT = defineExpStruct("lastAT", "lastAT", "Last A T", false);
lastAOFnoN2Events  = defineExpStruct("LastAOFNoN2Events", "LastAOFNoN2Events", "Last A OF w/o ss&kc", false);
lastATnoN2Events = defineExpStruct("LastATNoN2Events", "LastATNoN2Events", "Last A T w/o ss&kc", false);


% % [-12, 6]
% OmiR618 = struct(); OmiR618.import_s = "OR618"; OmiR618.short_s = "OR618"; OmiR618.long_s = "Omission Random, 6th";
% OmiR718 = struct(); OmiR718.import_s = "OR718"; OmiR718.short_s = "OR718"; OmiR718.long_s = "Omission Random, 7th";
% OmiR818 = struct(); OmiR818.import_s = "OR818"; OmiR818.short_s = "OR818"; OmiR818.lo ng_s = "Omission Random, 8th";
% OmiR918 = struct(); OmiR918.import_s = "OR918"; OmiR918.short_s = "OR918"; OmiR918.long_s = "Omission Random, 9th";
% OmiF18 = struct(); OmiF18.import_s = "OF18"; OmiF18.short_s = "OF18"; OmiF18.long_s = "Omission Fixed";
% LastOmiF18 = struct(); LastOmiF18.import_s = "LastOF18"; LastOmiF18.short_s = "LastOF18"; LastOmiF18.long_s = "Last Omission Fixed";
% LastOmiR18 = struct(); LastOmiR18.import_s = "LastOR18"; LastOmiR18.short_s = "LastOR18"; LastOmiR18.long_s = "Last Omission Random";
% 
% %[0,5]
% intbk5 = struct(); intbk5.import_s = "intbk5"; intbk5.short_s = "intbk5"; intbk5.long_s = "Interblock";
% 
% %[-0.2,2]
% intbk2 = struct(); intbk2.import_s = "intbk2"; intbk2.short_s = "intbk2"; intbk2.long_s = "Interblock";
% intbkLast2 = struct(); intbkLast2.import_s = "interblockLast2sec"; intbkLast2.short_s = "intbkLast2"; intbkLast2.long_s = "Interblock end";
% LastOR2 = struct(); LastOR2.import_s = "LastOR2sec"; LastOR2.short_s = "LastOR2"; LastOR2.long_s = "Last Omission Random";
% LastOF2 = struct(); LastOF2.import_s = "LastOF2sec"; LastOF2.short_s = "LastOF2"; LastOF2.long_s = "Last Omission Fixed";
% 
% LastOmiR = struct(); LastOmiR.import_s = "LastOR"; LastOmiR.short_s = "LastOR"; LastOmiR.long_s = "Omission Random";
% LastOmiF = struct(); LastOmiF.import_s = "LastOF"; LastOmiF.short_s = "LastOF"; LastOmiF.long_s = "Omission Fixed";
% 

%%%%%%%%
output_main_dir = "D:\OExpOut\spatioTemp";
ft_cond_input_dir = "D:\OExpOut\processed_data\ft_subSovCond";
ft_cond_output_dir = "D:\OExpOut\processed_data\ft_processed";
libs_dir = 'D:\matlab_libs';

%%%%%%

subs = {'08','09','10','11','13','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; 

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

time = -0.1:0.004:5.996;
f = get_funcs_instant(subs,{N2}, AOmi,ft_cond_input_dir,ft_cond_output_dir,time);
arbitrary_cond = f.imp.get_cond_timelocked(f.imp,AOmi,N2);
arbitrary_cond_elec = arbitrary_cond{1}.elec;

clusts_struct = struct();
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;

% central
% central_cluster = struct();
% central_cluster.('short_s') = 'centElec';
% central_cluster.('long_s') = '6 central elect';
% central_cluster.('elect_label') =  {'Cz','E31','E80','E55','E7','E106'};
% [isMember, indices] = ismember(central_cluster.('elect_label') , clusts_struct.('elec_gen_info').('label'));
% central_cluster.('elect') =  indices(isMember);
% clusts_struct.('central6') = central_cluster;

% wn: intblk vs AO
% clust_wn_intblk_AO_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% clust_wn_intblk_AO = f.get_electdClust(f,'simple_contrast',clust_wn_intblk_AO_res_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
% clusts_struct.('clust_wn_intblk_AO_pos1') = clust_wn_intblk_AO.pos_1; 
% clusts_struct.('clust_wn_intblk_AO_neg1') = clust_wn_intblk_AO.neg_1; 

% wn: OF vs OR
clust_wn_AOF_AOR_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
clust_wn_AOF_AOR = f.get_electdClust(f,'simple_contrast',clust_wn_AOF_AOR_res_dir,{AOmiF,AOmiR},{Wnig,Wnig},0.1);
clusts_struct.('clust_wn_AOF_AOR_pos1') = clust_wn_AOF_AOR.pos_1; 

%% RUN all conds for Anat Japanika
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

AdaptorOmission_output_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
sovs = {Wnig,N2,N3,REM}; % 
conds = {AOmi,AOmiF,AOmiR};
time = -0.1:0.004:1.1596;
f = get_funcs_instant(subs,sovs, conds{1},ft_cond_input_dir,ft_cond_output_dir,time);


adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
cfg.plot_bp_filter = [0.1,20];
maxPval = 0.05;

%%% Contrast
% curr_cont_elec =  "curr_sov_cont_clustersElect";
% run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,output_dir,cfg)
% 
% AdaptorOmission_output_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig});
% f.plot_erp_per_contrast_and_sov(f,output_dir,{AOmi,AOmi},{N3,N3},curr_electd_clust, cfg);

% %%% Per cond
output_dir = sprintf("%s\\furanat\\singleERP_O,OR,OF_elec-eachSovClust",output_main_dir); mkdir(output_dir);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
for cond_i=1:numel(conds)
    f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{Wnig},curr_electd_clust, cfg)
end
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{N2,N2},0.05);
for cond_i=1:numel(conds)
    f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{N2},curr_electd_clust, cfg)
end
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{REM,REM},0.05);
for cond_i=1:numel(conds)
    f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{REM},curr_electd_clust, cfg)
end
%%
output_dir = sprintf("%s\\furanat\\ERP-contrast\\OF vs OR vs Baseline",output_main_dir); mkdir(output_dir);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,Wnig}, {AOmiF,Wnig},{AOmiR,Wnig}},curr_electd_clust,"intbOFOR-wn" , cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N3}, {AOmiF,N3},{AOmiR,N3}},curr_electd_clust,"intbOFOR-N3" ,cfg);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{N2,N2},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmiF,N2},{AOmiR,N2}},curr_electd_clust,"intbOFOR-N2" , cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {noN2EventsAOF,N2},{noN2EventsAOR,N2}},curr_electd_clust,"intbOFOR-N2NoEvents" ,cfg);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{REM,REM},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,REM}, {AOmiF,REM},{AOmiR,REM}},curr_electd_clust,"intbOFOR-REM" ,cfg);
%%
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',sprintf("%s\\furanat\\N2_noSSKC",output_main_dir),{intblksmpAblO,AblOmi},{N2,N2},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {noN2EventsAOF,N2},{noN2EventsAOR,N2}},curr_electd_clust,"intbOFOR-N2NoEvents-ClusterAblOmi" , cfg);
%
output_dir = sprintf("%s\\furanat\\singleERP_O,OR,OF_elec-wnCluster",output_main_dir); mkdir(output_dir);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
        f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},sovs{sov_i},curr_electd_clust, cfg)
    end
end

% %%% N2 stuff 
output_dir = sprintf("%s\\furanat\\N2_noSSKC",output_main_dir); mkdir(output_dir);
curr_electd_clust = "curr_sov_cont_clustersElect";
run_withinSov_betweenCond_stcp_analysis(f, {N2}, {{intblksmpAblO,AblOmi}},curr_electd_clust,output_dir,maxPval,cfg)

curr_electd_clust =  f.get_electdClust(f,'simple_contrast',output_dir,{intblksmpAblO,AblOmi},{N2,N2},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2},{noN2KcompAO,N2},{noN2EventsAO,N2}},curr_electd_clust,"BlWAndWOAllEveTypes" , cfg);

curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{N2,N2},maxPval);
run_withinSov_betweenCond_stcp_analysis(f, {N2}, {{intblksmpAblO,AblOmi}},curr_electd_clust,output_dir,maxPval,cfg)
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2},{noN2KcompAO,N2},{noN2EventsAO,N2}},curr_electd_clust,"BlWAndWOAllEveTypes" ,cfg);
 
%%% contrasts
output_dir = sprintf("%s\\furanat\\REM",output_main_dir); mkdir(output_dir);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAblO,AblOmi},{REM,REM},maxPval);
run_withinSov_betweenCond_stcp_analysis(f, {REM}, {{intblksmpAblO,AblOmi}},curr_electd_clust,output_dir,maxPval,cfg)

sovs = {tREM,pREM}; % 
conds = {AblOmi};
time = -0.1:0.004:1.1596;
f = get_funcs_instant(subs,sovs, conds{1},ft_cond_input_dir,ft_cond_output_dir,time);
curr_cont_elec =  "curr_sov_cont_clustersElect";
run_withinSov_betweenCond_stcp_analysis(f, {tREM,pREM}, {{intblksmpAblO,AblOmi}},curr_cont_elec,output_dir,maxPval,cfg)

curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{REM,REM},maxPval);
run_withinSov_betweenCond_stcp_analysis(f, {tREM,pREM}, {{intblksmpAblO,AblOmi}},curr_electd_clust,output_dir,maxPval,cfg)

%% RUN {lastAOF,lastAT} & tfr 
output_dir = sprintf("%s\\EndOfBlock",output_main_dir); mkdir(output_dir);
sovs = {Wake,N2,REM};
contrasts = {{lastAT,lastAOF}};
time = -0.1:0.004:5.996;
f = get_funcs_instant(subs,sovs, contrasts{1}{1},ft_cond_input_dir,ft_cond_output_dir,time);

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'A';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'T / O';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,3];
cfg.plot_latency= [-0.1,4];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;

%%% 
% curr_cont_elec =  "curr_sov_cont_clustersElect";
curr_cont_elec = clusts_struct;

run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,output_dir,0.05,cfg)

conds = {lastAT,lastAOF};
for sov_i=1:numel(sovs)
    for cond_i=1:numel(conds)
        f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct, cfg)
    end
end

% timerange_plot =[-0.1,5.996];
% timerange_test =[0.58,4];
% freqrange_test =  [0.5,30];
% is_plot_topoplot = true;
% tfr_algo = 'multitaper';
% for cond_i=1:numel(contrasts)
%     for sov_i=1:numel(sovs)
%         f.run_STCP_TFRMAP_dependent(f,output_dir,tfr_algo, contrasts{cond_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot, is_plot_topoplot)
%     end
% end

sovs = {N2};
contrasts = {{lastATnoN2Events,lastAOFnoN2Events}};
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,output_dir,0.05,cfg)

%% RUN  (AO,AOF,AOR vs Aintbk) & (AOF vs. AOR) with a specific range [-0.1,1.16]
adaptor_omission_dir = sprintf("%s\\AdaptorOmission",output_main_dir); mkdir(adaptor_omission_dir);
sovs = {Wnig,N2,N3,REM,tREM,pREM};
contrasts = {{intblksmpAO,AOmi}, {AOmiF,AOmiR}};
conds = {AOmi,AOmiF,AOmiR};
time = -0.1:0.004:1.156;
f = get_funcs_instant(subs,sovs, conds{1},ft_cond_input_dir,ft_cond_output_dir,time);

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.plot_bp_filter = [0.1,20];
maxPval = 0.05;



% curr_cont_elec =  "curr_sov_cont_clustersElect";
% run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,output_dir,maxPval,cfg)
% 
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
% f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO,AOmi},{N3,N3},curr_electd_clust,cfg);

output_dir = sprintf("%s\\furanat\\ERP-contrast\\OF vs OR",output_main_dir); mkdir(output_dir);
best_cluster_cont = {AOmiF,AOmiR};
best_cluster_contSovs = {Wnig,Wnig};
elcdClust_bestCluster =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,best_cluster_cont,best_cluster_contSovs,0.1);
% union_intersect_sovs = {Wnig,N2,N3,REM};
% elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',adaptor_omission_dir,best_cluster_cont,union_intersect_sovs,maxPval);
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,elcdClust_bestCluster,output_dir,maxPval,cfg)

output_dir = sprintf("%s\\furanat\\ERP-contrast\\O vs Baseline",output_main_dir); mkdir(output_dir);
plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,elcdClust_bestCluster, output_dir,cfg)

% run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,elcdClust_bestCluster,output_dir,cfg)
% for sov_i=1:numel(sovs)
%     for cond_i=1:numel(conds)
%         f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},sovs{sov_i},elcdClust_bestCluster, cfg)
%     end
% end

%% RUN TFR Cluster-permu 
output_dir = sprintf("%s\\TFR_topo\\zscored",output_main_dir); mkdir(output_dir); %
sovs = {Wnig,REM,N3,N2};
contrasts = {{AOmiFtfr,AOmiRtfr}};
time = -1.6:0.004:2.66;
f = get_funcs_instant(subs,sovs, AOmi,ft_cond_input_dir,ft_cond_output_dir,time);
timerange_test = [0.58,1.16];
freqrange_test =  {[1.5,4],[4,8],[8,13],[15,30],[30,70]};
timerange_plot = [-0.1 1.16];
is_bl_in_band = false;

tfr_algos = {'multitaper_zscored'}; % 'hilbert', 'multitaper', 'multitaper_zscored'
for trfalgo_i=1:numel(tfr_algos)
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(contrasts)
            for freq_i=1:numel(freqrange_test)
                f.run_STCP_TFR_dependent(f,output_dir, contrasts{cond_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot,is_bl_in_band,tfr_algos{trfalgo_i})
            end
        end
    end
end


%%  RUN TFRMAP Cluster-permu  {T1stTfr, T5thTfr}

output_dir = sprintf("%s\\test",output_main_dir); mkdir(output_dir);
sovs = {Wnig}; % ,N2,N3,REM}
contrasts = {{T1stTfr, T5thTfr}};

time = -1.5:0.004:2.5;
f = get_funcs_instant(subs,sovs, contrasts{1}{1},ft_cond_input_dir,ft_cond_output_dir,time);
timerange_plot = [-1.5,2.5];
timerange_test = [0, 1.16];
freqrange_test =  [0.5,30];
is_plot_topoplot = true;

tfr_algos = {'multitaper'}; % ,'hilbert'

for tfr_algo_i=1:numel(tfr_algos)
    tfr_algo = tfr_algos{tfr_algo_i};
    for cond_i=1:numel(contrasts)
        for sov_i=1:numel(sovs)
            f.run_STCP_TFRMAP_dependent(f,output_dir,tfr_algo, contrasts{cond_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot)
        end
    end
end

%% RUN TFRMAP Cluster-permu 
contrasts = {{AOmiFtfr,AOmiRtfr}}; % {intblksmpAOtfr,AOmiftr}

output_dir = sprintf("%s\\TFR\\zscored",output_main_dir); mkdir(output_dir);
sovs = {Wnig,N2,N3,REM};
time = -1.6:0.004:2.66;
f = get_funcs_instant(subs,sovs, contrasts{1}{1},ft_cond_input_dir,ft_cond_output_dir,time);
timerange_test = [0.58,1.16];
timerange_plot = [-0.1 1.6];
freqrange_test =  [0.5,70];
clusts_struct = clusts_struct;

tfr_algos = {'multitaper_zscored'}; % 'hilbert', 'multitaper', 'multitaper_zscored'
for tfr_algo_i=1:numel(tfr_algos)
    tfr_algo = tfr_algos{tfr_algo_i};
    for cond_i=1:numel(contrasts)
        for sov_i=1:numel(sovs)
            f.run_STCP_TFRMAP_dependent(f,output_dir,tfr_algo, contrasts{cond_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test,clusts_struct,timerange_plot)
        end
    end
end


%%
output_dir = sprintf("%s\\test",output_main_dir); mkdir(output_dir);
sovs = {Wnig,N2,N3,REM};
contrasts = {{intblksmpAO,AOmi}, {AOmiF,AOmiR}};
conds = {AOmi,AOmiF,AOmiR};
f = get_funcs_instant(subs,sovs, conds{1},ft_cond_input_dir,ft_cond_output_dir);

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;

curr_cont_elec =  "curr_sov_cont_clustersElect";
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,output_dir,cfg)

best_cluster_cont = {AOmiF,AOmiR};
best_cluster_contSovs = {Wnig,Wnig};
elcdClust_bestCluster =  f.get_electdClust(f,'simple_contrast',output_dir,best_cluster_cont,best_cluster_contSovs);
% elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);

run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,elcdClust_bestCluster,output_dir,cfg)
plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,elcdClust_bestCluster, output_dir,cfg)
run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,elcdClust_bestCluster,output_dir,cfg)
plot_erp_withinSovCond_allSubs(f, sovs, conds, elcdClust_bestCluster, output_dir,cfg)

%%
sovs = {N2};
cluster_dir = sprintf("%s\\Omission058_AblLocked",output_main_dir);
output_dir = sprintf("%s\\N2_without",output_main_dir); mkdir(output_dir);
cfg = {};
cfg.test_latency =  [0,0.58];
cfg.plot_latency= [-0.1,0.58];
omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
cfg.event_lines = {omission_event};

f = get_funcs_instant(subs,sovs, intblksmpAblO,ft_cond_input_dir,ft_cond_output_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{intblksmpAblO,AblOmi},{N2,N2});
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAblO, noN2EventsAblOmi},{N2,N2},electd_clust ,cfg);
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAblO, AblOmi},{N2,N2},electd_clust ,cfg);

run_withinSov_betweenCond_stcp_analysis(f, sovs, {{intblksmpAblO, noN2EventsAblOmi}},'curr_sov_cont_clustersElect',output_dir,cfg)



%%
sovs = {N2};
output_dir = sprintf("%s\\N2_without",output_main_dir); mkdir(output_dir);

cfg = {};
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
cfg.event_lines = {adaptor_event,omission_event};

cluster_dir = sprintf("%s\\Omission058_AblLocked",output_main_dir);
f = get_funcs_instant(subs,sovs, intblksmpAO,ft_cond_input_dir,ft_cond_output_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{intblksmpAblO,AblOmi},{N2,N2});


f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO, noN2EventsAO},{N2,N2},electd_clust ,cfg);
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO, AOmi},{N2,N2},electd_clust ,cfg);
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{intblksmpAO, noN2EventsAO}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{intblksmpAO, AOmi}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{noN2EventsAO, AOmi}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{noN2EventsAOF, noN2EventsAOR}},'curr_sov_cont_clustersElect',output_dir,cfg)

cluster_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{AOmiF,AOmiR},{Wnig,Wnig});
f.plot_erp_per_contrast_and_sov(f,output_dir,{noN2EventsAOF, noN2EventsAOR},{N2,N2},electd_clust ,cfg);

% 
% noN2EventsAO = defineExpStruct("noN2EventsAO", "noN2EventsAO", "Omission without ss&kc", false);
% noN2KcompAO = defineExpStruct("noN2KcompAO", "noN2KcompAO", "Omission without kc", false);
% noN2SsAO = defineExpStruct("noNSspAO", "noNoSsAO", "Omission without ss", false);

%%
sovs = {N2};
output_dir = sprintf("%s\\N2_without",output_main_dir); mkdir(output_dir);
f = get_funcs_instant(subs,sovs, intblksmpAO,ft_cond_input_dir,ft_cond_output_dir);

cfg = {};
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Tone';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
cfg.event_lines = {adaptor_event,omission_event};

cluster_dir = sprintf("%s\\Omission058_AblLocked",output_main_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{intblksmpAblO,AblOmi},{N2,N2});
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2KcompAO,N2}},electd_clust,"BlNokc" , cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2}},electd_clust,"BlNoss" ,cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2EventsAO,N2}},electd_clust,"BlNoeve" , cfg);

f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2},{noN2KcompAO,N2},{noN2EventsAO,N2}},electd_clust,"BlWAndWOAllEveTypes" , cfg);
%% functions

function run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,electd_clust,output_dir,maxPval,cfg)
    for sov_i = 1:numel(sovs) 
        cur_contrast_sovs = {sovs{sov_i},sovs{sov_i}};    
        for cont_i=1:numel(contrasts)
            f.run_STCP_ERP_dependent(f,output_dir, contrasts{cont_i},cur_contrast_sovs, cfg)
            
            if (ischar(electd_clust) || isstring(electd_clust)) && strcmp(electd_clust, "curr_sov_cont_clustersElect")
                curr_electd_clust = f.get_electdClust(f,'simple_contrast',output_dir,contrasts{cont_i},cur_contrast_sovs,maxPval);
            else
                curr_electd_clust = electd_clust;
            end

            f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},cur_contrast_sovs,curr_electd_clust, cfg);
        end
    end
end

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
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir,time); 
    timelock = imp.get_cond_timelocked(imp,examp_cond,actual_sovs{1});
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

function expStruct = defineExpStruct(import_s, short_s, long_s, isBaseline)
    expStruct = struct();
    expStruct.import_s = import_s;
    expStruct.short_s = short_s;
    expStruct.long_s = long_s;
    expStruct.isBaseline = isBaseline;
end

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,cond)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        if strcmp(sovs{sov_i}.import_s, 'wake_night')
%             if strcmp(cond.import_s,'lastAblOF')
%                 curr_sov_subs(ismember(curr_sov_subs, { '29','32'})) = [];
%             end
        elseif strcmp(sovs{sov_i}.import_s, 'N1')
        elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
            curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
        elseif strcmp(sovs{sov_i}.import_s, 'N2')
        elseif strcmp(sovs{sov_i}.import_s, 'N3')
            if strcmp(cond.import_s,'lastAT')
                curr_sov_subs(ismember(curr_sov_subs, { '15'})) = [];
            end
        elseif strcmp(sovs{sov_i}.import_s, "tREM")
            curr_sov_subs(ismember(curr_sov_subs, {'36'})) = [];
        elseif strcmp(sovs{sov_i}.import_s, "REM")
%             if strcmp(cond.import_s,'lastAblOF')
%                 curr_sov_subs(ismember(curr_sov_subs, { '09'})) = [];
%             end
        end
    end
end
