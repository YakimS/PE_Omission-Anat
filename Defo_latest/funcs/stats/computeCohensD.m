function cohens_d = computeCohensD(group1_array, group2_array)
    % Means and standard deviations
    mean1 = nanmean(group1_array);
    mean2 = nanmean(group2_array);
    std1 = nanstd(group1_array);
    std2 = nanstd(group2_array);
    
    % Pooled standard deviation
    n1 = sum(~isnan(group1_array));
    n2 = sum(~isnan(group2_array));
    sd_pooled = sqrt(((n1 - 1)*std1^2 + (n2 - 1)*std2^2) / (n1 + n2 - 2));
    
    % Cohen's d
    cohens_d = (mean1 - mean2) / sd_pooled;
end