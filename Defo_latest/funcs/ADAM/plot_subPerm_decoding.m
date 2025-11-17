function plot_subPerm_decoding(mvpa_stats,acclim,title_,save_file_name_prefix)
    indi_over_time = mvpa_stats.indivClassOverTime;
    pvals_indi_over_time = mvpa_stats.pvalsOverTime;
    time = mvpa_stats.settings.times{1};
    
    for subj_i=1:size(indi_over_time,1) % for each subj
        h=figure;
        % set(h,'visible','off');
        % plot(time, indi_over_time(subj_i,:),'Color',[0, 0, 0, 1]); % Plot the line
        % hold on;
        shadedErrorBar2(time,mvpa_stats.indivClassOverTime_allPerm.(sprintf('sub_%d',subj_i)),{@mean,@std},'patchSaturation',0.1)%,'lineprops','-b');
        hold on;

        subj_neg_clust = mvpa_stats.permu_pstruct_per_sub.(sprintf('sub_%d_neg',subj_i));
        for clust_i=1:size(subj_neg_clust,2)
            start_time_sec = subj_neg_clust(clust_i).start_time/1000;
            startIndex = find(abs(time - start_time_sec) < 1e-10);
            end_time_sec = subj_neg_clust(clust_i).stop_time/1000;
            [~, endIndex] = find(abs(time - end_time_sec) < 1e-10);
            hold on;
            plot(time(startIndex:endIndex), indi_over_time(subj_i,startIndex:endIndex), 'k','LineWidth',6);
        end
        
        subj_pos_clust = mvpa_stats.permu_pstruct_per_sub.(sprintf('sub_%d_pos',subj_i));
        for clust_i=1:size(subj_pos_clust,2)
            start_time_sec = subj_pos_clust(clust_i).start_time/1000;
            startIndex = find(abs(time - start_time_sec) < 1e-10);
            end_time_sec = subj_pos_clust(clust_i).stop_time/1000;
            [~, endIndex] = find(abs(time - end_time_sec) < 1e-10);
            hold on;
            plot(time(startIndex:endIndex), indi_over_time(subj_i,startIndex:endIndex), 'k','LineWidth',6);
        end
        

        xlim([time(1),time(end)]);
        if acclim ~=0
            ylim(acclim);
        end
        title(sprintf("%s, subINDEX-%d",title_{1}, subj_i));
        xlabel("time (s)");
        ylabel("AUC");
        set(gcf,'Position',[100 100 600 300]);
        save_file_name = sprintf('%s_subINDEX-%d',save_file_name_prefix,subj_i);
        save_plot_and_close_fig(save_file_name);
    end
end


function save_plot_and_close_fig(file_name)
%     saveas(gcf, sprintf("%s\\%s.fig", folder, file_name));
%     saveas(gcf, sprintf("%s\\%s.svg", folder, file_name));
    saveas(gcf, sprintf("%s.png", file_name));
    close(gcf);
end
