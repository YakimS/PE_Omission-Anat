%% args set
args = {};
args.subs = {'08','09','10','11','13','14','15','16','17','19','20','21','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'}; % add 23 to night ones
args.bl = 100;
args.contrasts = {{'O'}};%{{'OFFirst5','ORFirst5'},{'OEf6','ORf6'},{'OF','OR'},{'OEf6','OR'}};
args.pre_vs_post_conds_names = {'O'};%{'OEf5','OEf6','OR','ORf6','OFFirst5','ORFirst5','T','O'};

%% local variables
args.ft_cond_dir= sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\data_in_ft_cond_fomat');
args.output_main_dir = sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm');
args.libs_dir = sprintf('C:\\Users\\User\\Cloud-Drive\\BigFiles\\libs');
args.code_dir = sprintf('C:\\Users\\User\\OneDrive\\Documents\\githubProjects\\PE_Omission-Anat\\ft_ERPAnalysis');

datasets = {"wake_night","wake_morning","N2","N3","REM"};

for dataset_i =1:numel(datasets)
    args.wake_files_name_suffix = datasets{dataset_i};
    save(sprintf("spatioTempoAnaly_run_%s.mat",datasets{dataset_i}),"args",'-mat')
end

%% cluster variables
args.ft_cond_dir= sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//OmissionSleepData//data_in_ft_cond_fomat');
args.output_main_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//AnalysisResults//ft_ERPAnalysis');
args.libs_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//Code//libs');
args.code_dir = sprintf('//sci//labs//arzilab//ykmsharon//OmissionProject//Code//PE_Omission-Anat//ft_ERPAnalysis');

datasets = {"wake_night","wake_morning","N2","N3","REM"};

for dataset_i =1:numel(datasets)
    args.wake_files_name_suffix = datasets{dataset_i};
    save(sprintf("clust_spatioTempoAnaly_run_%s.mat",datasets{dataset_i}),"args",'-mat')
end