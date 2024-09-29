clear
close all
%%
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false, [1, 0, 1]);
N2 = defineExpStruct("N2", "N2", "N2", false,[1, 0.6, 0]);
N2wo = defineExpStruct("N2wo", "N2wo", "N2 w/o events", false,[0.7, 0.6, 0]);
N2woSs = defineExpStruct("N2woSs", "N2woSs", "N2 w/o spindles", false,[0.8, 0.6, 0]);
N2woKc = defineExpStruct("N2woKc", "N2woKc", "N2 w/o k-complex", false,[0.9, 0.6, 0]);
N3 = defineExpStruct("N3", "N3", "N3", false,[0, 1, 0]);
REM = defineExpStruct("REM", "REM", "REM", false,[1, 0, 0]);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false,[0, 0, 1]);
tREM = defineExpStruct("tREM", "tREM", "tREM", false,[1, 0, 0]);
pREM = defineExpStruct("pREM", "pREM", "pREM", false,[1, 0, 0]);
% Wmor = defineExpStruct("wake_morning", "wm", "Wake Post", false); 
% Wake = defineExpStruct("wake", "WAll", "Wake Pre+Post", false); % Short must be WAll for ft_importer

% [-0.1, 1.16]
NblAOmi = defineExpStruct("NblAO", "NblAO", "Omission", false, [0, 0, 0]);
NblAOmiR = defineExpStruct("NblAOR", "NblAOR", "Unpredictable Omission", false, [0, 0, 0]);
NblAOmiF = defineExpStruct("NblAOF", "NblAOF", "Predictable Omission", false, [0, 0, 0]);
intblksmpNblAO = defineExpStruct("intblksmpNblAO", "intblksmpNblAO", "Baseline", true, [0, 0, 0]);
intblksmpNblAOR = defineExpStruct("intblksmpNblAOR", "intblksmpNblAOR", "Baseline", true, [0, 0, 0]);
intblksmpNblAOF = defineExpStruct("intblksmpNblAOF", "intblksmpNblAOF", "Baseline", true, [0, 0, 0]);
AOmi = defineExpStruct("AO", "AO", "Omission", false, [0, 0, 0]);
AOmiR = defineExpStruct("AOR", "AOR", "Unpredictable Omission", false, [0, 0, 0]);
AOmiF = defineExpStruct("AOF", "AOF", "Predictable Omission", false, [0, 0, 0]);
AT1 = defineExpStruct("AT1", "AT1", "1st tone", false, [0, 0, 0]);
AT5 = defineExpStruct("AT5", "AT5", "5th tone", false, [0, 0, 0]);
AT8 = defineExpStruct("AT8", "AT8", "8th tone", false, [0, 0, 0]);
ATR10 = defineExpStruct("ATR10", "ATR10", "10th tone, random block", false, [0, 0, 0]);

AblOmi = defineExpStruct("AblO", "AblO", "Omission", false, [0, 0, 0]);
intblksmpAO = defineExpStruct("intblksmpAO", "intblksmpAO", "Baseline", true, [0, 0, 0]);
intblksmpAblO = defineExpStruct("intblksmpAblO", "intblksmpAblO", "Baseline", true, [0, 0, 0]);
intblksmpAOR = defineExpStruct("intblksmpAOR", "intblksmpAOR", "Baseline", true, [0, 0, 0]);
intblksmpAOF = defineExpStruct("intblksmpAOF", "intblksmpAOF", "Baseline", true, [0, 0, 0]);

% [-1.6, 2.66]
AOmiftr = defineExpStruct("AOtfr", "AOtfr", "Omission", false, [0, 0, 0]);
AOmiRtfr = defineExpStruct("AOFtfr", "AOFtfr", "Unpredictable Omission", false, [0, 0, 0]);
AOmiFtfr = defineExpStruct("AORtfr", "AORtfr", "Predictable Omission", false, [0, 0, 0]);
intblksmpAOtfr = defineExpStruct("intblksmpAOtfr", "intblksmpAOtfr", "Baseline", true, [0, 0, 0]);

% [-1.5, 2.5] (note! They are opposite - T5thTfr is T1stTfr and vice versa)
T5thTfr = defineExpStruct("T5thTfr", "T5thTfr", "1st trial tone", false, [0, 0, 0]);
T1stTfr = defineExpStruct("T1stTfr", "T1stTfr", "5th trial tone", false, [0, 0, 0]);

% [-0.1, 6]
lastAOF = defineExpStruct("lastAOF", "lastAOF", "Last A OF", false, [0, 0, 0]);
lastAT = defineExpStruct("lastAT", "lastAT", "Last A T", false, [0, 0, 0]);
lastAOFnoN2Events  = defineExpStruct("LastAOFNoN2Events", "LastAOFNoN2Events", "Last A OF w/o ss&kc", false, [0, 0, 0]);
lastATnoN2Events = defineExpStruct("LastATNoN2Events", "LastATNoN2Events", "Last A T w/o ss&kc", false, [0, 0, 0]);

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

time = -0.1:0.004:1.596;
f = get_funcs_instant(subs,{Wnig}, {AOmi},ft_cond_input_dir,ft_cond_output_dir,time);
arbitrary_cond = f.imp.get_cond_timelocked(f.imp,f.imp.subs,AOmi,Wnig);
arbitrary_cond_elec = arbitrary_cond{1}.elec;

clusts_struct = struct();
clusts_struct.('elec_gen_info') = arbitrary_cond_elec;

% central
central_cluster = struct();
central_cluster.('short_s') = 'centElec';
central_cluster.('long_s') = '6 central elect';
central_cluster.('elect_label') =  {'Cz','E31','E80','E55','E7','E106'};
clusts_struct.('central6') = central_cluster;

% % % wn: intblk vs AO
% clust_wn_intblk_AO_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% clust_wn_intblk_AO = f.get_electdClust(f,'simple_contrast',clust_wn_intblk_AO_res_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
% clusts_struct.('clust_wn_intblk_AO_pos1') = clust_wn_intblk_AO.pos_1; 
% clusts_struct.('clust_wn_intblk_AO_neg1') = clust_wn_intblk_AO.neg_1; 

% wn: OF vs OR
% clust_wn_AOF_AOR_res_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
% clust_wn_AOF_AOR = f.get_electdClust(f,'simple_contrast',clust_wn_AOF_AOR_res_dir,{AOmiF,AOmiR},{Wnig,Wnig},0.1);
% clusts_struct.('clust_wn_AOF_AOR_pos1') = clust_wn_AOF_AOR.pos_1; 

% N2, 13-30Hz: OF vs OR
% clust_N2_AOF_AOR_1330HZ_res_dir = sprintf("%s\\TFR_topo\\zscored",output_main_dir);
% electd_clusts=f.get_electdClust_tfrband(f,clust_N2_AOF_AOR_1330HZ_res_dir,{AOmiFtfr,AOmiRtfr},{N2,N2},"15.0-30.0",0.05);
% clusts_struct.('clust_wn_AOF_AOR_pos1') = clust_wn_AOF_AOR.pos_1; 


%% AO_and_NblAO
AO_and_NblAO_output_dir = sprintf("%s\\AO_and_NblAO",output_main_dir);
sovs = {Wnig, N2,N3,REM,N1}; % 
time = -0.1:0.004:1.1596;

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Adaptor';
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
% cfg.plot_bp_filter = [0.1,20];
cfg.ylim_ = [-1.3,2];
maxPval = 0.05;

% contrasts = {{intblksmpNblAO,NblAOmi},{NblAOmiF,NblAOmiR}}; %,{intblksmpNblAOR,NblAOmiR},{intblksmpNblAOF,NblAOmiF}
% for cont_i=1:numel(contrasts)
%     for sov_i=1:numel(sovs)
%         f = get_funcs_instant(subs,{sovs{sov_i}}, contrasts{1}{1},ft_cond_input_dir,ft_cond_output_dir,time);
%         f.run_STCP_ERP_dependent(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}}, cfg)
% 
%         curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,contrasts{cont_i},{Wnig,Wnig},maxPval);
%         f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);
% 
%         curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},maxPval);
%         f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);
%     end
% end

contrasts = {{intblksmpNblAO,NblAOmi},{NblAOmiF,NblAOmiF}}; %,{intblksmpNblAOR,NblAOmiR},{intblksmpNblAOF,NblAOmiF} 
for cont_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        
        f = get_funcs_instant(subs,{sovs{sov_i}}, {contrasts{1}{1}},ft_cond_input_dir,ft_cond_output_dir,time);
        f.run_STCP_ERP_dependent(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}}, cfg)

        maxPval = 0.1;
        curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,contrasts{cont_i},{Wnig,Wnig},maxPval);
        f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);

        maxPval = 0.1;
        curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},maxPval);
        f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);

        maxPval = 0.05;
        curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
        f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},curr_electd_clust, cfg);
    end
end

% n2 all
N2_sovs = {N2,N2woKc,N2woSs,N2wo};
f = get_funcs_instant(subs,N2_sovs, {NblAOmi},ft_cond_input_dir,ft_cond_output_dir,time);
condSovPairs = {{intblksmpAO,N2},{NblAOmi,N2},{NblAOmi,N2woKc},{NblAOmi,N2woSs},{NblAOmi,N2wo}};
maxPval = 0.05;
curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,{intblksmpAO,NblAOmi},{Wnig,Wnig},maxPval);
f.plot_erp_per_condsSovPairs(f,AO_and_NblAO_output_dir,condSovPairs,curr_electd_clust,sprintf("%s'-allN2Sovs",NblAOmi.short_s) ,cfg);
f = get_funcs_instant(subs,{N2,N2wo}, {NblAOmi},ft_cond_input_dir,ft_cond_output_dir,time);
f.run_STCP_ERP_dependent(f,AO_and_NblAO_output_dir,{intblksmpAO,NblAOmi},{N2,N2wo}, cfg)
f.run_STCP_ERP_dependent(f,AO_and_NblAO_output_dir,{NblAOmiF,NblAOmiR},{N2wo,N2wo}, cfg)
f.plot_erp_per_contrast_and_sov(f,AO_and_NblAO_output_dir,{NblAOmiF,NblAOmiR},{N2wo,N2wo},curr_electd_clust, cfg);


%%
at10_vs_of_output_dir = sprintf("%s\\at10_vs_of",output_main_dir);
AO_and_NblAO_output_dir = sprintf("%s\\AO_and_NblAO",output_main_dir);
sovs = {N2,N1,N2wo}; % 
time = -0.1:0.004:1.1596;

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Adaptor';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission/Tone';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.is_plot_subs = false;
cfg.is_plot_ste = true;
% cfg.plot_bp_filter = [0.1,20];
cfg.ylim_ = [-1.3,2];
maxPval = 0.05;

for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, {AOmiF},ft_cond_input_dir,ft_cond_output_dir,time);
    condSovPairs = {{intblksmpAO,sovs{sov_i}},{AOmiF,sovs{sov_i}},{ATR10,sovs{sov_i}}};

    curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,{intblksmpAO,AOmi},{sovs{sov_i},sovs{sov_i}},maxPval);

    f.plot_erp_per_condsSovPairs(f,at10_vs_of_output_dir,condSovPairs,curr_electd_clust,sprintf("%s-ATF10VsOFVsBl",sovs{sov_i}.short_s) ,cfg);
end

condSovPairs = {{intblksmpAO,N2},{AOmiF,N2wo},{ATR10,N2wo}};
curr_electd_clust = f.get_electdClust(f,'simple_contrast',AO_and_NblAO_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
f.plot_erp_per_condsSovPairs(f,at10_vs_of_output_dir,condSovPairs,curr_electd_clust,sprintf("%s-ATF10VsOFVsBl",N2wo.short_s) ,cfg);



%% RUN all conds for Anat Japanika
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%

AdaptorOmission_output_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
sovs = {Wnig,N2,N3,REM,Wake}; % 
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
% cfg.plot_bp_filter = [0.1,20];
cfg.ylim_ = [-1.3,2];
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
time = -0.1:0.004:1.1596;
f = get_funcs_instant(subs,{Wnig}, intblksmpAO,ft_cond_input_dir,ft_cond_output_dir,time);

output_dir = sprintf("%s\\furanat\\ERP-contrast\\OF vs OR vs Baseline",output_main_dir); mkdir(output_dir);
curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{N1,N1},maxPval);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N1}, {AOmiF,N1},{AOmiR,N1}},curr_electd_clust,"intbOFOR-N1" , cfg);
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},0.05);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,Wnig}, {AOmiF,Wnig},{AOmiR,Wnig}},curr_electd_clust,"intbOFOR-wn" , cfg);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,Wmor}, {AOmiF,Wmor},{AOmiR,Wmor}},curr_electd_clust,"intbOFOR-wm" , cfg);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N3}, {AOmiF,N3},{AOmiR,N3}},curr_electd_clust,"intbOFOR-N3" ,cfg);
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{N2,N2},maxPval);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmiF,N2},{AOmiR,N2}},curr_electd_clust,"intbOFOR-N2" , cfg);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {noN2EventsAOF,N2},{noN2EventsAOR,N2}},curr_electd_clust,"intbOFOR-N2NoEvents" ,cfg);
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{REM,REM},maxPval);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,REM}, {AOmiF,REM},{AOmiR,REM}},curr_electd_clust,"intbOFOR-REM" ,cfg);
%%
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',sprintf("%s\\furanat\\N2_noSSKC",output_main_dir),{intblksmpAblO,AblOmi},{N2,N2},maxPval);
% f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {noN2EventsAOF,N2},{noN2EventsAOR,N2}},curr_electd_clust,"intbOFOR-N2NoEvents-ClusterAblOmi" , cfg);
% %
% output_dir = sprintf("%s\\furanat\\singleERP_O,OR,OF_elec-wnCluster",output_main_dir); mkdir(output_dir);
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',AdaptorOmission_output_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
% for sov_i=1:numel(sovs)
%     for cond_i=1:numel(conds)
%         f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},sovs{sov_i},curr_electd_clust, cfg)
%     end
% end

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
sovs = {N2,REM,Wnig,N3};
contrasts = {{lastAT,lastAOF}};
time = -0.1:0.004:5.996;
f = get_funcs_instant(subs,sovs, AOmi,lastAT,ft_cond_output_dir,time);

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

% conds = {lastAT,lastAOF};
% for sov_i=1:numel(sovs)
%     f = get_funcs_instant(subs,{sovs{sov_i}}, contrasts{1}{1},ft_cond_input_dir,ft_cond_output_dir,time);
%     for cond_i=1:numel(conds)
%         f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{sovs{sov_i}},clusts_struct, cfg)
%     end
% end

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

%% RUN  AT1 [-0.1,1.16]
output_dir = sprintf("%s\\AT158_AO",output_main_dir); mkdir(output_dir);
adaptor_omission_dir = sprintf("%s\\AdaptorOmission",output_main_dir); 
sovs = {Wnig,N2,N3,REM,Wmor,Wake,N1};
time = -0.1:0.004:1.156;

adaptor_event = struct();
adaptor_event.("event_time") = 0;
adaptor_event.("event_color") = [.2, .2 ,.2];
adaptor_event.("event_text") = 'Adaptor';
omission_event = struct();
omission_event.("event_time") = 0.6;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Tone/Omission';
event_lines = {adaptor_event,omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency = [0.58,1.16];
cfg.plot_latency= [-0.1,1.16];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;
cfg.ylim_ = [-3,3];
% cfg.plot_bp_filter = [0.1,20];

for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, AOmi,ft_cond_input_dir,ft_cond_output_dir,time);
    elcdClust =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,{intblksmpAO,AOmi},{sovs{sov_i},sovs{sov_i}},0.05);
    f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,sovs{sov_i}},{AOmi,sovs{sov_i}},{AT1,sovs{sov_i}},{AT5,sovs{sov_i}},{AT8,sovs{sov_i}}}, ...
        elcdClust,sprintf("AOT158-%s",sovs{sov_i}.short_s), cfg);
end

sovs = {N2};
for sov_i=1:numel(sovs)
    f = get_funcs_instant(subs,{sovs{sov_i}}, AOmi,ft_cond_input_dir,ft_cond_output_dir,time);
    elcdClust =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,{intblksmpAO,AOmi},{Wnig, Wnig},0.05);
    f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,sovs{sov_i}},{noN2EventsAO,sovs{sov_i}},{noN2EventsAT1,sovs{sov_i}},{noN2EventsAT8,sovs{sov_i}}}, ...
        elcdClust,sprintf("AOT18-%s",sovs{sov_i}.short_s), cfg);
end


%% RUN  (AO,AOF,AOR vs Aintbk) & (AOF vs. AOR) with a specific range [-0.1,1.16]
adaptor_omission_dir = sprintf("%s\\AdaptorOmission",output_main_dir); mkdir(adaptor_omission_dir);
sovs = {Wmor};
contrasts = {{AOmiF,AOmiR},{intblksmpAO,AOmi}}; %,
conds = {AOmi,AOmiF,AOmiR};
time = -0.1:0.004:1.156;
f = get_funcs_instant(subs,sovs, AOmi,ft_cond_input_dir,ft_cond_output_dir,time);

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
cfg.ylim_ = [-1.3,2];
% cfg.plot_bp_filter = [0.1,20];
maxPval = 0.05;


curr_cont_elec =  "curr_sov_cont_clustersElect";
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,curr_cont_elec,adaptor_omission_dir,0.05,cfg)
% 
% curr_electd_clust =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,{intblksmpAO,AOmi},{Wnig,Wnig},maxPval);
% f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO,AOmi},{N3,N3},curr_electd_clust,cfg);

best_cluster_cont = {AOmiF,AOmiR};
best_cluster_contSovs = {Wnig,Wnig};
elcdClust_bestCluster =  f.get_electdClust(f,'simple_contrast',adaptor_omission_dir,best_cluster_cont,best_cluster_contSovs,0.1);
% union_intersect_sovs = {Wnig,N2,N3,REM};
% elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',adaptor_omission_dir,best_cluster_cont,union_intersect_sovs,maxPval);
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,elcdClust_bestCluster,adaptor_omission_dir,maxPval,cfg)

% plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,elcdClust_bestCluster, adaptor_omission_dir,cfg)

% run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,elcdClust_bestCluster,output_dir,cfg)
% for sov_i=1:numel(sovs)
%     for cond_i=1:numel(conds)
%         f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},sovs{sov_i},elcdClust_bestCluster, cfg)
%     end
% end

%% RUN TFR Cluster-permu 
output_dir = sprintf("%s\\TFR_topo\\zscored",output_main_dir); mkdir(output_dir); %
sovs = {N2}; % Wnig,REM,N3,
contrasts = {{noN2EventsAORtfr,noN2EventsAOFtfr}};%{AOmiFtfr,AOmiRtfr}
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
contrasts = {{AOmiRtfr,AOmiFtfr}}; % {intblksmpAOtfr,AOmiftr},{noN2EventsAORtfr,noN2EventsAOFtfr}

output_dir = sprintf("%s\\TFR\\zscored",output_main_dir); mkdir(output_dir);
sovs = {Wnig,N2,N3,REM}; % 
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
time = -0.1:0.004:1.156;
f = get_funcs_instant(subs,sovs, intblksmpAO,ft_cond_input_dir,ft_cond_output_dir,time);

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
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{intblksmpAblO,AblOmi},{N2,N2},0.05);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2KcompAO,N2}},electd_clust,"BlNokc" , cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2}},electd_clust,"BlNoss" ,cfg);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2EventsAO,N2}},electd_clust,"BlNoeve" , cfg);

f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2},{noN2KcompAO,N2},{noN2EventsAO,N2}},electd_clust,"BlWAndWOAllEveTypes" , cfg);

cluster_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{intblksmpAO,AOmi},{N2,N2},0.05);
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

function curr_sov_subs = sub_exclu_per_sov(subs, sovs,conds)
    curr_sov_subs = subs;
    for sov_i=1:numel(sovs)
        for cond_i=1:numel(conds)
            if strcmp(sovs{sov_i}.import_s, 'wake_night')
    %             if strcmp(cond.import_s,'lastAblOF')
    %                 curr_sov_subs(ismember(curr_sov_subs, { '29','32'})) = [];
    %             end
            elseif strcmp(sovs{sov_i}.import_s, 'N1')
                curr_sov_subs(ismember(curr_sov_subs, { '33'})) = [];
                curr_sov_subs(ismember(curr_sov_subs, { '36'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'wake')
                curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
            elseif strcmp(sovs{sov_i}.import_s, 'N2')
            elseif strcmp(sovs{sov_i}.import_s, 'N3')
                if strcmp(conds{cond_i}.import_s,'lastAT')
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
end
