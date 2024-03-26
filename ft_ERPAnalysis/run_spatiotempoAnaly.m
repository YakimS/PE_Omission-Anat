
% sovs
N1 = defineExpStruct("N1", "N1", "N1", false);
N2 = defineExpStruct("N2", "N2", "N2", false);
N3 = defineExpStruct("N3", "N3", "N3", false);
REM = defineExpStruct("REM", "REM", "REM", false);
tREM = defineExpStruct("tREM", "tREM", "tREM", false);
pREM = defineExpStruct("pREM", "pREM", "pREM", false);
Wnig = defineExpStruct("wake_night", "wn", "Wake Pre", false);
Wmor = defineExpStruct("wake_morning", "wm", "Wake Post", false);

% [-0.1, 0.58] - locked to A before
AblOmi = defineExpStruct("AblO", "AblO", "Omission", false);
AblOmiF = defineExpStruct("AblOF", "AblOF", "Predictable Omission", false);
AblOmiR = defineExpStruct("AblOR", "AblOR", "Unpredictable Omission", false);
intblksmpAblO = defineExpStruct("intblksmpAblO", "intblksmpAblO", "Baseline", true);
intblksmpAblOF = defineExpStruct("intblksmpAblOF", "intblksmpAblOF", "Baseline", true);
intblksmpAblOR = defineExpStruct("intblksmpAblOR", "intblksmpAblOR", "Baseline", true);

noN2EventsAblOmi = defineExpStruct("noN2EventsAblO", "noN2EventsAblO", "Omission without ss&kc", false);

% [-0.1, 1.16]
AOmi = defineExpStruct("AO", "AO", "Omission", false);
AOmiR = defineExpStruct("AOR", "AOR", "Unpredictable Omission", false);
AOmiF = defineExpStruct("AOF", "AOF", "Predictable Omission", false);
intblksmpAO = defineExpStruct("intblksmpAO", "intblksmpAO", "Baseline", true);
intblksmpAOR = defineExpStruct("intblksmpAOR", "intblksmpAOR", "Baseline", true);
intblksmpAOF = defineExpStruct("intblksmpAOF", "intblksmpAOF", "Baseline", true);

noN2EventsAO = defineExpStruct("noN2EventsAO", "noN2EventsAO", "Omission w/o ss&kc", false);
noN2EventsAOF = defineExpStruct("noN2EventsAOF", "noN2EventsAOF", "Omission fixed w/o ss&kc", false);
noN2EventsAOR = defineExpStruct("noN2EventsAOR", "noN2EventsAOR", "Omission random w/o ss&kc", false);
noN2KcompAO = defineExpStruct("noN2KcompAO", "noN2KcompAO", "Omission w/o kc", false);
noN2KcompAOF = defineExpStruct("noN2KcompAOF", "noN2KcompAOF", "Predictable Omission w/o kc", false);
noN2KcompAOR = defineExpStruct("noN2KcompAOR", "noN2KcompAOR", "Unpredictable Omission w/o kc", false);
noN2SsAO = defineExpStruct("noN2SsAO", "noN2SsAO", "Omission w/o ss", false);


% % [-12, 6]
% OmiR618 = struct(); OmiR618.import_s = "OR618"; OmiR618.short_s = "OR618"; OmiR618.long_s = "Omission Random, 6th";
% OmiR718 = struct(); OmiR718.import_s = "OR718"; OmiR718.short_s = "OR718"; OmiR718.long_s = "Omission Random, 7th";
% OmiR818 = struct(); OmiR818.import_s = "OR818"; OmiR818.short_s = "OR818"; OmiR818.long_s = "Omission Random, 8th";
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

%% RUN  (AO,AOF,AOR vs Aintbk) & (AOF vs. AOR) with a specific range [-0.1,1.16]
output_dir = sprintf("%s\\AdaptorOmission",output_main_dir); mkdir(output_dir);
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

curr_electd_clust =  f.get_electdClust(f,'simple_contrast',output_dir,{intblksmpAO,AOmi},{Wnig,Wnig});
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO,AOmi},{N3,N3},curr_electd_clust ...
                ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);

best_cluster_cont = {AOmiF,AOmiR};
best_cluster_contSovs = {Wnig,Wnig};
elcdClust_bestCluster =  f.get_electdClust(f,'simple_contrast',output_dir,best_cluster_cont,best_cluster_contSovs);
% union_intersect_sovs = {Wnig,N2,N3,REM};
% elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);

% run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,elcdClust_bestCluster,output_dir,cfg)
% plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,elcdClust_bestCluster, output_dir,cfg)
% run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,elcdClust_bestCluster,output_dir,cfg)
% plot_erp_withinSovCond_allSubs(f, sovs, conds, elcdClust_bestCluster, output_dir,cfg)
%% RUN  (AblO,AblOF,AblOR vs intblksmpAO) & (AblOF vs. AblOR) with a specific range [-0.1,0.58]

output_dir = sprintf("%s\\Omission058_AblLocked",output_main_dir); mkdir(output_dir);
sovs = {Wnig,N2,N3,REM};
contrasts = {{intblksmpAblO,AblOmi}, {AblOmiF,AblOmiR}};
conds = {AblOmi,AblOmiR,AblOmiF};
f = get_funcs_instant(subs,sovs, conds{1},ft_cond_input_dir,ft_cond_output_dir);

omission_event = struct();
omission_event.("event_time") = 0;
omission_event.("event_color") = [.2, .2 ,.2];
omission_event.("event_text") = 'Omission';
event_lines = {omission_event};

cfg = {};
cfg.event_lines = event_lines;
cfg.test_latency =  [0,0.58];
cfg.plot_latency= [-0.1,0.58];
cfg.is_plot_topoplot = true;
cfg.is_plot_video = false;

electd_clust = f.get_electdClust(f,'simple_contrast',sprintf("%s\\AdaptorOmission",output_main_dir),{intblksmpAO,AOmi},{REM,REM});
run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,electd_clust,output_dir,cfg)


%% RUN TFR Cluster-permu 

sovs = {Wnig,N2,N3,REM};
pre_vs_post_conds = {Omi,OmiF,OmiR};
contrasts = {{OmiF,OmiR}};
f = get_funcs_instant(subs,sovs, pre_vs_post_conds{1},ft_cond_input_dir,ft_cond_output_dir);
contrast_conds = {intbkMid,Omi};
contrast_sovs = {Wnig,Wnig};
timerange_test = [0,0.448];
freqrange_test =  {[1.5,4],[8,12],[13,30],[31,40]};
timerange_plot = [-0.1 0.448];
is_plot_topoplot = true;

for cond_i=1:numel(pre_vs_post_conds)
    for sov_i=1:numel(sovs)
        for freq_i=1:numel(freqrange_test)
            contrast_conds = {intbkMid,pre_vs_post_conds{cond_i}};
            f.run_STCP_TFR_dependent(f,output_dir, contrast_conds,{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot, is_plot_topoplot)
        end
    end
end

for cond_i=1:numel(contrasts)
    for sov_i=1:numel(sovs)
        for freq_i=1:numel(freqrange_test)
            f.run_STCP_TFR_dependent(f,output_dir, contrasts{cond_i},{sovs{sov_i},sovs{sov_i}},timerange_test,freqrange_test{freq_i},timerange_plot, is_plot_topoplot)
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
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAblO, noN2EventsAblOmi},{N2,N2},electd_clust ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAblO, AblOmi},{N2,N2},electd_clust ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);

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


f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO, noN2EventsAO},{N2,N2},electd_clust ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
f.plot_erp_per_contrast_and_sov(f,output_dir,{intblksmpAO, AOmi},{N2,N2},electd_clust ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{intblksmpAO, noN2EventsAO}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{intblksmpAO, AOmi}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{noN2EventsAO, AOmi}},'curr_sov_cont_clustersElect',output_dir,cfg)
run_withinSov_betweenCond_stcp_analysis(f, sovs, {{noN2EventsAOF, noN2EventsAOR}},'curr_sov_cont_clustersElect',output_dir,cfg)

cluster_dir = sprintf("%s\\AdaptorOmission",output_main_dir);
electd_clust = f.get_electdClust(f,'simple_contrast',cluster_dir,{AOmiF,AOmiR},{Wnig,Wnig});
f.plot_erp_per_contrast_and_sov(f,output_dir,{noN2EventsAOF, noN2EventsAOR},{N2,N2},electd_clust ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);

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
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2KcompAO,N2}},electd_clust,"BlNokc" ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2}},electd_clust,"BlNoss" ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2EventsAO,N2}},electd_clust,"BlNoeve" ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);

f.plot_erp_per_condsSovPairs(f,output_dir,{{intblksmpAO,N2}, {AOmi,N2},{noN2SsAO,N2},{noN2KcompAO,N2},{noN2EventsAO,N2}},electd_clust,"BlWAndWOAllEveTypes" ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
%% functions

function run_withinSov_betweenCond_stcp_analysis(f, sovs, contrasts,electd_clust,output_dir,cfg)
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [f.time(1), f.time(end)]; end
    if ~isfield(cfg, 'is_plot_topoplot')    cfg.is_plot_topoplot = true; end
    if ~isfield(cfg, 'is_plot_video')       cfg.is_plot_video = false; end
    if ~isfield(cfg, 'event_lines')         cfg.event_lines = {}; end

    for sov_i = 1:numel(sovs) 
        cur_contrast_sovs = {sovs{sov_i},sovs{sov_i}};    
        for cont_i=1:numel(contrasts)
            
            f.run_STCP_ERP_dependent(f,output_dir, contrasts{cont_i},cur_contrast_sovs, ...
                cfg.test_latency,cfg.test_latency, cfg.is_plot_topoplot,cfg.is_plot_video)
            
            if (ischar(electd_clust) || isstring(electd_clust)) && strcmp(electd_clust, "curr_sov_cont_clustersElect")
                curr_electd_clust = f.get_electdClust(f,'simple_contrast',output_dir,contrasts{cont_i},cur_contrast_sovs);
            else
                curr_electd_clust = electd_clust;
            end

            f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},cur_contrast_sovs,curr_electd_clust ...
                ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines);
        end
    end
end

function run_betweenSovs_withinCond_stcp_analysis(f,sovs, conds,electd_clust,output_dir,cfg)
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [f.time(1), f.time(end)]; end
    if ~isfield(cfg, 'is_plot_topoplot')    cfg.is_plot_topoplot = true; end
    if ~isfield(cfg, 'is_plot_video')       cfg.is_plot_video = false; end
    if ~isfield(cfg, 'event_lines')         cfg.event_lines = {}; end
    
    for conds_i=1:numel(conds)
        sovs_pairs = uniquePairs(sovs);
        for sp_i = 1:numel(sovs_pairs) 
            cur_contrast_sovs = {sovs_pairs{sp_i}{1},sovs_pairs{sp_i}{2}};
            curr_contrast_conds = {conds{conds_i},conds{conds_i}};

            f.run_STCP_ERP_dependent(f,output_dir, curr_contrast_conds,cur_contrast_sovs, ...
                cfg.test_latency,cfg.test_latency, cfg.is_plot_topoplot,cfg.is_plot_video);
            
            f.plot_erp_per_contrast_and_sov(f,output_dir,curr_contrast_conds,cur_contrast_sovs,electd_clust ...
            ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines)
        end
    end
end

function plot_erp_withinSovCond_allSubs(f, sovs, conds, electd_clust, output_dir,cfg)
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [f.time(1), f.time(end)]; end
    if ~isfield(cfg, 'event_lines')         cfg.event_lines = {}; end
    
    for sov_i = 1:numel(sovs)
        for cond_i=1:numel(conds)
            f.plot_erp_per_cond_across_sovs(f,output_dir,conds{cond_i},{sovs{sov_i}},electd_clust ...
                ,'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency,"event_lines",cfg.event_lines)
        end
    end
end

function plot_erp_allSovsOneCondOneContrastAllBlContrasts(f, sovs,contrasts,electd_clust, output_dir,cfg)
    if ~isfield(cfg, 'test_latency')        cfg.test_latency = [0, f.time(end)]; end
    if ~isfield(cfg, 'plot_latency')        cfg.plot_latency = [f.time(1), f.time(end)]; end
    if ~isfield(cfg, 'event_lines')         cfg.event_lines = {}; end

    for cont_i=1:numel(contrasts)
        if contrasts{cont_i}{1}.isBaseline || contrasts{cont_i}{2}.isBaseline
            if contrasts{cont_i}{1}.isBaseline
                non_baselise_cond = 2;
            else 
                non_baselise_cond = 1;
            end
            f.plot_erp_per_cond_across_sovs(f,output_dir,contrasts{cont_i}{non_baselise_cond},sovs,electd_clust, ...
                'withinSov_contrast_forSigLine',contrasts{cont_i}, ...
                'betweenSov_cond_forSigLine', contrasts{cont_i}{non_baselise_cond}, ... 
                'test_latency', cfg.test_latency,'plot_latency',cfg.plot_latency, 'event_lines',cfg.event_lines);
        end
    end
end




function f = get_funcs_instant(actual_subs,actual_sovs, examp_cond,ft_cond_input_dir,ft_cond_output_dir)
    curr_sov_subs = sub_exclu_per_sov(actual_subs, actual_sovs,examp_cond);
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir); 
    timelock = imp.get_cond_timelocked(imp,examp_cond,actual_sovs{1});
    electrodes = timelock{1}.label;
    time = timelock{1}.time;
    f = funcs_(imp, electrodes,time);
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
        elseif strcmp(sovs{sov_i}.import_s, 'N1')
        elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
            curr_sov_subs(ismember(curr_sov_subs, { '23'})) = [];
        elseif strcmp(sovs{sov_i}.import_s, 'N2')
        elseif strcmp(sovs{sov_i}.import_s, 'N3')
        elseif strcmp(sovs{sov_i}.import_s, "tREM")
            curr_sov_subs(ismember(curr_sov_subs, {'36'})) = [];
        end
    end
end
