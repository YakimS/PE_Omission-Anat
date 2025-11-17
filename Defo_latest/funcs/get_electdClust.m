% unionWithinFrontBack_intersectBetweenSovs: 
% In this function I assume that the positive and negative cluster
% in REM are oposite in thire location in other sovs
% conds is a contrast. E.g. {intblkMid, Omi}
% sovs are not of a contrast. The contrasnt is always within the same sov, but then there is an intersection between the clusters in each sov
function electd_clusts=get_electdClust(type,clust_dir,conds,sovs,maxPval)
    electd_clusts = struct();
    if strcmp(type,'simple_contrast')
        try
            clusters_res = load(sprintf("%s\\STCP-ERP_conds-%s+%s_condsSovs-%s+%s_subAvg", ...
                clust_dir,conds{1}.short_s,conds{2}.short_s,sovs{1}.short_s,sovs{2}.short_s));
        catch ME
            if isequal(ME.identifier,"MATLAB:load:couldNotReadFile")
                fprintf("%s\n",ME.message);
                return
            else
                throw(ME)
            end
        end

        clusters_res = clusters_res.metadata.stat;
        for pos_neg_ind=1:2
            if pos_neg_ind ==1
                clusters_posneg = {clusters_res.posclusters.prob};
                clust_mask = clusters_res.posclusterslabelmat;
                curr_posneg_string = 'pos';
            else
                clusters_posneg = {clusters_res.negclusters.prob};
                clust_mask = clusters_res.negclusterslabelmat;
                curr_posneg_string= 'neg';
            end

            % get pos or neg clusters
            curr_posneg_clusts_toplot = {}; 
            for clust_ind=1:size(clusters_posneg,2)
                if clusters_posneg{clust_ind} > maxPval continue;  end
                % get time-electrode mask for current cluster
                curr_clust_mask = clust_mask;
                curr_clust_mask(curr_clust_mask~=clust_ind) = 0;
                curr_clust_mask(curr_clust_mask ~= 0) = 1;
                temp = mean(curr_clust_mask,2);
                clust_electd = find(temp>0);
                
                if ~isempty(clust_electd)
                    clust = struct();
                    clust.('short_s') =  sprintf("%s+%s-%s+%s-%s-%d",conds{1}.short_s,conds{2}.short_s,sovs{1}.short_s,sovs{2}.short_s,curr_posneg_string,clust_ind);
                    clust.('long_s') =  sprintf("%s+%s-%s+%s-%s-%d",conds{1}.long_s,conds{2}.long_s,sovs{1}.long_s,sovs{2}.long_s,curr_posneg_string,clust_ind);
                    clust.('elect_label')  = clusters_res.elec.label(clust_electd);
                    clust.('pval') = clusters_posneg{clust_ind};
                    electd_clusts.(sprintf('%s_%d',curr_posneg_string,clust_ind)) = clust;
                    
                end
            end
            electd_clusts.('elec_gen_info') = clusters_res.elec;
        end                
    elseif strcmp(type,'unionWithinFrontBack_intersectBetweenSovs')
        electd_clusts = struct();
        pos_elct_clust = struct();
        neg_elct_clust = struct();

        % get neg and pos union electrodes clusters
        for sov_i=1:numel(sovs)
            curr_sov_electd_clusts=get_electdClust('simple_contrast',clust_dir,conds,{sovs{sov_i},sovs{sov_i}});

            union_pos = [];
            union_neg = [];
            fields = fieldnames(curr_sov_electd_clusts);
            for i = 1:length(fields)
                if contains(fields{i}, 'pos')
                    union_pos = union(union_pos, curr_sov_electd_clusts.(fields{i}).('elect'));
                elseif contains(fields{i}, 'neg')
                    union_neg = union(union_neg, curr_sov_electd_clusts.(fields{i}).('elect'));
                end
            end

            pos_elct_clust.(sovs{sov_i}.short_s) = union_pos;
            neg_elct_clust.(sovs{sov_i}.short_s) = union_neg;
            electd_clusts.('elec_gen_info') = curr_sov_electd_clusts.('elec_gen_info');
        end
        
        % get back cluster electrodes
        back_elct_clust = [];
        front_elct_clust = [];
        fields = fieldnames(neg_elct_clust);
        for i = 1:length(fields)
            if contains(fields{i}, 'REM') continue;  end
            if isempty(neg_elct_clust.(fields{i})) continue; end
            if isempty(back_elct_clust)
                back_elct_clust = neg_elct_clust.(fields{i});
            else
                back_elct_clust = intersect(back_elct_clust, neg_elct_clust.(fields{i}));
            end
        end
        if isfield(pos_elct_clust,'REM') && ~isempty(pos_elct_clust.('REM'))
            if isempty(back_elct_clust)
                back_elct_clust = pos_elct_clust.('REM');
            else
                back_elct_clust = intersect(back_elct_clust, pos_elct_clust.('REM'));
            end
        end

        % get front cluster electrodes
        fields = fieldnames(pos_elct_clust);
        for i = 1:length(fields)
            if contains(fields{i}, 'REM') continue;  end
            if isempty(pos_elct_clust.(fields{i})) continue; end
            if isempty(front_elct_clust)
                front_elct_clust = pos_elct_clust.(fields{i});
            else
                front_elct_clust = intersect(front_elct_clust, pos_elct_clust.(fields{i}));
            end
        end
        if isfield(neg_elct_clust,'REM') && ~isempty(neg_elct_clust.('REM'))
            if isempty(front_elct_clust)
                front_elct_clust = neg_elct_clust.('REM');
            else
                front_elct_clust = intersect(front_elct_clust, neg_elct_clust.('REM'));
            end
        end

        % get sovs_string
        sovs_string = "";
        for s_i=1:numel(sovs)
            if strcmp(sovs_string,"")
                sovs_string =sovs{s_i}.short_s;
            else
                sovs_string = sprintf("%s+%s",sovs_string,sovs{s_i}.short_s);
            end
        end

        if ~isempty(back_elct_clust)
            clust = struct();
            clust.('short_s') =  sprintf("%s+%s-%s-back",conds{1}.short_s,conds{2}.short_s,sovs_string);
            clust.('long_s') =  sprintf("%s+%s-%s-back",conds{1}.long_s,conds{2}.long_s,sovs_string);
            % clust.('elect_label') = ADD!
            electd_clusts.('back') = clust;
        end
        if ~isempty(front_elct_clust)
            clust = struct();
            clust.('short_s') =  sprintf("%s+%s-%s-front",conds{1}.short_s,conds{2}.short_s,sovs_string);
            clust.('long_s') =  sprintf("%s+%s-%s-front",conds{1}.long_s,conds{2}.long_s,sovs_string);
            % clust.('elect_label') = ADD!
            electd_clusts.('front') = clust;
        end
    end
end
