addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs'
eeglab nogui;
%%
referenced_preproce_name =  'referenced';
referenced_filename_ses_types = {'wake_morning','wake_night'};
referenced_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\mix_modeling\graphs';
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
subs = {'08','09'};

%% load the two clusters electrodes
clustering_res = load ('C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ft_erpAnalysis\spatiotemp_clusterPerm\wake_morning\preStim_Vs_postStim\preVsPoststim_bl-100_O_avg.mat');
posClustElect = find(any(clustering_res.posclusterslabelmat == 1, 2));
negClustElect = find(any(clustering_res.negclusterslabelmat == 1, 2));
%% 
%columns = {'sub','ses','timeWin','trialID','block_type','seniority','blockpos','opos','ampAvg_pos','ampAvg_neg'};

variables_name = {'omission_type_seniority','tone_pos_in_trial','sleep_stage','block_pos_in_file','block_type'};
variables = {num2cell(1:11),num2cell(6:10),referenced_filename_ses_types,num2cell(1:24),{'fixed','random'}};
sess = referenced_filename_ses_types; %{'wake_morning','wake_night'};

for var_i = 1:numel(variables_name)
    curr_variable_name = variables_name{var_i};
    curr_variable = variables{var_i};
    
    subs_avgErp_var_pos = zeros([numel(subs),138,numel(curr_variable)]);
    subs_avgErp_var_neg = zeros([numel(subs),138,numel(curr_variable)]);
    for sub_i=1:numel(subs)
        currSub_erps_var_pos = struct(); % 
        currSub_erps_var_neg = struct(); %zeros([138,numel(wanted_variable),0]);
        for ses_i=1:numel(sess) 
            curr_ses = sess{ses_i};
            curr_sub = subs{sub_i};
            try 
                % get referenced file
                set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_ses,referenced_preproce_name);
                event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents.mat',referenced_elaboEvents_dir,curr_sub,curr_ses,referenced_preproce_name);
                if isfile(set_filename)
                    eeglab_referenced =  pop_loadset(set_filename);
                    elaborated_events = load(event_mat_filename);
                    elaborated_events = elaborated_events.events;
                end
                got_files = true;
            catch ME
                strcat('could not get' ,set_filename)
                strcat('or' ,event_mat_filename)
                got_files = false;
            end
            if strcmp(subs{sub_i},'23') && strcmp(sess{ses_i},'wake_morning')
                continue;
            end
            if ~got_files  continue;  end
    
            for val_i=1:numel(curr_variable)
                if isnumeric(curr_variable{val_i})
                    if strcmp("omission_type_seniority",curr_variable_name)
                        if curr_variable{val_i} <=10
                            indexes_value = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                            & [elaborated_events.(curr_variable_name)] == curr_variable{val_i});
                        elseif curr_variable{val_i} > 10
                            indexes_value = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                            & [elaborated_events.(curr_variable_name)] > 10);
                        end
                    else
                        indexes_value = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                        & [elaborated_events.(curr_variable_name)] == curr_variable{val_i});
                    end
                else
                    indexes_value = find( strcmp({elaborated_events.('TOA')},'O')  == 1 ...
                    & strcmp({elaborated_events.(curr_variable_name)},curr_variable{val_i}));
                end
    
                pos_clust_activity = eeglab_referenced.data(posClustElect,:,indexes_value);
                neg_clust_activity = eeglab_referenced.data(negClustElect,:,indexes_value);
                
    
                mean_pos_clust_activity = squeeze(mean(pos_clust_activity,1));
                mean_neg_clust_activity = squeeze(mean(neg_clust_activity,1));
    
                curr_var_val_name = curr_variable{val_i};
                if isnumeric(curr_var_val_name)
                    if strcmp("omission_type_seniority",curr_variable_name) && curr_variable{val_i} > 10
                        curr_var_val_name = sprintf("f%s", "11");
                    end
                    curr_var_val_name = sprintf("f%s", num2str(curr_var_val_name));
                end

                if ~isfield(currSub_erps_var_pos, curr_var_val_name)
                    currSub_erps_var_pos.(curr_var_val_name) = zeros([138,0]);                
                end
    
                if ~isfield(currSub_erps_var_neg, curr_var_val_name)
                    currSub_erps_var_neg.(curr_var_val_name) = zeros([138,0]);                
                end
                currSub_erps_var_neg.(curr_var_val_name) = [currSub_erps_var_neg.(curr_var_val_name).'; mean_neg_clust_activity.'];
                currSub_erps_var_neg.(curr_var_val_name) = currSub_erps_var_neg.(curr_var_val_name).';
                currSub_erps_var_pos.(curr_var_val_name) = [currSub_erps_var_pos.(curr_var_val_name).'; mean_pos_clust_activity.'];
                currSub_erps_var_pos.(curr_var_val_name) = currSub_erps_var_pos.(curr_var_val_name).';
            end
        end
    
        for val_i=1:numel(curr_variable)
            curr_var_val_name = curr_variable{val_i};
            if isnumeric(curr_var_val_name)
                if strcmp("omission_type_seniority",curr_variable_name) && curr_variable{val_i} > 10
                    curr_var_val_name = sprintf("f%s", "11");
                end
                curr_var_val_name = sprintf("f%s", num2str(curr_var_val_name));
            end

            curr_mean = squeeze(mean(currSub_erps_var_pos.(curr_var_val_name),2));
            subs_avgErp_var_pos(sub_i,:,val_i) =curr_mean;
            curr_mean = squeeze(mean(currSub_erps_var_neg.(curr_var_val_name),2));
            subs_avgErp_var_neg(sub_i,:,val_i) =curr_mean;
        end
    end

    %%%%%%%   plot
    clusts_res = {subs_avgErp_var_neg,subs_avgErp_var_pos};
    time = eeglab_referenced.times;
    for k=1:numel(clusts_res)
        curr_clust_res = clusts_res{k};
        if curr_clust_res == subs_avgErp_var_neg
            curr_clust_name = 'neg';
        else
            curr_clust_name = 'pos';
        end
        
        curr_output_filename = sprintf('%s//var_%s_%s.png',output_dir, curr_variable_name,curr_clust_name);
        figure();
        cc = winter(numel(curr_variable));
        one_div_sqrt_samp_size = 1/sqrt(size(subs,2));
        for val_i=1:numel(curr_variable)
            curr_var_val_name = curr_variable{val_i};
            if isnumeric(curr_var_val_name)
                curr_var_val_name = sprintf("f%s", num2str(curr_var_val_name));
            end
            if numel(curr_variable)>5
                mean_subs = squeeze(mean(curr_clust_res(:,:,val_i),1));
                plot(time,mean_subs,'Color',cc(val_i,:),'DisplayName',sprintf("%s",curr_var_val_name))
            else
                x = squeeze(curr_clust_res(:,:,val_i));
                shadedErrorBar(time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',cc(val_i,:),'DisplayName',sprintf("%s",curr_var_val_name)},'patchSaturation',0.2);
            end
            hold on;
        end
        title_add = "";
        if isnumeric(curr_variable{1})
            title_add = " ,blue<green";
        end
        title(sprintf("Subject Avg ERP, cluster =%s \n variable: %s%s",curr_clust_name,curr_variable_name,title_add));
        if numel(curr_variable)<=5
            legend("Location","northwest","FontSize",10);
        end
        
        if strcmp(curr_clust_name, 'pos') 
            axis([time(1) time(end) -1.6 1.6]) %axis([time(1) time(end) -1 1.5])
        else
            axis([time(1) time(end) -1.6 1.6]) %axis([time(1) time(end) -1 1.5])
        end
        xlabel('Time (s)')
        ylabel('µV')
        saveas(gcf, curr_output_filename)
    end
end
