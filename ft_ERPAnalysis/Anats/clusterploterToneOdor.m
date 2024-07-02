function clusterploterToneOdor(basename1,basename2,basename3,wind1, wind2,compkind,startFreq,folder,loc, trend,direction)

% trend - if the p value is not significant but only a trend
% direction = 'pos'  or 'neg'
loadpathsToneOdor

stats = load([filepath '/tone odor conditioning/hilbert/zscore' loc 'results/' folder basename3], 'stats');
stats = stats.stats;

if strcmp(compkind,'base')
    cond1 = load([filepath '/tone odor conditioning/hilbert/zscore' loc 'results/' folder basename1], 'condition');
    data1 = cond1.condition;
    data1 = squeeze(data1(:,1,wind1,:));
elseif strcmp(compkind,'twostim')
    cond1 = load([filepath '/tone odor conditioning/hilbert/zscore' loc 'results/' folder basename1], 'condition2');
    data1 = cond1.condition2;
    data1 = squeeze(data1(:,1,wind1,:));
end

cond2 = load([filepath '/tone odor conditioning/hilbert/zscore' loc 'results/' folder basename2], 'condition2');
data2 = cond2.condition2;
data2 = squeeze(data2(:,1,wind2,:));
%TI = load([filepath '/hilbert/zscore/results/' basename3], 'TI');
%TI = TI.TI;
%timer = [1*4:4:250*4]./1000;
%timer = [1:10000/2500:1000]./1000;

[ freq,time,trials] = size(data1);

maskz = zeros(time,freq);
if exist('trend','var')
    if strcmp(direction,'pos')
        pos = stats.posclusterslabelmat == 1;
        maskz(1:time,startFreq:0.5:startFreq+size(pos,3)/2-0.5) = pos;
    elseif strcmp(direction,'neg')
        neg = stats.negclusterslabelmat == 1;
        maskz(1:time,startFreq:0.5:startFreq+size(neg,3)/2-0.5) = neg;
    end
else
    %maskz(1:time,startFreq:0.5:startFreq+size(stats.mask,3)/2-0.5) = stats.mask;
    maskz(1:size(stats.mask,2),1:size(stats.mask,3)) = squeeze(stats.mask);
    
end
maskz = ~maskz';
%Xt = 1:1000/250:time/0.25;
Xt = 1:time;
Xf = 1/2:0.5:freq/2; % for the transparent
Xf = 1:freq;

cond1 = squeeze(nanmean(data1,3));
cond2 = squeeze(nanmean(data2,3));
conddiff = cond2 - cond1;

% figure; pcolor(Xt,Xf,cond1);
% xlabel('Time (sec)','FontSize',16)
% ylabel('Frequencies (1-40 Hz)','FontSize',16)
% c = colorbar;
% ylabel(c,'Power (z-score)','Fontsize',16);
% colormap; caxis([-0.5 1.1]);
% set(gca,'LineWidth',1,'FontSize',14)
% box on; shading interp;
% set(gcf,'Color',[1 1 1])
%
% figure; pcolor(Xt,Xf,cond2);
% xlabel('Time (sec)','FontSize',16)
% ylabel('Frequencies (1-40 Hz)','FontSize',16)
% c = colorbar;
% ylabel(c,'Power (z-score)','Fontsize',16);
% colormap; caxis([-0.5 1.1]);
% set(gca,'LineWidth',1,'FontSize',14)
% box on; shading interp;
% set(gcf,'Color',[1 1 1])

%f = figure;
% f = figure('Colormap',...
%     [0 0 0.5625;0 0 0.625;0 0 0.6875;0 0 0.75;0 0 0.8125;0 0 0.875;0 0 0.9375;0 0 1;0 0.16666667163372 1;0 0.333333343267441 1;0 0.5 1;0 0.666666686534882 1;0 0.833333313465118 1;0 1 1;0.0476190485060215 1 0.952380955219269;0.095238097012043 1 0.904761910438538;0.142857149243355 1 0.857142865657806;0.190476194024086 1 0.809523820877075;0.238095238804817 1 0.761904776096344;0.28571429848671 1 0.714285731315613;0.333333343267441 1 0.666666686534882;0.380952388048172 1 0.61904764175415;0.428571432828903 1 0.571428596973419;0.476190477609634 1 0.523809552192688;0.523809552192688 1 0.476190477609634;0.571428596973419 1 0.428571432828903;0.61904764175415 1 0.380952388048172;0.666666686534882 1 0.333333343267441;0.714285731315613 1 0.28571429848671;0.761904776096344 1 0.238095238804817;0.809523820877075 1 0.190476194024086;0.857142865657806 1 0.142857149243355;0.904761910438538 1 0.095238097012043;0.952380955219269 1 0.0476190485060215;1 1 0;1 0.949999988079071 0;1 0.899999976158142 0;1 0.850000023841858 0;1 0.800000011920929 0;1 0.75 0;1 0.699999988079071 0;1 0.649999976158142 0;1 0.600000023841858 0;1 0.550000011920929 0;1 0.5 0;1 0.449999988079071 0;1 0.400000005960464 0;1 0.349999994039536 0;1 0.300000011920929 0;1 0.25 0;1 0.200000002980232 0;1 0.150000005960464 0;1 0.100000001490116 0;1 0.0500000007450581 0;1 0 0;0.944444417953491 0 0;0.888888895511627 0 0;0.833333313465118 0 0;0.777777791023254 0 0;0.722222208976746 0 0;0.666666686534882 0 0;0.611111104488373 0 0;0.555555582046509 0 0;0.5 0 0],...
%     'Color',[1 1 1]);
%caxis([-0.5 1.1]);

figure;
pcolor(Xt,Xf,conddiff);
hold on;
xlabel('Time (ms)','FontSize',16)
ylabel('Frequency (1-40 Hz)','FontSize',16)
c = colorbar;
ylabel(c,'Power (z-score)','Fontsize',16);
colormap('redblue');
caxis([-1 1]);

set(gca,'LineWidth',1,'FontSize',14)
box on; shading interp;
% alphamask(maskz,[1 1 1],0.65,Xt, Xf);
contour(maskz,1,'LineColor', [0.5, 0.5, 0.5])
%contour(maskz,1,'LineColor', [0, 0, 0])

set(gcf,'Color',[1 1 1])
%set(f,'position',[270 660 990 250]);box on;

% fprintf('Saving %s.\n',[filepath 'hilbert/' odor1 '_' odor2 '_clustperm.mat']);
% save([filepath 'hilbert/' odor1 '_' odor2 '_clustperm.mat'], 'stats', '-v7.3');

end