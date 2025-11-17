FTR analysis exploration - interim progress and testing
===============================

Files:
--------
There are 2 code files of interset: hilb.m and tfr_3.m fr
In hilb.m I tried to implement Anats pipline "pipelineElla". It need "tfr_output_example" in some parts in order to run.
In tfr_3.m I tried to preform tfr analysis by myself, following ft tutorials

There is also an analysis that was actually implemented in the "funcs_" and "ft_imported" files. It produces a topograpy cluster in a specifiy freq range (see image output_example.png, https://www.fieldtriptoolbox.org/tutorial/cluster_permutation_freq/).


hilb.:
--------
* It seems that hilb.m indeed find some clusters in the time-freq maps, but if I plot the actual amplitudes, it doesnt seems right (run "Similar to clusterElla process" section). There are couple of reasons it might happen: 1. I used matlab fft bandpass filter, instead of "pop_eegfiltnew" that Ella used in her code (Search "pop_eegfiltnew" in hilb.m to see where). 2. There might be an edge-effect, as Ella's code designated to work with 7sec of data, and I analise 0.5s epochs.
* Section "over specific electd" output looks like a progress, but the issue with it is that the "stat" output doesnt include the pos and neg clusters info (and includes only a mask). The test in the section before it ("Similar to clusterElla process" section) procude a stat with the cluster details.




Moving forward: solutions
------------------
If I had more time, I would do it myself - understand which filter should I use given that I have 0.5s epochs and I want to explore 0.5-40Hz. Then, I would use the analysis implemented in  "funcs_" and "ft_imported" to  


 - Use other code Anat sent me that bins the data differently according to the "hilbampToneOdor"
 - Consult an expert (Andres? GalVishne?) - What filter should I use given my epcoch length (-0.1 - 0.5 sec), and what freq range
 - Tottaly do it yourself: see MikeXCohen stuff, and use ft toturials. Notice that ft toturials doesnt include tf maps clustering (but it can be done and you created these kind of tests in the hilb.m file. (under "over specific set of electd, avg sub. Similar to clusterElla process" part )))



Appendix:
----------
MikeXCohen stuff:
https://www.youtube.com/watch?v=7ahrcB5HL0k&list=PLn0OLiymPak2BYu--bR0ADNBJsC4kuRWs&ab_channel=MikeXCohen 

Important issues:
https://www.fieldtriptoolbox.org/faq/why_does_my_output.freq_not_match_my_cfg.foi_when_using_mtmconvol_in_ft_freqanalyis/
https://www.fieldtriptoolbox.org/faq/why_does_my_tfr_look_strange/
https://www.fieldtriptoolbox.org/faq/why_does_my_output.freq_not_match_my_cfg.foi_when_using_wavelet_formerly_wltconvol_in_ft_freqanalyis/