function average2eletrial(listname)

loadpathsToneOdor
loadsubjToneOdor

subjlist = eval(listname);

for s = 1:size(subjlist,1)
    basename = subjlist{s,1};
    %    % hilbert
    %    load([filepath 'tone odor conditioning/hilbert/2elec/' basename 'hilbert.mat'])
    %    spec1 = squeeze(hilbdata(:,1,:,:)); spec1_vec = reshape(spec1, size(spec1,1)*size(spec1,2)*size(spec1,3),1);
    %    spec2 = squeeze(hilbdata(:,2,:,:)); spec2_vec = reshape(spec2, size(spec2,1)*size(spec2,2)*size(spec2,3),1);
    %    hilbdata(:,3,:,:) = reshape(nanmean([spec1_vec spec2_vec],2),[size(spec1,1),size(spec1,2),size(spec1,3)]);
    %    fprintf('Saving %s.\n',basename);
    %    save ([filepath 'tone odor conditioning/hilbert/2elec/'  basename 'hilbert.mat'],'hilbdata','times','-v7.3')
    
    
    % z-score
%     %ERP
%     load([filepath 'tone odor conditioning/ERP/2elec/' basename 'ERPdata.mat'])
%     ele1 = squeeze(ERPdata(1,:,:)); ele1_vec = reshape(ele1, size(ele1,1)*size(ele1,2),1);
%     ele2 = squeeze(ERPdata(2,:,:)); ele2_vec = reshape(ele2, size(ele2,1)*size(ele2,2),1);
%     ERPdata(3,:,:) = reshape(nanmean([ele1_vec ele2_vec],2),[size(ele1,1),size(ele1,2)]);
    
    %ERSP
    %load([filepath 'tone odor conditioning/hilbert/zscore/2elec/' basename 'hilbdata_intra_zscore.mat'])
    %load([filepath 'tone odor conditioning/hilbert/zscore/2elec/zscore5sec/' basename 'hilbdata_intra2_zscore2.mat'])
    load([filepath 'tone odor conditioning/hilbert/zscore/2elec/' basename 'hilbdata_baseline_zscore.mat'])
    
    spec1 = squeeze(condition(:,1,:,:)); spec1_vec = reshape(spec1, size(spec1,1)*size(spec1,2)*size(spec1,3),1);
    spec2 = squeeze(condition(:,2,:,:)); spec2_vec = reshape(spec2, size(spec2,1)*size(spec2,2)*size(spec2,3),1);
    condition(:,3,:,:) = reshape(nanmean([spec1_vec spec2_vec],2),[size(spec1,1),size(spec1,2),size(spec1,3)]);
    
%     spec1 = squeeze(condition2(:,1,:,:)); spec1_vec = reshape(spec1, size(spec1,1)*size(spec1,2)*size(spec1,3),1);
%     spec2 = squeeze(condition2(:,2,:,:)); spec2_vec = reshape(spec2, size(spec2,1)*size(spec2,2)*size(spec2,3),1);
%     condition2(:,3,:,:) = reshape(nanmean([spec1_vec spec2_vec],2),[size(spec1,1),size(spec1,2),size(spec1,3)]);
    
    
    fprintf('Saving %s.\n',basename);
    %save ([filepath 'tone odor conditioning/ERP/2elec/'  basename 'ERPdata.mat'],'ERPdata')
    %save ([filepath 'tone odor conditioning/hilbert/zscore/2elec/zscore5sec/'  basename 'hilbdata_intra_zscore.mat'],'condition','condition2','times')
    %save ([filepath 'tone odor conditioning/hilbert/zscore/2elec/zscore5sec/'  basename 'hilbdata_intra2_zscore2.mat'],'condition','condition2','times')
    save ([filepath 'tone odor conditioning/hilbert/zscore/2elec/'  basename 'hilbdata_baseline_zscore.mat'],'condition','times')
    
end