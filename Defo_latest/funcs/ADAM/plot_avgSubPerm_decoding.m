
function plot_avgSubPerm_decoding(mvpa_stats,acclim,title_,save_file_name)
    indi_over_time = mvpa_stats.indivClassOverTime;
    h=figure;
    set(h,'visible','off');
    time = mvpa_stats.settings.times{1};
    shadedErrorBar2(time,mvpa_stats.indivClassOverTime,{@mean,@std},'patchSaturation',0.1)%,'lineprops','-b');
    hold on;
    plot(time,indi_over_time,'Color',[0 ,0, 0, 0.2]);
    hold on;
    plot(time,mvpa_stats.ClassOverTime,'Color',[0, 0, 0, 1]);
    xlim([time(1),time(end)]);
    if acclim ~=0
        ylim(acclim);
    end
    title(title_);
    xlabel("time (s)");
    ylabel("AUC");
    set(gcf,'Position',[100 100 600 300])
    save_plot_and_close_fig(save_file_name)
end
