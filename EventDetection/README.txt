Process:

 -  Run "imported" files in convertSetFile2mat_preEpoched_EventDetection.mlx.
    With these parameters:
    electrodesPSG_names = {'Fp1','Fp2','C3','C4','O1', 'O2','F3', 'F4', 'P3', 'P4', 'Cz'};
    linked mastoid reference
    bandpass
 - Use Import_eeglab_nonEpoched_data.ipynb to create a .pkl file
 - Use eventDetection.ipynb to create .csv files of events, or to compare between parameters of detection
 - Use assignSleepEventsToEEGLAB.mlx to assign detected events to EEGLAB format events table of -epoched- .set files