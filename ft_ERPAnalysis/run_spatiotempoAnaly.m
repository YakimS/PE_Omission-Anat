
% sovs
N1 = struct(); N1.import_s = "N1"; N1.short_s = "N1"; N1.long_s = "N1";
N2 = struct(); N2.import_s = "N2"; N2.short_s = "N2"; N2.long_s = "N2";
N3 = struct(); N3.import_s = "N3"; N3.short_s = "N3"; N3.long_s = "N3";
REM = struct(); REM.import_s = "REM"; REM.short_s = "REM"; REM.long_s = "REM";
tREM = struct(); tREM.import_s = "tREM"; tREM.short_s = "tREM"; tREM.long_s = "tREM";
pREM = struct(); pREM.import_s = "pREM"; pREM.short_s = "pREM"; pREM.long_s = "pREM";
Wnig = struct(); Wnig.import_s = "wake_night"; Wnig.short_s = "wn"; Wnig.long_s = "Wake Pre";
Wmor = struct(); Wmor.import_s = "wake_morning"; Wmor.short_s = "wm"; Wmor.long_s = "Wake Post";

% [-0.1, 0.448]
Omi = struct(); Omi.import_s = "O"; Omi.short_s = "O"; Omi.long_s = "Omission";
OmiR = struct(); OmiR.import_s = "OR"; OmiR.short_s = "OR"; OmiR.long_s = "Omission Random";
OmiF = struct(); OmiF.import_s = "OF"; OmiF.short_s = "OF"; OmiF.long_s = "Omission Fixed";
intbk = struct(); intbk.import_s = "intbk"; intbk.short_s = "intbk"; intbk.long_s = "Interblock (Avg)";
intbkMid = struct(); intbkMid.import_s = "intbkMid"; intbkMid.short_s = "intbkMid"; intbkMid.long_s = "Interblock middle (Avg)"; % 0.5s - 4.5s of the interblock cut to 0.5s

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

output_dir = sprintf("%s\\all",output_main_dir);
mkdir(output_dir);


%% RUN TFR Cluster-permu 

sovs = {Wnig,Wnig,N2,N3,REM};
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
%% RUN  (O,OF,OR vs intbk) & (OF vs. OR) with a specific range [-0.1,0.448]

bl_cond = intbkMid;
% sovs = {Wnig,N2,N3,REM}; %Wmor,N3,REM,Wnig,N2,tREM,pREM
sovs = {tREM,pREM};
pre_vs_post_conds = {Omi,OmiF,OmiR};
union_intersect_sovs = {Wnig,N2,N3,REM};
contrasts = {{OmiF,OmiR}};
best_cluster_cont = {bl_cond,Omi};
best_cluster_contSovs = {Wnig,Wnig};
test_latency = [0,0.448];
plot_latency= [-0.1,0.448];
is_plot_topoplot = true;
is_plot_video = false;

onset_event = struct();
onset_event.("event_time") = 0;
onset_event.("event_color") = [.3, .3 ,.3];
onset_event.("event_text") = 'Omission Onset';
event_lines = {onset_event};

run_full_O_OF_OR_vs_intblk_in_range(subs,bl_cond, sovs,union_intersect_sovs,pre_vs_post_conds,contrasts,best_cluster_cont,best_cluster_contSovs,test_latency,plot_latency, ...
                                    event_lines,is_plot_topoplot,is_plot_video,ft_cond_input_dir,ft_cond_output_dir,output_dir)


%% RUN  (OF,OR vs intbk) & (OF vs. OR) with a specific range [-0.2,2]
sovs = {Wnig,N2,N3,REM}; %Wmor,N3,REM,N2
bl_cond = intbk2;
pre_vs_post_conds = {LastOF2,LastOR2};
contrasts = {{LastOF2,LastOR2}};
best_cluster_cont = {bl_cond,LastOF2}; best_cluster_contSovs = {Wnig,Wnig};
test_latency = [0,1.996]; plot_latency= [-0.2,1.996];
is_plot_topoplot = true;
is_plot_video = false;

event_lines = {};
event = struct();
event.("event_time") = 0;
event.("event_color") = [.3, .3 ,.3];
event.("event_text") = '';
event_lines{end+1} = event;
event.("event_time") = 0.5;
event_lines{end+1} = event;
event.("event_time") = 1;
event_lines{end+1} = event;
event.("event_time") = 1.5;
event_lines{end+1} = event;


run_full_O_OF_OR_vs_intblk_in_range(subs,bl_cond, sovs,pre_vs_post_conds,contrasts,best_cluster_cont,best_cluster_contSovs,test_latency,plot_latency, ...
                                    event_lines,is_plot_topoplot,is_plot_video,ft_cond_input_dir,ft_cond_output_dir,output_dir)

%%
sovs = {Wnig,N2,N3,REM}; %Wmor,N3,REM,Wnig, N2
for sov_i = 1:numel(sovs)
    curr_sov_subs = sub_exclu_per_sov(subs, {sovs{sov_i}});
    imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir); 
    timelock = imp.get_cond_timelocked(imp,intbk5,sovs{sov_i});
    electrodes = timelock{1}.label;
    time = timelock{1}.time;
    f = funcs_(imp, electrodes,time);

    f.plot_erp_per_cond_across_sovs(f,output_dir,intbk5,{sovs{sov_i}},{intbk,Omi},{Wnig,Wnig},{},[0,5])
end

curr_sov_subs = sub_exclu_per_sov(subs, sovs);
imp = ft_importer(curr_sov_subs,ft_cond_input_dir,ft_cond_output_dir); 
timelock = imp.get_cond_timelocked(imp,intbk5,sovs{sov_i});
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_(imp, electrodes,time);
f.plot_erp_per_cond_across_sovs(f,output_dir,intbk5,sovs,{intbk,Omi},{Wnig,Wnig},{},[0,5])

%%
curr_subs = subs;
% curr_subs(ismember(curr_subs, {'14','15','17','27','37'})) = [];
curr_subs(ismember(curr_subs, {'14','32','37'})) = [];
rand_cond =OmiR618;
imp = ft_importer(curr_subs,ft_cond_input_dir,ft_cond_output_dir); 
timelock = imp.get_cond_timelocked(imp,rand_cond,Wnig);
electrodes = timelock{1}.label;
time = timelock{1}.time;
sovs = {Wnig};%Wnig,N2,REM,N3
f = funcs_(imp, electrodes,time);
% f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiF,sovs,{Omi,intbk},{Wnig,Wnig},{})
% f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiR,sovs,{Omi,intbk},{Wnig,Wnig},{})

% f.plot_erp_per_cond_across_sovs(f,output_dir,OmiR618,sovs,{Omi,intbk},{Wnig,Wnig},{})
% f.plot_erp_per_cond_across_sovs(f,output_dir,OmiR718,sovs,{Omi,intbk},{Wnig,Wnig},{})
% f.plot_erp_per_cond_across_sovs(f,output_dir,OmiR818,sovs,{Omi,intbk},{Wnig,Wnig},{})
% f.plot_erp_per_cond_across_sovs(f,output_dir,OmiR918,sovs,{Omi,intbk},{Wnig,Wnig},{})

% f.plot_erp_per_cond_across_sovs(f,output_dir,OmiF18,sovs,{Omi,intbk},{Wnig,Wnig},{})

% f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiF18,sovs,{Omi,intbk},{Wnig,Wnig},{})

% f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiR18,sovs,{Omi,intbk},{Wnig,Wnig},{})

f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiR18,sovs,{Omi,intbk},{Wnig,Wnig},{},[0,2])

is_plot_topoplot = true;
is_plot_video = true;
f.run_spatiotempoClustPerm_dependent(f,output_dir, {pre_vs_post_conds{cond_i},intbk},{sovs{sov_i},sovs{sov_i}},[-0.1,0.448], is_plot_topoplot,is_plot_video)
f.plot_erp_per_contrast_and_sov(f,output_dir,{pre_vs_post_conds{cond_i},intbk},{sovs{sov_i},sovs{sov_i}},{pre_vs_post_conds{cond_i},intbk},{sovs{sov_i},sovs{sov_i}},sovs{sov_i}.short_s)
f.plot_erp_per_contrast_and_sov(f,output_dir,{pre_vs_post_conds{cond_i},intbk},{sovs{sov_i},sovs{sov_i}},{pre_vs_post_conds{cond_i},intbk},{Wnig,Wnig},sovs{sov_i}.short_s)


%%
for sov_i = 1:numel(sovs)
    curr_subs = subs;
    if strcmp(sovs{sov_i}.import_s, 'wake_night')
        curr_subs(ismember(curr_subs, {'29','37'})) = [];
% %     elseif strcmp(sovs{sov_i}.import_s, 'wake_morning')
% %         curr_subs(ismember(curr_subs, {'09','14','24', '30', '37'})) = [];
    elseif strcmp(sovs{sov_i}.import_s, 'N3')
        curr_subs(ismember(curr_subs, {'27','29','37'})) = [];
    elseif strcmp(sovs{sov_i}.import_s, 'N2')
        curr_subs(ismember(curr_subs, {'29','37'})) = [];
    elseif strcmp(sovs{sov_i}.import_s, 'REM')
        curr_subs(ismember(curr_subs, {'27','29','37'})) = [];
    end
    rand_cond =LastOmiF;
    imp = ft_importer(curr_subs,ft_cond_input_dir,ft_cond_output_dir); 
    timelock = imp.get_cond_timelocked(imp,rand_cond,Wnig);
    electrodes = timelock{1}.label;
    time = timelock{1}.time;
    f = funcs_(imp, electrodes,time);
    f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiF,{sovs{sov_i}},{Omi,intbk},{Wnig,Wnig},{});
    f.plot_erp_per_cond_across_sovs(f,output_dir,LastOmiR,{sovs{sov_i}},{Omi,intbk},{Wnig,Wnig},{});
end



% curr_subs = subs;
% curr_subs(ismember(curr_subs, {'27','29','37'})) = [];
% rand_cond =LastOmiF;
% imp = ft_importer(curr_subs,ft_cond_input_dir,ft_cond_output_dir); 
% timelock = imp.get_cond_timelocked(imp,rand_cond,Wnig);
% electrodes = timelock{1}.label;
% time = timelock{1}.time;
% f = funcs_(imp, electrodes,time);
% contrasts = {{LastOmiF, LastOmiR}};
% cont_i = 1;
% for sov_i = 1:numel(sovs)
%     is_plot_topoplot = true;
%     is_plot_video = false;
%     f.run_spatiotempoClustPerm_dependent(f,output_dir, contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},[-12,6], is_plot_topoplot,is_plot_video)
%     f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},{LastOmiF, LastOmiR},{sovs{sov_i},sovs{sov_i}},sovs{sov_i}.short_s)
%     f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},{Omi,intbk},{Wnig,Wnig},sovs{sov_i}.short_s)
%     f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},{sovs{sov_i},sovs{sov_i}},{LastOmiF, LastOmiR},{Wnig,Wnig},sovs{sov_i}.short_s)
% end

 %% functions

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

function run_full_O_OF_OR_vs_intblk_in_range(subs,bl_cond, sovs,union_intersect_sovs,pre_vs_post_conds,contrasts,best_cluster_cont,best_cluster_contSovs, ...
    test_latency,plot_latency,event_lines, ...
    is_plot_topoplot,is_plot_video,ft_cond_input_dir,ft_cond_output_dir,output_dir)

    %%% within sovs
    for sov_i = 1:numel(sovs) 
        cur_contrast_sovs = {sovs{sov_i},sovs{sov_i}};
        for cond_i=1:numel(pre_vs_post_conds)
            f = get_funcs_instant(subs,sovs, pre_vs_post_conds{cond_i},ft_cond_input_dir,ft_cond_output_dir);
            curr_contrast_conds = {bl_cond,pre_vs_post_conds{cond_i}};

            % spatio-temporal-cluster permutation. Contrast: pre-vs-post conds
            f.run_spatiotempoClustPerm_dependent(f,output_dir, curr_contrast_conds,cur_contrast_sovs,test_latency,plot_latency, is_plot_topoplot,is_plot_video)
            
%             % plot contrast. Electrodes: stcp results
%             elcdClust_withinCurrSov_condVsIntblk = f.get_electdClust(f,'simple_contrast',output_dir,curr_contrast_conds,cur_contrast_sovs);
%             f.plot_erp_per_contrast_and_sov(f,output_dir,curr_contrast_conds,cur_contrast_sovs,elcdClust_withinCurrSov_condVsIntblk,sovs{sov_i}.short_s, ...
%                 'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines)
%             
%             % plot contrast. Electrodes: given "best"
%             elcdClust_bestCluster =  f.get_electdClust(f,'simple_contrast',output_dir,best_cluster_cont,best_cluster_contSovs);
%             f.plot_erp_per_contrast_and_sov(f,output_dir,curr_contrast_conds,cur_contrast_sovs,elcdClust_bestCluster,sovs{sov_i}.short_s, ...
%                 'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines)
% 
%             % plot all subjects in the "post" cond, Electrodes: given "best"
%             f.plot_erp_per_cond_across_sovs(f,output_dir,pre_vs_post_conds{cond_i},{sovs{sov_i}},elcdClust_bestCluster ...
%                 ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines)
        end
    
        for cont_i=1:numel(contrasts)
            f.run_spatiotempoClustPerm_dependent(f,output_dir, contrasts{cont_i},cur_contrast_sovs,test_latency,plot_latency, is_plot_topoplot,is_plot_video)
            
%             curr_elcdClust =  f.get_electdClust(f,'simple_contrast',output_dir,best_cluster_cont,cur_contrast_sovs);
%             
%             f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},cur_contrast_sovs,curr_elcdClust,sovs{sov_i}.short_s ...
%                 ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines);
%             
%             f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},cur_contrast_sovs,elcdClust_bestCluster,sovs{sov_i}.short_s...
%                 ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines);
        end
    end


    %%% between sovs
%     for cond_i=1:numel(pre_vs_post_conds)
%         sovs_pairs = uniquePairs(sovs);
%         for sp_i = 1:numel(sovs_pairs) 
%             f = get_funcs_instant(subs,sovs, pre_vs_post_conds{cond_i},ft_cond_input_dir,ft_cond_output_dir);
%             cur_contrast_sovs = {sovs_pairs{sp_i}{1},sovs_pairs{sp_i}{2}};
%             curr_contrast_conds = {pre_vs_post_conds{cond_i},pre_vs_post_conds{cond_i}};
% 
%             f.run_spatiotempoClustPerm_dependent(f,output_dir, curr_contrast_conds,cur_contrast_sovs,test_latency,plot_latency, is_plot_topoplot,is_plot_video);
%         end
% 
%         f = get_funcs_instant(subs,sovs, pre_vs_post_conds{cond_i},ft_cond_input_dir,ft_cond_output_dir);
%         cond_contrast_for_sig = {bl_cond,pre_vs_post_conds{cond_i}};
% 
%         elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);
%         f.plot_erp_per_cond_across_sovs(f,output_dir,pre_vs_post_conds{cond_i},sovs,elcdClust_unionInter, ...
%             'withinSov_contrast_forSigLine',cond_contrast_for_sig, ...
%             'betweenSov_cond_forSigLine', pre_vs_post_conds{cond_i}, ...
%             'test_latency', test_latency,'plot_latency',plot_latency, 'event_lines',event_lines);
%     end


    %%% unionWithinFrontBack_intersectBetweenSovs
    for sov_i = 1:numel(sovs) 
        cur_contrast_sovs = {sovs{sov_i},sovs{sov_i}};
        for cond_i=1:numel(pre_vs_post_conds)
            f = get_funcs_instant(subs,sovs, pre_vs_post_conds{cond_i},ft_cond_input_dir,ft_cond_output_dir);
            curr_contrast_conds = {bl_cond,pre_vs_post_conds{cond_i}};

            elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);
            f.plot_erp_per_contrast_and_sov(f,output_dir,curr_contrast_conds,cur_contrast_sovs,elcdClust_unionInter,sovs{sov_i}.short_s ...
                    ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines);
            f.plot_erp_per_cond_across_sovs(f,output_dir,pre_vs_post_conds{cond_i},{sovs{sov_i}},elcdClust_unionInter ...
                ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines)
        end
        for cont_i=1:numel(contrasts)
            elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);
            f.plot_erp_per_contrast_and_sov(f,output_dir,contrasts{cont_i},cur_contrast_sovs,elcdClust_unionInter,sovs{sov_i}.short_s ...
                ,'test_latency', test_latency,'plot_latency',plot_latency,"event_lines",event_lines);
        end
    end
    
    %%% unionWithinFrontBack_intersectBetweenSovs % between sovs
%     for cond_i=1:numel(pre_vs_post_conds)
%         f = get_funcs_instant(subs,sovs, pre_vs_post_conds{cond_i},ft_cond_input_dir,ft_cond_output_dir);
%         cond_contrast_for_sig = {bl_cond,pre_vs_post_conds{cond_i}};
% 
%         elcdClust_unionInter =  f.get_electdClust(f,'unionWithinFrontBack_intersectBetweenSovs',output_dir,best_cluster_cont,union_intersect_sovs);
%         f.plot_erp_per_cond_across_sovs(f,output_dir,pre_vs_post_conds{cond_i},sovs,elcdClust_unionInter, ...
%             'withinSov_contrast_forSigLine',cond_contrast_for_sig, ...
%             'betweenSov_cond_forSigLine', pre_vs_post_conds{cond_i}, ...
%             'test_latency', test_latency,'plot_latency',plot_latency, 'event_lines',event_lines);
%     end
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
