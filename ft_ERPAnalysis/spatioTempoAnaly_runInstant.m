%% args set
args = {};
args.subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; % add 23 to night ones
args.bl = 100;
args.contrasts = {{'OFFirst5','ORFirst5'}};%{{'OFFirst5','ORFirst5'},{'OEf6','ORf6'},{'OF','OR'},{'OEf6','OR'}};
args.pre_vs_post_conds_names = {'OFFirst5'};%{'OEf5','OEf6','OR','ORf6','OFFirst5','ORFirst5','T','O'};

%% local variables
args.ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat');
args.output_main_dir = sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm');
args.libs_dir = sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\libs');
args.code_dir = sprintf('C:\\Users\\User\\OneDrive\\Documents\\githubProjects\\PE_Omission-Anat\\ft_ERPAnalysis');
save(sprintf("%s\\spatioTempoAnaly_run_all.mat",args.code_dir),"args",'-mat')
args.wake_files_name_suffix = 'wake_morning_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save(sprintf("%s\\spatioTempoAnaly_run_morning.mat",args.code_dir),"args",'-mat')
args.wake_files_name_suffix = 'wake_night_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save(sprintf("%s\\spatioTempoAnaly_run_night.mat",args.code_dir),"args",'-mat')

%% cluster variables
args.ft_cond_dir= sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//OmissionSleepData//data_in_ft_cond_fomat');
args.output_main_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//AnalysisResults//ft_ERPAnalysis');
args.libs_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//Code//libs');
args.code_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//Code//PE_Omission-Anat//ft_ERPAnalysis');
args.wake_files_name_suffix = 'wake_all_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save(sprintf("clust_spatioTempoAnaly_run_all.mat"),"args",'-mat')
args.wake_files_name_suffix = 'wake_morning_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save(sprintf("clust_spatioTempoAnaly_run_morning.mat"),"args",'-mat')
args.wake_files_name_suffix = 'wake_night_referenced'; %wake_morning_referenced, wake_night_referenced, wake_all_referenced
save(sprintf("clust_spatioTempoAnaly_run_night.mat"),"args",'-mat')