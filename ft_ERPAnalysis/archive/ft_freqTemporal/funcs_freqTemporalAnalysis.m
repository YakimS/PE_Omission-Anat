classdef funcs_freqTemporalAnalysis
    properties (SetAccess = private)
        imp
        electrodes
        time
    end
    methods(Static)
        % constructor
        function f = funcs_freqTemporalAnalysis(imp, electrodes,time)
            f.imp = imp;
            f.electrodes = electrodes;
            f.time = time;
        end

        % get/set
        function s = get_imp(f)
            s = f.imp;
        end
        function s = get_bl(f)
            s = f.bl;
        end
        function s = get_electrodes(f)
            s = f.electrodes;
        end
        function s = get_time(f)
            s = f.time;
        end

        function freqtempoClustPerm_cond1VsCond2_subAvg(f,output_dir, contrasrs)
            for contrast_ind=1:size(contrasrs,2)
                cond1 = contrasrs{contrast_ind}{1};
                cond2 = contrasrs{contrast_ind}{2};

                curr_output_filename = sprintf("%s//%sVs%s_avg.mat",output_dir,cond1,cond2);
                if isfile(curr_output_filename) continue; end
                
                try
                    rawft_cond1 = f.imp.get_cond_grandAvg(f.imp,cond1);
                    rawft_cond2 = f.imp.get_cond_grandAvg(f.imp,cond2);

                    funcs_freqTemporalAnalysis.cluster_dependentT(f,rawft_cond1,rawft_cond2,[-0.1,0.448])
                    
                    %metadata = funcs_spatioTemporalAnalysis.cluster_dependentT(f,rawft_cond1, rawft_cond2,[-0.1,0.45],curr_output_filename,is_plot_topoplot);
                    %save(sprintf("%s/SpatioTempSubAvg_metadata.mat",image_output_dir), "metadata")
                catch ME
                    if strcmp(ME.message,"no clusters present with a p-value lower than the specified alpha, nothing to plot")
                        sprintf("contrast: [%s, %s]: %s",cond1,cond2,ME.message)
                    else
                        ME.message
                        
                    end
                end
            end
        end

    end

    methods(Access=private, Static)

        function metadata = cluster_dependentT(f,cond1_struct,cond2_struct,latency)
            neig = f.imp.get_neighbours(f.imp);
            metadata = {};
            cfg              = [];
            cfg.output       = 'pow';
            cfg.channel      = 'all';
            cfg.method       = 'mtmconvol';
            cfg.taper        = 'hanning';
            cfg.foi          = 2:1:50;                         % analysis 2 to 30 Hz in steps of 2 Hz
            cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.1;   % length of time window = 0.5 sec
            cfg.toi          =  latency(1):0.01: latency(2);                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
            
            cond3_struct = cond1_struct;
            cond3_struct.avg = cond2_struct.avg - cond1_struct.avg;
            TFRhann = ft_freqanalysis(cfg, cond3_struct);
            
            

            cfg = [];
            cfg.baseline     = [-0.1 0];
            cfg.baselinetype = 'absolute';
            %cfg.zlim         = [-5 5];
            cfg.showlabels   = 'yes';
            %cfg.layout       = 'CTF151_helmet.mat';
            %cfg.neighbours  = neighbours; % defined as above
            figure
            ft_multiplotTFR(cfg, TFRhann);


            cfg = [];
            cfg.channel      = 'all';
            cfg.latency          = 'all';
            cfg.frequency        = 20;
            cfg.method           = 'montecarlo';
            cfg.statistic        = 'ft_statfun_indepsamplesT';
            cfg.correctm         = 'cluster';
            cfg.clusteralpha     = 0.05;
            cfg.clusterstatistic = 'maxsum';
            cfg.minnbchan        = 2;
            cfg.tail             = 0;
            cfg.clustertail      = 0;
            cfg.alpha            = 0.025;
            cfg.numrandomization = 500;
            % prepare_neighbours determines what sensors may form clusters
            cfg.method    = 'distance';
            cfg.neighbours       = neig;
            
            subs = f.imp.get_subs(f.imp);
            Nsub = size(subs,2);
%             cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
%             cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
%             
%             cfg.design           = design;
            cfg.ivar             = 1;
            
            [stat] = ft_freqstatistics(cfg, cond1_struct, cond2_struct);

            cfg = [];
            freqFIC_planar_cmb = ft_freqdescriptives(cfg, cond1_struct);
            freqFC_planar_cmb  = ft_freqdescriptives(cfg, cond2_struct);
            Subsequently we add the raw effect (FIC-FC) to the obtained stat structure and plot the largest cluster overlayed on the raw effect.
            
            stat.raweffect = freqFIC_planar_cmb.powspctrm - freqFC_planar_cmb.powspctrm;
            
            cfg = [];
            cfg.alpha  = 0.025;
            cfg.parameter = 'raweffect';
            cfg.zlim   = [-1e-27 1e-27];
            cfg.layout = 'CTF151_helmet.mat';
            ft_clusterplot(cfg, stat);

% 
%             cfg = [];
%             cfg.latency     = latency;
%             Nsub = size(subs,2);
%             cfg.numrandomization = 10000;
%             
%             cfg.neighbours  = neighbours; % defined as above
%             cfg.avgovertime = 'no';
%             cfg.parameter   = 'avg';
%             cfg.method      = 'montecarlo';
%             cfg.statistic   = 'ft_statfun_depsamplesT';
%             cfg.correctm    = 'cluster';
%             cfg.correcttail = 'prob';
%             cfg.minnbchan        = 1;      % minimal number of neighbouring channels
%             
%             cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
%             cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
%             cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
%             cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
%             
%             stat = ft_timelockstatistics(cfg,cond1_struct{:}, cond2_struct{:});
%             save(sprintf("%s",mat_filename), '-struct', 'stat');
%             metadata.ft_timelockstatistics =  stat.cfg;
%         
%             % plot
%             if is_plot_topoplot
%                 timediff = 0.04;
%                 toi = latency(1): timediff :latency(2);
%                 png_filename = erase(mat_filename,".mat");
%                 cfg = funcs_spatioTemporalAnalysis.cluster_plot(stat,toi,png_filename);
%                 metadata.cfg_ft_clusterplot =  cfg;
%             end
        end
        

        function stat = cluster_permu_erp(f,conds,clust_mask,latency)
            subs = f.imp.get_subs(f.imp);
            all_conds_timelocked_currClustElecd = cell(1, size(conds,2));
            for cond_j = 1:size(conds,2)
                curr_cond_timelock = f.imp.get_cond_timelocked(f.imp,conds{cond_j}); 
                for sub_i = 1:size(subs,2)
                    curr_subcond = curr_cond_timelock{sub_i};
                    curr_subcond = rmfield(curr_subcond,'dof');
                    curr_subcond = rmfield(curr_subcond,'var');
                    curr_subcond.label = {'eletd_avg'};
                    if size(clust_mask,2) == 1 % there is only electrodes
                        %curr_subcond.var = std(curr_subcond.avg(clust_mask,:),1,1);
                        curr_subcond.avg = mean(curr_subcond.avg(clust_mask,:),1);
                    else % theres time-electorde
                        avg_clusterMasked = curr_subcond.avg .* clust_mask;
                        sub_clust_activity_mean = sum(avg_clusterMasked,1) ./ sum(avg_clusterMasked~=0,1);
                        curr_subcond.avg = sub_clust_activity_mean;
                    end
                    all_conds_timelocked_currClustElecd{cond_j}{sub_i} = curr_subcond;
                end
            end
        
            % cluster permutation anaslysis 
            % define the parameters for the statistical comparison
            cfg = [];
            cfg.channel     = {'eletd_avg'};
            cfg.latency     = latency;
            cfg.avgovertime = 'no';
            cfg.parameter   = 'avg';
            cfg.method      = 'analytic';
            cfg.statistic   = 'ft_statfun_depsamplesT';
            cfg.alpha       = 0.05;
            cfg.correctm    = 'no';            
            Nsub = size(subs,2);
            cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
            cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
            cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
            cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
            stat = ft_timelockstatistics(cfg, all_conds_timelocked_currClustElecd{1}{:}, all_conds_timelocked_currClustElecd{2}{:});   % don't forget the {:}!
        end
        
        function cfg = cluster_plot(stat,toi,png_filename)
            % make a plot
            cfg = [];
            %cfg.highlightsymbolseries = ['*','.','.','.','.']; %%  (default ['*', 'x', '+', 'o', '.'] for p < [0.01 0.05 0.1 0.2 0.3]
            cfg.highlightsizeseries     = [5,4,4,4,4];  %1x5 vector, highlight marker size series   (default [6 6 6 6 6] for p < [0.01 0.05 0.1 0.2 0.3])
            cfg.zlim = [-5 5];
            cfg.alpha = 0.2; % This is the max alpha to be plotted. (0.3 is the hights value possible)
            cfg.saveaspng = png_filename;
            cfg.visible = 'no';
            cfg.toi =toi;
            cfg = ft_clusterplot(cfg, stat);
        end
    end
end

