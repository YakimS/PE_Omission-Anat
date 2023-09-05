How?

inside ft_ERPAnalysis:

 - Use epoched EEGLAB files (e.g. "referenced")  to create EEGLAB .set files per event (EEGLAB2FT.m)

 - Create FT .mat files per event (EEGLAB2FT.m)

 - Run spatiotemporal analysis

	 - Define variables and create an X.mat analysis running instance (spatioTempoAnaly_runInstant) for each dataset

	 - Run analysis: run_spatioTemporalAnalysis(“path/X.mat”)

		 - You can run in cmd using this command: "C:\Program Files\MATLAB\R2023a\bin\matlab.exe" -nosplash -nodesktop -r "cd('C:\Users\User\OneDrive\Documents\githubProjects\PE_Omission-Anat\ft_ERPAnalysis'), run_spatioTemporalAnalysis('spatioTempoAnaly_run_all.mat'), exit"