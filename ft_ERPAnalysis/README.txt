How?

inside ft_ERPAnalysis:
 - 1. Create ft files per sub_sov_cond
    Are the files preprocessed? (filtered & epoched etc.)
     - If yes:
        1.1 Use "eeglab2ft_bigFiles.m" to change eeglab .set files to ft .mat files
        1.2 Use "EEGLAB_mat_for_event_sub_paral.m" to create ft files per sub_sov_cond
     - If no:
        1.1  Use "re_preprocessing_after17NovInsight.m" to create ft files per sub_sov_cond from "imported" .set files
 - 2. Run spatiotemporal analysis
     - 

    