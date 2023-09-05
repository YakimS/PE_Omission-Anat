addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs\eeglab2023.0'
addpath 'C:\Users\User\Cloud-Drive\BigFiles\libs'
eeglab nogui;

%%
%%% "graphs.m" - 2 graphs (pos and neg cluster) per variable. sov is a variable
    % I think it can be discarded as graphs_sleep.m contains all these options
%%% No sure, but it seems that graphs_OE6OR6.m suppose to be the same as graphs.m but when theres only 1 cluster (neg)
%%
referenced_preproce_name =  'referenced';
referenced_set_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced';
output_dir = 'C:\Users\User\Cloud-Drive\BigFiles\OmissionExpOutput\ERP_graphs';
referenced_elaboEvents_dir = 'C:\Users\User\OneDrive - huji.ac.il\AnatArzData\Data\rerefrenced\elaborated_events+outliers';
subs = {'08','09','10','11','13','14','15','16','17','19','20','21','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38'};
%% Cond between states of vigilance
sovs = {'wake_morning','wake_night','N1','N2','N3','REM'};
sovs = {'wake_night','N2','N3','REM'};

variable = 'TOA';
value = 'O';

sovs_var_name = 'sleep_stage';
for j=1:2
    if j==1
        O_clust_per_sov = false;
        curr_sovs = sovs;
    else
        O_clust_per_sov = true;
        curr_sovs = setdiff(sovs, {'N3','N1'});
    end
    
    subs_avgErp_var_pos = zeros([numel(subs),138,numel(curr_sovs)]);
    subs_avgErp_var_neg = zeros([numel(subs),138,numel(curr_sovs)]);
    for sub_i=1:numel(subs)
        curr_sub = subs{sub_i};
        currSub_erps_var_pos = struct(); % 
        currSub_erps_var_neg = struct(); %zeros([138,numel(wanted_variable),0]);
        for sov_i=1:numel(curr_sovs)
            % get set file
            if func_is_sov_sleep(curr_sovs{sov_i})
                curr_file_ses = 'sleep';
            else
                curr_file_ses = curr_sovs{sov_i};
            end
            if strcmp(curr_sub,'23') && strcmp(curr_sovs{sov_i},'wake_morning') ...
                || strcmp(curr_sub,'37') && strcmp(curr_sovs{sov_i},'wake_night')
                continue;
            end
            if ~(func_is_sov_sleep(curr_sovs{sov_i}) && sov_i>1 && func_is_sov_sleep(curr_sovs{sov_i-1}))
                try 
                    set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_file_ses,referenced_preproce_name);
                    event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents+outliers.mat',referenced_elaboEvents_dir,curr_sub,curr_file_ses,referenced_preproce_name);
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
                if ~got_files  continue;  end
            end
            
            if O_clust_per_sov
                clustering_res = load(sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\preStim_Vs_postStim\\preVsPoststim_bl-100_O_avg.mat",curr_sovs{sov_i}));
            else
                clustering_res = load(sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\preStim_Vs_postStim\\preVsPoststim_bl-100_O_avg.mat",'wake_morning'));
            end
            
            posClustElect = find(any(clustering_res.posclusterslabelmat == 1, 2));
            negClustElect = find(any(clustering_res.negclusterslabelmat == 1, 2));
    
            % get the indexes of the current variable value for this ses and sub
            if  strcmp(curr_sovs{sov_i}, "REM")
                sov_indexs = strcmp({elaborated_events.("sleep_stage")},"Rt") | strcmp({elaborated_events.("sleep_stage")},"Rp");
            else
                sov_indexs = strcmp({elaborated_events.("sleep_stage")},curr_sovs{sov_i});
            end
    
            if isnumeric(value)
                specific_cond_indexs = [elaborated_events.(variable)] == value;
            else
                specific_cond_indexs = strcmp({elaborated_events.(variable)},value);
            end
    
            indexes_value = find(specific_cond_indexs & ...
                [elaborated_events.('is_outlier_trial')] == 0 & ...
                strcmp({elaborated_events.('TOA')},'O')  == 1 & ...
                sov_indexs);
    
            if isempty(indexes_value) fprintf("big problem?");  end
    
    
            % get the data of these indexes in the cluster electodes
            pos_clust_activity = eeglab_referenced.data(posClustElect,:,indexes_value);
            neg_clust_activity = eeglab_referenced.data(negClustElect,:,indexes_value);
            
            mean_pos_clust_activity = squeeze(mean(pos_clust_activity,1, 'omitnan'));
            mean_neg_clust_activity = squeeze(mean(neg_clust_activity,1, 'omitnan'));
    
            curr_var_val_name = curr_sovs{sov_i};
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
    
        % for each value, save mean over the subjects
        for sov_i=1:numel(curr_sovs)
            if strcmp(curr_sub,'23') && strcmp(curr_sovs{sov_i},'wake_morning') ...
                || strcmp(curr_sub,'37') && strcmp(curr_sovs{sov_i},'wake_night')
                continue;
            end
            curr_var_val_name = curr_sovs{sov_i};
            curr_mean = squeeze(mean(currSub_erps_var_pos.(curr_var_val_name),2, 'omitnan'));
            subs_avgErp_var_pos(sub_i,:,sov_i) =curr_mean;
            curr_mean = squeeze(mean(currSub_erps_var_neg.(curr_var_val_name),2, 'omitnan'));
            subs_avgErp_var_neg(sub_i,:,sov_i) =curr_mean;
        end
    end

    %%%%%%%   plot each cluster
    time = eeglab_referenced.times;
    custom_colormap = get_colormap_for_sovs(curr_sovs);
    
    if O_clust_per_sov
        O_clust_per_sov_text = "OPerSov";
    else
        O_clust_per_sov_text = "Owmorning";
    end
    
    curr_clust_name = 'neg';
    curr_output_filename = sprintf('%s//ERP_within-%s=%s_var-sovs_%s-%s.png',output_dir,variable,value,O_clust_per_sov_text,curr_clust_name);
    plot_erps(time,subs,curr_sovs,sovs_var_name,subs_avgErp_var_neg,curr_clust_name,curr_output_filename,custom_colormap);
    
    curr_clust_name = 'pos';
    curr_output_filename = sprintf('%s//ERP_within-%s=%s_var-sovs_%s-%s.png',output_dir,variable,value,O_clust_per_sov_text,curr_clust_name);
    plot_erps(time,subs,curr_sovs,sovs_var_name,subs_avgErp_var_pos,curr_clust_name,curr_output_filename,custom_colormap);
end

%% Within state of vigilance
sovs = {'wake_morning','wake_night','N2','REM','N1','N3'};

variables_name = {'omission_type_seniority','tone_pos_in_trial','block_pos_in_file','block_type'};
variables = {num2cell(1:11),num2cell(6:10),num2cell(1:24),{'fixed','random'}};

sovs = {'N2'} ;
% variables_name = {'block_type'};
% variables = {{'fixed','random'}};

for j=1:2
    if j==1
        O_clust_per_sov = true;
       
    else
        O_clust_per_sov = false;
    end
    for sov_i =1:numel(sovs)
        curr_sov = sovs{sov_i};
        if O_clust_per_sov && (strcmp(curr_sov,'N3')||strcmp(curr_sov,'REM'))
            continue;
        end
        
        for var_i = 1:numel(variables_name)
            curr_variable_name = variables_name{var_i};
            curr_variable = variables{var_i};
            
            subs_avgErp_var_pos = zeros([numel(subs),138,numel(curr_variable)]);
            subs_avgErp_var_neg = zeros([numel(subs),138,numel(curr_variable)]);
        
            for sub_i=1:numel(subs)
                curr_sub = subs{sub_i};
                currSub_erps_var_pos = struct(); 
                currSub_erps_var_neg = struct();
        
                if func_is_sov_sleep(curr_sov)
                    curr_file_ses = 'sleep';
                else
                    curr_file_ses = curr_sov;
                end
                if strcmp(curr_sub,'23') && strcmp(curr_file_ses,'wake_morning')
                    continue;
                end
                
                try 
                    % get referenced file
                    set_filename = sprintf('%s\\s_%s_%s_%s.set',referenced_set_dir,curr_sub,curr_file_ses,referenced_preproce_name);
                    event_mat_filename = sprintf('%s\\s_%s_%s_%s_elaboEvents+outliers.mat',referenced_elaboEvents_dir,curr_sub,curr_file_ses,referenced_preproce_name);
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
                if ~got_files  continue;  end
    
    
                if O_clust_per_sov
                    clustering_res = load (sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\preStim_Vs_postStim\\preVsPoststim_bl-100_O_avg.mat",curr_sov));
                else
                    clustering_res = load (sprintf("C:\\Users\\User\\Cloud-Drive\\BigFiles\\OmissionExpOutput\\ft_erpAnalysis\\spatiotemp_clusterPerm\\%s\\preStim_Vs_postStim\\preVsPoststim_bl-100_O_avg.mat",'wake_morning'));
                end
                posClustElect = find(any(clustering_res.posclusterslabelmat == 1, 2));
                negClustElect = find(any(clustering_res.negclusterslabelmat == 1, 2));
        
                for val_i=1:numel(curr_variable)
                    % get the indexes of the current variable value for this ses and sub
                    if  strcmp(curr_sov, "REM")
                        sov_indexs = strcmp({elaborated_events.("sleep_stage")},"Rt") | strcmp({elaborated_events.("sleep_stage")},"Rp");
                    else
                        sov_indexs = strcmp({elaborated_events.("sleep_stage")},curr_sov);
                    end
                    if isnumeric(curr_variable{val_i})
                        if strcmp("omission_type_seniority",curr_variable_name)
                            if curr_variable{val_i} <=10
                                specific_cond_indexs = [elaborated_events.(curr_variable_name)] == curr_variable{val_i};
                            elseif curr_variable{val_i} > 10
                                specific_cond_indexs =[elaborated_events.(curr_variable_name)] > 10;
                            end
                        else
                            specific_cond_indexs = [elaborated_events.(curr_variable_name)] == curr_variable{val_i};
                        end
                    else
                        specific_cond_indexs = strcmp({elaborated_events.(curr_variable_name)},curr_variable{val_i});
                    end
        
                    indexes_value = find(specific_cond_indexs & ...
                        [elaborated_events.('is_outlier_trial')] == 0 & ...
                        strcmp({elaborated_events.('TOA')},'O')  == 1 & ...
                        sov_indexs);
        
                    if isempty(indexes_value) 
                        fprintf("big problem?");  
                    end
        
                    % get the data of these indexes in the cluster electodes
                    pos_clust_activity = eeglab_referenced.data(posClustElect,:,indexes_value);
                    neg_clust_activity = eeglab_referenced.data(negClustElect,:,indexes_value);
                    
                    mean_pos_clust_activity = squeeze(mean(pos_clust_activity,1, 'omitnan'));
                    mean_neg_clust_activity = squeeze(mean(neg_clust_activity,1, 'omitnan'));
        
                    curr_var_val_name = sprintf("v%s",num2str(curr_variable{val_i}));
                    if strcmp("omission_type_seniority",curr_variable_name) && curr_variable{val_i} > 10
                        curr_var_val_name = "v11";
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
            
                % for each value, save mean over the subjects
                for val_i=1:numel(curr_variable)
                    curr_var_val_name = sprintf("v%s",num2str(curr_variable{val_i}));
                    if strcmp("omission_type_seniority",curr_variable_name) && str2num(strrep(curr_var_val_name, 'v', '')) > 10
                        curr_var_val_name = "v11";
                    end
                    curr_mean = squeeze(mean(currSub_erps_var_pos.(curr_var_val_name),2, 'omitnan'));
                    subs_avgErp_var_pos(sub_i,:,val_i) =curr_mean;
                    curr_mean = squeeze(mean(currSub_erps_var_neg.(curr_var_val_name),2, 'omitnan'));
                    subs_avgErp_var_neg(sub_i,:,val_i) =curr_mean;
                end
            end
            

            %%%%%%%   plot each cluster
            time = eeglab_referenced.times;
        
            curr_colormap = get_colormap_for_sov(curr_sov,numel(curr_variable));
    
            if O_clust_per_sov
                O_clust_per_sov_text = "OPerSov";
            else
                O_clust_per_sov_text = "Owmorning";
            end
        
            curr_clust_name = 'neg';
            curr_output_filename = sprintf('%s//ERP_within-sov=%s_var-%s_%s-%s.png',output_dir, curr_sov, curr_variable_name,O_clust_per_sov_text,curr_clust_name);
            plot_erps(time,subs,curr_variable,curr_variable_name,subs_avgErp_var_neg,curr_clust_name,curr_output_filename,curr_colormap);
            curr_clust_name = 'pos';
            curr_output_filename = sprintf('%s//ERP_within-sov=%s_var-%s_%s-%s.png',output_dir, curr_sov, curr_variable_name,O_clust_per_sov_text,curr_clust_name);
            plot_erps(time,subs,curr_variable,curr_variable_name,subs_avgErp_var_pos,curr_clust_name,curr_output_filename,curr_colormap);
        end
    end
end

%%
function plot_erps(time,subs,curr_variable,curr_variable_name,curr_clust_res,curr_clust_name,curr_output_filename, custom_colormap)
    figure();
    one_div_sqrt_samp_size = 1/sqrt(size(subs,2));
    for val_i=1:numel(curr_variable)
        curr_var_val_name = num2str(curr_variable{val_i});
        if numel(curr_variable)>5 && ~strcmp(curr_variable_name,'sleep_stage')
            mean_subs = squeeze(mean(curr_clust_res(:,:,val_i),1, 'omitnan'));
            plot(time,mean_subs,'Color',custom_colormap(val_i,:),'DisplayName',curr_var_val_name);
        else
            x = squeeze(curr_clust_res(:,:,val_i));
            shadedErrorBar(time,x,{@mean, @(x) one_div_sqrt_samp_size*std(x)},'lineprops',{'Color',custom_colormap(val_i,:),'DisplayName',curr_var_val_name},'patchSaturation',0.1);
        end
        hold on;
    end
    title_add = "";
    title(sprintf("%d Subject Avg ERP, %s cluster =Activity vs baseline \n variable: %s%s",numel(subs),curr_clust_name,curr_variable_name,title_add));
    if numel(curr_variable)<=5
        legend("Location","northwest","FontSize",10);
    end
    
    if strcmp(curr_clust_name, 'pos') 
        legend("Location","southwest","FontSize",10);
        axis([time(1) time(end) -0.8 0.4]) %axis([time(1) time(end) -1 1.5])
    else
        legend("Location","northwest","FontSize",10);
        axis([time(1) time(end) -0.4 0.8]) %axis([time(1) time(end) -1 1.5])
    end
    xlabel('Time (s)')
    ylabel('µV')
    saveas(gcf, curr_output_filename)
    close;
end

function is_sov_sleep=func_is_sov_sleep(sov)
    if strcmp(sov, 'wake_night') || strcmp(sov, 'wake_morning')
        is_sov_sleep = false;
    else
        is_sov_sleep = true;
    end
end

function custom_colormap = get_colormap_for_sovs(sovs)
    % Initialize the colormap cell array
    custom_colormap = zeros(numel(sovs),3);

    % Loop over each sleep stage in the input cell array
    for i = 1:numel(sovs)
        % Get the colormap for the current sleep stage with one shade
        custom_colormap(i,:) = get_colormap_for_sov(sovs{i}, 1);
    end
end

function custom_colormap = get_colormap_for_sov(sov, num_shades)
    % Define the color dictionary
    color_dict = containers.Map(...
        {'wake_morning', 'wake_night', 'N2', 'N3', 'REM', 'N1'}, ...
        {[0.5, 0.8, 1], [0, 0, 1], [1, 0.8, 0], [0, 1, 0], [1, 0, 0], [1, 0, 1]} ...
    );

    % Get the RGB color from the dictionary
    if isKey(color_dict, sov)
        color_ = color_dict(sov);
        custom_colormap = create_custom_colormap(color_, num_shades);
    else
        error('Invalid sleep stage. Supported sleep stages are: wake_morning, wake_night, N2, N3, REM, N1');
    end
end

function custom_colormap = create_custom_colormap(color_, num_shades)
    % Create a colormap with the specified number of shades
    custom_colormap = zeros(num_shades, 3);
    
    % Linearly interpolate each color component (R, G, B) independently
    for i = 1:3
        custom_colormap(:, i) = linspace(0, color_(i), num_shades);
    end
end




