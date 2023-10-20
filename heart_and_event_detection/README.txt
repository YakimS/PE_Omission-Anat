 - Use "pipelineMultimodalSniffing.m" to create orig and prepro files from raw files. They include the EGI-EEG data and the rest of the physiological data

Non-eeg analysis:
 - Use "sniff_import.m", section "load for emg, HR, triggers" to create files
 - Use "sniff__.m" to create Non-eeg analysis


 EEG analysis:
 - First run the Non-eeg analysis to create trigger events text file
 - copy "sub-XX_triggerEvents" to triggers_textfile_after_trial_exclusion and remove spesific events
 - Use "sniff_import.m", section "load all: EEG + emg, HR, triggers + events" to create set epoched files
 - Use EEGLAB_2_FT.m to create ft per condition
 - run analysis using run_spatioTemporalAnalysis_notWithinSub