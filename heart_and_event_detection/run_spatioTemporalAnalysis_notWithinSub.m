subs = {'02','03','04','05','06','07','08','09','11','12','13','14',...
    '15','16','17','18','19','21','22','24','26','27','28','29'...
    '30','31','32','33','34','35','36','37','38'}; %'01','10', excluded. '20','23','25'
bl = 1000;
contrasts = {{'None','Unpleasant'},{'None','Smell'},{'None','Pleasant'},{'Pleasant','Unpleasant'}};
conditions = {'None','Smell','Pleasant','Unpleasant'};
ft_cond_input_dir = "C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\ft_per_cond_exclu";
ft_cond_output_dir = "C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\sniff\ft_per_cond_exclu";
results_dir = "C:\Users\User\Cloud-Drive\BigFiles\sniff_output\exclu";
output_main_dir = results_dir;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_timelock/
restoredefaultpath
libs_dir = 'C:\Users\User\Cloud-Drive\BigFiles\libs';
addpath(sprintf('%s\\fieldtrip-20230223', libs_dir))
ft_defaults
addpath(sprintf('%s\\eeglab2023.0', libs_dir))
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
addpath(libs_dir)
close;
%%
cond_rand_name ='None';
sov = 'wake';
imp = ft_importer(subs,ft_cond_input_dir,ft_cond_output_dir,bl,sov); 
timelock = imp.get_cond_timelocked(imp,cond_rand_name);
electrodes = timelock{1}.label;
time = timelock{1}.time;
f = funcs_spatioTemporalAnalysis(imp, electrodes,time);

cond1_Vs_cond2_dir = sprintf('%s\\%s\\cond1_Vs_cond2',output_main_dir,sov);
pre_vs_poststim_dir = sprintf("%s\\%s\\preStim_Vs_postStim",output_main_dir,sov);
dir_baseline_erp = sprintf('%s\\%s\\baseline_erp',output_main_dir,sov);
persub_output_dir = sprintf("%s\\%s\\per_sub_electrode",output_main_dir,sov);
mkdir(cond1_Vs_cond2_dir);
mkdir(pre_vs_poststim_dir);
mkdir(dir_baseline_erp);
mkdir(persub_output_dir);

%%
all_minus_faceNeck = {'all', '-E1', '-E2', '-E10', '-E11', '-E12', '-E18', '-E19', '-E20', '-E25', '-E26', '-E30', '-E31', '-E32', '-E33', '-E36', '-E37', '-E45', '-E46', '-E53', '-E60', '-E61', '-E66', '-E67', '-E72', '-E81', '-E90', '-E91', '-E92', '-E101', '-E102', '-E103', '-E112', '-E113', '-E121', '-E122', '-E134', '-E135', '-E136', '-E146', '-E147', '-E148', '-E157', '-E158', '-E166', '-E167', '-E175', '-E176', '-E188', '-E189', '-E200', '-E201', '-E202', '-E209', '-E210', '-E211', '-E212', '-E217', '-E218', '-E219', '-E220', '-E221', '-E222', '-E227', '-E228', '-E229', '-E230', '-E231', '-E232', '-E233', '-E234', '-E235', '-E236', '-E237', '-E238', '-E239', '-E240', '-E241', '-E242', '-E243', '-E244', '-E245', '-E246', '-E247', '-E248', '-E249', '-E250', '-E251', '-E252', '-E253', '-E254', '-E255', '-E256'};
all_minus_faceNeck = {'all', '-E2', '-E3', '-E4', '-E5', '-E6', '-E7', '-E8', '-E9', '-E11', '-E12', '-E13', '-E14', '-E15', '-E16', '-E17', '-E19', '-E20', '-E21', '-E22', '-E23', '-E24', '-E26', '-E27', '-E28', '-E29', '-E30', '-E33', '-E34', '-E35', '-E36', '-E38', '-E39', '-E40', '-E41', '-E42', '-E43', '-E44', '-E45', '-E47', '-E48', '-E49', '-E50', '-E51', '-E52', '-E53', '-E55', '-E56', '-E57', '-E58', '-E59', '-E60', '-E61', '-E62', '-E63', '-E64', '-E65', '-E66', '-E68', '-E69', '-E70', '-E71', '-E72', '-E74', '-E75', '-E76', '-E77', '-E78', '-E79', '-E80', '-E81', '-E83', '-E84', '-E85', '-E86', '-E87', '-E88', '-E89', '-E90', '-E94', '-E95', '-E96', '-E97', '-E98', '-E99', '-E100', '-E101', '-E104', '-E105', '-E106', '-E107', '-E108', '-E109', '-E110', '-E112', '-E113', '-E114', '-E115', '-E116', '-E117', '-E118', '-E119', '-E121', '-E122', '-E123', '-E124', '-E125', '-E126', '-E127', '-E128', '-E129', '-E130', '-E131', '-E132', '-E134', '-E135', '-E136', '-E137', '-E138', '-E139', '-E140', '-E141', '-E142', '-E143', '-E144', '-E146', '-E147', '-E148', '-E149', '-E150', '-E151', '-E152', '-E153', '-E154', '-E155', '-E156', '-E157', '-E158', '-E159', '-E160', '-E161', '-E162', '-E163', '-E164', '-E166', '-E167', '-E168', '-E169', '-E170', '-E171', '-E172', '-E173', '-E175', '-E176', '-E177', '-E178', '-E179', '-E180', '-E181', '-E182', '-E183', '-E184', '-E185', '-E186', '-E188', '-E189', '-E190', '-E191', '-E192', '-E193', '-E194', '-E195', '-E196', '-E197', '-E198', '-E202', '-E203', '-E204', '-E205', '-E206', '-E207', '-E210', '-E211', '-E212', '-E213', '-E214', '-E215', '-E220', '-E221', '-E222', '-E223', '-E224'};
all_minus_faceNeck = {'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E11', 'E12', 'E13', 'E14', 'E15', 'E16', 'E17', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24', 'E26', 'E27', 'E28', 'E29', 'E30', 'E33', 'E34', 'E35', 'E36', 'E38', 'E39', 'E40', 'E41', 'E42', 'E43', 'E44', 'E45', 'E47', 'E48', 'E49', 'E50', 'E51', 'E52', 'E53', 'E55', 'E56', 'E57', 'E58', 'E59', 'E60', 'E61', 'E62', 'E63', 'E64', 'E65', 'E66', 'E68', 'E69', 'E70', 'E71', 'E72', 'E74', 'E75', 'E76', 'E77', 'E78', 'E79', 'E80', 'E81', 'E83', 'E84', 'E85', 'E86', 'E87', 'E88', 'E89', 'E90', 'E94', 'E95', 'E96', 'E97', 'E98', 'E99', 'E100', 'E101', 'E104', 'E105', 'E106', 'E107', 'E108', 'E109', 'E110', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E119', 'E121', 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'E129', 'E130', 'E131', 'E132', 'E134', 'E135', 'E136', 'E137', 'E138', 'E139', 'E140', 'E141', 'E142', 'E143', 'E144', 'E146', 'E147', 'E148', 'E149', 'E150', 'E151', 'E152', 'E153', 'E154', 'E155', 'E156', 'E157', 'E158', 'E159', 'E160', 'E161', 'E162', 'E163', 'E164', 'E166', 'E167', 'E168', 'E169', 'E170', 'E171', 'E172', 'E173', 'E175', 'E176', 'E177', 'E178', 'E179', 'E180', 'E181', 'E182', 'E183', 'E184', 'E185', 'E186', 'E188', 'E189', 'E190', 'E191', 'E192', 'E193', 'E194', 'E195', 'E196', 'E197', 'E198', 'E202', 'E203', 'E204', 'E205', 'E206', 'E207', 'E210', 'E211', 'E212', 'E213', 'E214', 'E215', 'E220', 'E221', 'E222', 'E223', 'E224'};

plot_topoplot = true;
f.spatiotempoClustPerm_cond1VsCond2_subAvg(f,cond1_Vs_cond2_dir, contrasts,plot_topoplot, [-3,10],all_minus_faceNeck)
    
for cond_i=1:numel(conditions)
    curr_cond = conditions{cond_i};
    
    plot_topoplot = true;
    f.spatiotempoClustPerm_baselineVsActivity_subAvg(f,pre_vs_poststim_dir, {curr_cond},plot_topoplot,[0,10],all_minus_faceNeck)
end

cluster_for_electrodes = load(sprintf("%s\\NoneVsSmell_avg",cond1_Vs_cond2_dir));
f.plot_erp_per_contrast_and_sov(f,sov,{'None','Smell'},{'None','Smell'},cond1_Vs_cond2_dir,"NoneVsSmell_avg",cluster_for_electrodes)
cluster_for_electrodes = load(sprintf("%s\\NoneVsPleasant_avg",cond1_Vs_cond2_dir));
f.plot_erp_per_contrast_and_sov(f,sov,{'None','Pleasant'},{'None','Pleasant'},cond1_Vs_cond2_dir,"NoneVsPleasant_avg",cluster_for_electrodes)
cluster_for_electrodes = load(sprintf("%s\\NoneVsUnpleasant_avg",cond1_Vs_cond2_dir));
f.plot_erp_per_contrast_and_sov(f,sov,{'None','Unpleasant'},{'None','Unpleasant'},cond1_Vs_cond2_dir,"NoneVsUnpleasant_avg",cluster_for_electrodes)

%%
curr_contrast = {{'None','Smell'},{'None','Pleasant'},{'None','Unpleasant'}};

f.tempoClustPerm_cond1VsCond2_perSub(f,curr_contrast, persub_output_dir,[0,10])

cluster_for_electrodes = load(sprintf("%s\\NoneVsSmell_avg",cond1_Vs_cond2_dir));
% f.plotErp_perSub_electrodesPerSigBlCluster(f,"NoneVsSmell_avg", curr_contrast,cond1_Vs_cond2_dir,cluster_for_electrodes)

%% Plot erp of difference conditions per subject - for area
% central_electrodes = [6,25,61,80,93];
% frontal_electrodes = [8,9,13,14]; % E10, E11, E18, E16
% parital_electrodes = [48,49,52,58,59]; % E61, E62, E67, E77, E78
% temporalL_electrodes = [31,32,35] ;%E39, E40, E45

curr_contrast = {'None','Smell'};
cluster_for_electrodes = load(sprintf("%s\\NoneVsSmell_avg",cond1_Vs_cond2_dir));
grandavg_cond1 = imp.get_cond_grandAvg(imp,curr_contrast{1});
grandavg_cond2 = imp.get_cond_grandAvg(imp,curr_contrast{2});
bl_cond_text = sprintf("%sVs%s_avg",curr_contrast{1},curr_contrast{2});
contrasts = {curr_contrast};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.showlabels  = 'yes';
cfg.interactive  = 'no';

% figure; ft_multiplotER(cfg,grandavg_cond1,grandavg_cond2)
% %blue - 1, red -2, green -3, purple - 4
% text(0.5,0.35,'1','color','b') ;
% text(0.5,0.3,'2','color','r');
% % text(0.5,0.25,'3','color','g');
% %text(0.5,0.2,'4','color','black');


for contrast_ind=1:size(contrasts,2)
    cond1_text = contrasts{contrast_ind}{1};
    cond2_text = contrasts{contrast_ind}{2};
%     cond3_text = contrasts{contrast_ind}{3};

    for pos_neg_ind=1:2
        if pos_neg_ind ==1
            clusters = {cluster_for_electrodes.posclusters.prob};
            clust_mask = cluster_for_electrodes.posclusterslabelmat;
            clust_time_range = cluster_for_electrodes.time;
            title_text = sprintf("PreVsPoststim %s - positive clusters",bl_cond_text);
            pos_or_neg_text = 'pos';
        else
            clusters = {cluster_for_electrodes.negclusters.prob};
            clust_mask = cluster_for_electrodes.negclusterslabelmat;
            clust_time_range = cluster_for_electrodes.time;
            title_text = sprintf("PreVsPoststim %s - negative clusters",bl_cond_text);
            pos_or_neg_text = 'neg';
        end
        for clust_ind=1:size(clusters,2)
            curr_output_filename = sprintf("%s//clustCond-%s_contrast-%svs%s_bl-%d_clustInd-%d%s_PerSub.png",cond1_Vs_cond2_dir,bl_cond_text,cond1_text,cond2_text,bl,clust_ind,pos_or_neg_text);
            if isfile(curr_output_filename) continue; end
            if clusters{clust_ind} > 0.2   continue; end
            
            % get time-electrode mask for current cluster
            curr_clust_mask = clust_mask;
            curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
            curr_clust_mask(curr_clust_mask ~= 0) = 1;
            temp = mean(curr_clust_mask,2);
            clust_electd = find(temp>0);
            temp = mean(curr_clust_mask,1);
            clust_times = find(temp>0);
    
            % Scaling of the vertical axis for the plots below
            grandavg_cond1 = imp.get_cond_timelocked(imp,cond1_text);
            grandavg_cond2 = imp.get_cond_timelocked(imp,cond2_text);
%             grandavg_cond3 = imp.get_cond_timelocked(imp,cond3_text);
            % grandavg_cond4 = imp.get_cond_timelocked(imp,cond4);
            fig = figure('Position', [10 10 1100 900]);
            sgtitle(sprintf("Contrast: %s vs. %s \n Only electrodes from %s %s cluster\nStart:  %.2f,  End:  %.2f, pval: %.3f" ...
                ,cond1_text,cond2_text,bl_cond_text,pos_or_neg_text,clust_time_range(clust_times(1)),clust_time_range(clust_times(end)),clusters{clust_ind}));
            for isub = 1:size(subs,2)
                subplot(5,7,isub)
                hold on;
                
                y1 = grandavg_cond1{isub}.avg(clust_electd,:);
                y2 = grandavg_cond2{isub}.avg(clust_electd,:);
%                 y3 = grandavg_cond3{isub}.avg(clust_electd,:);
                x = grandavg_cond1{isub}.time;
                shadedErrorBar2(x,y1,{@mean,@std},'lineprops','-b','patchSaturation',0.2); 
                shadedErrorBar2(x,y2,{@mean,@std},'lineprops','-r','patchSaturation',0.2); 
%                 shadedErrorBar2(x,y3,{@mean,@std},'lineprops','-g','patchSaturation',0.2); 

                title(strcat('subject ',subs{isub}))
                 ylim([-8 8])
                 xlim([-2 7])
            end
            subplot(5,7,size(subs,2)+1);
            axis off
            text(0.5,0.7,cond1_text,'Color','b')
            text(0.5,0.5,cond2_text,'Color','r')
%             text(0.5,0.3,cond3_text,'Color','g')
            saveas(fig, curr_output_filename)
        end
    end
end