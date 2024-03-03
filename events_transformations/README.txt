If I remember correctly, as I document it months after the creation:

"save_event_files_seperately" just saves the event mat seperatly from the set files. Creates "\\s_%s_%s_%s_events.mat"
"connect_epoched_and_nonepoched_events.mlx" to give each non-epoched event id, and then assosiate each epoched events with the id's. to create "s_..._epochedID+sleepFile" files
"event_elaboration" - creates elaboaration for the imported files & use the elaborated imported to create elaboration also for the epoched ("referenced"). Creates "\s_%s_%s_%s_elaboEvents.mat" 


I found a doc somewhere:
- save_event_files_seperately.mlx to save the event mat separately from the set files.
 - connect_epoched_and_nonepoched_events.mlx to give each non-epoched event id, and then assosiate each epoched events with the id's
 - event_elaboration.mlx to create events mats with more info per event