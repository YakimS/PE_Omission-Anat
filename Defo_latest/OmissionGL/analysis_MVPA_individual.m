%% Individual-level MVPA analysis: cluster permutation test + descriptive statistics
%
% Part 1: Single-subject cluster-based permutation test (ADAM-style)
%   For each subject/sleep stage, tests whether decoding is significantly
%   above chance using cluster-based permutation following the same algorithm
%   as ADAM's cluster_based_permutation.m (Maris & Oostenveld, 2007).
%   Adapted for individual level: observed AUC is z-scored against the 30
%   label permutations at each timepoint (analogous to ADAM's t-statistic),
%   clusters are formed from adjacent significant timepoints, cluster
%   statistic = sum of z-values (maxsum). Null distribution is constructed
%   by exhaustive relabeling (n=31) across the observed and permuted time
%   courses, which are exchangeable under H0.
%
% Part 2: Descriptive statistics for max consecutive significant timepoints
%   Computes and reports per-stage and cross-stage summary statistics
%   from the saved sub_mvpa_data (analysis_MVPA.m output).

clc; clear;
addpath(genpath('C:\Users\User\Documents\GitHub\PE_Omission-Anat\Defo_latest'));
[v, subs, dirs, ~, ~, ~] = GL_configuration('mvpa');

%% Parameters
results_dir   = 'C:\mvpa\GL\FirstLevel2';
plot_dir      = 'C:\mvpa\GL\plots2\resampNo';
all_subsets   = {'subset-wn', 'subset-N1', 'subset-N2', 'subset-N3', 'subset-REM'};
all_contrasts = {'UnexOm-vs-ExOm'};
testlim       = [-100 900];
channelpool   = 'ALL_NOSELECTION';
cluster_alpha = 0.05;   % cluster-forming threshold
cluster_pval  = 0.05;   % cluster-level significance threshold
tail          = 'right'; % one-tailed: above chance
ms_factor     = 4;       % 250 Hz -> 4 ms per timepoint

%% Load saved per-subject MVPA data (from analysis_MVPA.m)
load(sprintf('%s\\sub_mvpa_auc_pval.mat', plot_dir), 'sub_mvpa_data');

%% ======================================================================
%  PART 1: Cluster-based permutation test per subject per sleep stage
%  ======================================================================
cluster_results = struct();

for contrast_i = 1:numel(all_contrasts)
    curr_contrast = all_contrasts{contrast_i};

    for subset_i = 1:numel(all_subsets)
        curr_subset = all_subsets{subset_i};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));

        % Paths
        contrast_dir = sprintf('%s\\%s\\%s_%s', results_dir, curr_subset, curr_subset, curr_contrast);
        regular_dir  = [contrast_dir filesep channelpool];
        perm_dir     = [regular_dir filesep 'randperm'];

        % Get subject files (regular first-level, exclude PERM files)
        sub_files = dir(fullfile(regular_dir, 'CLASS_PERF_*.mat'));
        sub_files = sub_files(~contains({sub_files.name}, 'PERM'));
        n_subs = numel(sub_files);

        fprintf('Processing %s / %s (%d subjects)...\n', curr_subset, curr_contrast, n_subs);

        sub_results = struct();

        for s = 1:n_subs
            sub_name = sub_files(s).name;
            sub_id = regexp(sub_name, '(CLASS_PERF_s-\d+_allSovs)', 'match', 'once');

            % Load observed diagonal AUC
            actual_data = load(fullfile(regular_dir, sub_name), 'BDM', 'settings');
            actual_diag_full = diag(actual_data.BDM.ClassOverTime);
            times_ms = actual_data.settings.times{1} * 1000;
            lim_idx = find(times_ms >= testlim(1), 1, 'first'):find(times_ms <= testlim(2), 1, 'last');
            actual_diag = actual_diag_full(lim_idx)';
            time_vec = times_ms(lim_idx) / 1000;
            n_tp = numel(lim_idx);

            % Load permutation diagonal AUCs
            perm_files_list = dir(fullfile(perm_dir, [sub_id '*_PERM*.mat']));
            n_perms = numel(perm_files_list);
            perm_diags = zeros(n_perms, n_tp);

            for p = 1:n_perms
                try
                    perm_data = load(fullfile(perm_dir, perm_files_list(p).name), 'BDM');
                    d = diag(perm_data.BDM.ClassOverTime);
                    perm_diags(p, :) = d(lim_idx)';
                catch
                    perm_diags(p, :) = NaN;
                end
            end
            perm_diags = perm_diags(~any(isnan(perm_diags), 2), :);
            n_perms = size(perm_diags, 1);

            % Pool all time courses: row 1 = observed, rows 2:end = permutations
            % Under H0 (no real decoding), all 31 are exchangeable
            all_diags = [actual_diag; perm_diags];  % (n_perms+1) x n_tp
            n_total = size(all_diags, 1);            % 31

            % Step 1: z-score observed against permutation distribution
            % (analogous to ADAM's t-statistic at each timepoint)
            perm_mean = mean(perm_diags, 1);
            perm_std  = std(perm_diags, 0, 1);
            perm_std(perm_std == 0) = eps;
            obs_z = (actual_diag - perm_mean) ./ perm_std;

            % Step 2-4: threshold, find clusters, cluster stat = sum of z-values (maxsum)
            z_thresh = norminv(1 - cluster_alpha);  % 1.645 for alpha=0.05, one-tailed
            [obs_clusters, obs_cluster_stats] = compute_cluster_stats_z(obs_z, z_thresh);
            if isempty(obs_cluster_stats)
                obs_max_cluster_stat = 0;
            else
                obs_max_cluster_stat = max(obs_cluster_stats);
            end

            % Step 5-6: null distribution via exhaustive relabeling
            % Treat each of the 31 time courses as "observed" in turn
            null_max_cluster_stats = zeros(n_total, 1);
            for k = 1:n_total
                null_obs = all_diags(k, :);
                null_perms = all_diags([1:k-1, k+1:end], :);
                null_mean = mean(null_perms, 1);
                null_std  = std(null_perms, 0, 1);
                null_std(null_std == 0) = eps;
                null_z = (null_obs - null_mean) ./ null_std;

                [~, null_cstats] = compute_cluster_stats_z(null_z, z_thresh);
                if isempty(null_cstats)
                    null_max_cluster_stats(k) = 0;
                else
                    null_max_cluster_stats(k) = max(null_cstats);
                end
            end

            % Cluster p-values for each observed cluster
            sig_clusters = [];
            if ~isempty(obs_cluster_stats)
                for ci = 1:numel(obs_cluster_stats)
                    cp = sum(null_max_cluster_stats >= obs_cluster_stats(ci)) / n_total;
                    if cp < cluster_pval
                        sig_clusters(end+1).stat = obs_cluster_stats(ci);
                        sig_clusters(end).pval = cp;
                        sig_clusters(end).onset = time_vec(obs_clusters{ci}(1));
                        sig_clusters(end).offset = time_vec(obs_clusters{ci}(end));
                    end
                end
            end

            % Overall cluster p-value (for the max cluster)
            cluster_pvalue = sum(null_max_cluster_stats >= obs_max_cluster_stat) / n_total;

            sub_results(s).sub_name = sub_name;
            sub_results(s).max_cluster_stat = obs_max_cluster_stat;
            sub_results(s).cluster_pvalue = cluster_pvalue;
            sub_results(s).n_sig_clusters = numel(sig_clusters);
            sub_results(s).sig_clusters = sig_clusters;
            sub_results(s).null_distribution = null_max_cluster_stats;

            if ~mod(s, 5)
                fprintf('  Subject %d/%d done\n', s, n_subs);
            end
        end

        cluster_results.(field_name).sub_results = sub_results;
        cluster_results.(field_name).time = time_vec;
        cluster_results.(field_name).subset = curr_subset;
        cluster_results.(field_name).contrast = curr_contrast;
    end
end

%% Save cluster results
save_path = sprintf('%s\\cluster_perm_results.mat', plot_dir);
save(save_path, 'cluster_results');
fprintf('Saved cluster permutation results to: %s\n', save_path);

%% Export cluster results to Excel
excel_cluster_path = sprintf('%s\\sub_mvpa_cluster_perm.xlsx', plot_dir);
fields_cl = fieldnames(cluster_results);
unique_contrasts_cl = unique(cellfun(@(f) cluster_results.(f).contrast, fields_cl, 'UniformOutput', false), 'stable');
unique_subsets_cl   = unique(cellfun(@(f) cluster_results.(f).subset, fields_cl, 'UniformOutput', false), 'stable');

for c = 1:numel(unique_contrasts_cl)
    curr_contrast = unique_contrasts_cl{c};
    col_names = {'Subject'};
    table_data = {};
    n_subs_first = [];

    for ss = 1:numel(unique_subsets_cl)
        curr_subset = unique_subsets_cl{ss};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));
        sr = cluster_results.(field_name).sub_results;
        n_subs = numel(sr);
        if isempty(n_subs_first); n_subs_first = n_subs; end

        subset_clean = strrep(curr_subset, '-', '_');
        col_names = [col_names, ...
            sprintf('%s_maxClusterStat', subset_clean), ...
            sprintf('%s_clusterPval', subset_clean), ...
            sprintf('%s_nSigClusters', subset_clean), ...
            sprintf('%s_sigClusterTimes', subset_clean)];

        max_stats = arrayfun(@(x) x.max_cluster_stat, sr)';
        pvals     = arrayfun(@(x) x.cluster_pvalue, sr)';
        n_sig     = arrayfun(@(x) x.n_sig_clusters, sr)';

        time_strs = cell(n_subs, 1);
        for s = 1:n_subs
            if sr(s).n_sig_clusters > 0
                parts = arrayfun(@(x) sprintf('%.0f-%.0f ms', x.onset*1000, x.offset*1000), ...
                    sr(s).sig_clusters, 'UniformOutput', false);
                time_strs{s} = strjoin(parts, '; ');
            else
                time_strs{s} = '';
            end
        end

        table_data = [table_data, ...
            num2cell(round(max_stats, 2)), ...
            num2cell(round(pvals, 3)), ...
            num2cell(n_sig), ...
            time_strs];
    end

    sub_labels = arrayfun(@(x) sprintf('sub%d', x), 1:n_subs_first, 'UniformOutput', false)';
    table_data = [sub_labels, table_data];
    T = cell2table(table_data, 'VariableNames', col_names);

    sheet_name = strrep(curr_contrast, '-', '_');
    if length(sheet_name) > 31; sheet_name = sheet_name(1:31); end
    writetable(T, excel_cluster_path, 'Sheet', sheet_name);
end
fprintf('Saved cluster Excel to: %s\n', excel_cluster_path);

%% Cluster test summary
fprintf('\n=== Cluster Permutation Test Summary ===\n');
for c = 1:numel(unique_contrasts_cl)
    curr_contrast = unique_contrasts_cl{c};
    sig_all = [];
    sig_no_n3 = [];
    for ss = 1:numel(unique_subsets_cl)
        curr_subset = unique_subsets_cl{ss};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));
        sr = cluster_results.(field_name).sub_results;
        is_sig = arrayfun(@(x) x.cluster_pvalue < cluster_pval, sr)';
        fprintf('%s / %s: %d/%d subjects with significant cluster (p<%.2f)\n', ...
            curr_contrast, curr_subset, sum(is_sig), numel(is_sig), cluster_pval);
        if isempty(sig_all); sig_all = is_sig; else; sig_all = sig_all & is_sig; end
        if ~contains(curr_subset, 'N3')
            if isempty(sig_no_n3); sig_no_n3 = is_sig; else; sig_no_n3 = sig_no_n3 & is_sig; end
        end
    end
    fprintf('%s / ALL subsets: %d/%d subjects significant in every subset\n', ...
        curr_contrast, sum(sig_all), numel(sig_all));
    fprintf('%s / ALL except N3: %d/%d subjects significant in every subset except N3\n\n', ...
        curr_contrast, sum(sig_no_n3), numel(sig_no_n3));
end

%% ======================================================================
%  PART 2: Descriptive statistics for max consecutive significant timepoints
%  ======================================================================
fprintf('\n=== Descriptive Statistics: Max Consecutive Significant Timepoints ===\n');

fields_data = fieldnames(sub_mvpa_data);
unique_subsets_data   = unique(cellfun(@(f) sub_mvpa_data.(f).subset, fields_data, 'UniformOutput', false), 'stable');
unique_contrasts_data = unique(cellfun(@(f) sub_mvpa_data.(f).contrast, fields_data, 'UniformOutput', false), 'stable');
n_subs = size(sub_mvpa_data.(fields_data{1}).auc, 1);

for c = 1:numel(unique_contrasts_data)
    curr_contrast = unique_contrasts_data{c};
    fprintf('\n--- Contrast: %s ---\n', curr_contrast);

    % Build max_consec matrix: n_subs x n_subsets
    max_consec = zeros(n_subs, numel(unique_subsets_data));
    stage_labels = cell(1, numel(unique_subsets_data));

    for ss = 1:numel(unique_subsets_data)
        curr_subset = unique_subsets_data{ss};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));
        stage_labels{ss} = curr_subset;

        for s = 1:n_subs
            pvals = sub_mvpa_data.(field_name).pval(s, :);
            max_consec(s, ss) = max_consecutive_true(pvals < 0.05);
        end
    end

    % Per-stage descriptives
    fprintf('\nPer-stage descriptives:\n');
    for ss = 1:numel(stage_labels)
        vals_tp = max_consec(:, ss);
        vals_ms = vals_tp * ms_factor;
        fprintf('  %s: median = %d ms (IQR = [%d-%d] ms, range = [%d-%d] ms)\n', ...
            stage_labels{ss}, median(vals_ms), ...
            prctile(vals_ms, 25), prctile(vals_ms, 75), ...
            min(vals_ms), max(vals_ms));
        fprintf('         n with no significant timepoints: %d/%d\n', sum(vals_tp == 0), n_subs);
        fprintf('         n >= 40 ms (10 tp): %d/%d,  n >= 100 ms (25 tp): %d/%d\n', ...
            sum(vals_tp >= 10), n_subs, sum(vals_tp >= 25), n_subs);
    end

    % Cross-stage: min across ALL states per subject
    min_all = min(max_consec, [], 2);
    fprintf('\nMinimum across ALL vigilance states per subject:\n');
    fprintf('  Best subject (max of mins): %d tp (%d ms)\n', max(min_all), max(min_all)*ms_factor);
    fprintf('  Median of mins: %.0f tp (%.0f ms)\n', median(min_all), median(min_all)*ms_factor);

    % Cross-stage: min across all EXCEPT N3
    n3_col = find(contains(stage_labels, 'N3'));
    non_n3_cols = setdiff(1:numel(stage_labels), n3_col);
    min_no_n3 = min(max_consec(:, non_n3_cols), [], 2);
    fprintf('\nMinimum excluding N3 per subject:\n');
    fprintf('  Best subject (max of mins): %d tp (%d ms)\n', max(min_no_n3), max(min_no_n3)*ms_factor);
    fprintf('  Median of mins: %.0f tp (%.0f ms)\n', median(min_no_n3), median(min_no_n3)*ms_factor);

    % Subjects with no significant timepoints at all in at least one sleep stage
    sleep_cols = find(~contains(stage_labels, 'wn'));
    has_zero_any_sleep = any(max_consec(:, sleep_cols) == 0, 2);
    fprintf('\nSubjects with no significant timepoints in at least one sleep stage: %d/%d\n', ...
        sum(has_zero_any_sleep), n_subs);

    % Number of timepoints tested
    n_tp_tested = size(sub_mvpa_data.(fields_data{1}).pval, 2);
    fprintf('Number of time points tested: %d (%.0f ms window)\n', ...
        n_tp_tested, n_tp_tested * ms_factor);
end

%% ======================================================================
%  PART 3: "For paper" supplementary table Excel
%  Each cell: "X ms, Yes/No, p=Y"
%  (longest sustained sig period / sig cluster? / cluster p-value)
%  ======================================================================
paper_excel_path = sprintf('%s\\Supplementary_Table_Individual_MVPA.xlsx', plot_dir);

stage_display_names = {'Wakefulness', 'N1', 'N2', 'N3', 'REM'};

for c = 1:numel(unique_contrasts_data)
    curr_contrast = unique_contrasts_data{c};

    % Build max_consec from sub_mvpa_data
    max_consec_paper = zeros(n_subs, numel(unique_subsets_data));
    for ss = 1:numel(unique_subsets_data)
        curr_subset = unique_subsets_data{ss};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));
        for s = 1:n_subs
            pvals = sub_mvpa_data.(field_name).pval(s, :);
            max_consec_paper(s, ss) = max_consecutive_true(pvals < 0.05);
        end
    end

    % Build combined cell strings
    paper_data = cell(n_subs, numel(unique_subsets_data));
    for ss = 1:numel(unique_subsets_data)
        curr_subset = unique_subsets_data{ss};
        field_name = sprintf('%s__%s', strrep(curr_subset,'-','_'), strrep(curr_contrast,'-','_'));
        sr = cluster_results.(field_name).sub_results;

        for s = 1:n_subs
            duration_ms = max_consec_paper(s, ss) * ms_factor;
            cp = sr(s).cluster_pvalue;
            is_sig = cp < cluster_pval;

            if is_sig
                sig_str = 'Yes';
            else
                sig_str = 'No';
            end

            if cp < 0.001
                p_str = 'p<.001';
            else
                p_str = sprintf('p=%.3f', cp);
                p_str = strrep(p_str, '0.', '.');  % remove leading zero
            end

            paper_data{s, ss} = sprintf('%dms, %s, %s', duration_ms, sig_str, p_str);
        end
    end

    sub_labels = arrayfun(@(x) sprintf('S%02d', x), 1:n_subs, 'UniformOutput', false)';
    col_names = ['Subject', stage_display_names];
    T = cell2table([sub_labels, paper_data], 'VariableNames', col_names);

    sheet_name = strrep(curr_contrast, '-', '_');
    if length(sheet_name) > 31; sheet_name = sheet_name(1:31); end

    % Write caption at cell A1, then table starting below
    note_text = {'Note: Each cell contains: longest sustained significant decoding period (ms) / significant cluster (Yes/No) / cluster-level p-value.'};
    writecell(note_text, paper_excel_path, 'Sheet', sheet_name, 'Range', 'A1');
    writetable(T, paper_excel_path, 'Sheet', sheet_name, 'Range', 'A3');
end
fprintf('Saved supplementary table Excel to: %s\n', paper_excel_path);

%% ======================== Helper functions ========================

function [clusters, cluster_stats] = compute_cluster_stats_z(z_values, z_thresh)
% Find clusters of adjacent timepoints where z exceeds threshold and
% compute cluster statistics as sum of z-values (maxsum).
% Follows ADAM's cluster_based_permutation.m steps 2-4.
%   z_values - 1 x timepoints, z-scores
%   z_thresh - z-score threshold for cluster formation
    clusters = {};
    cluster_stats = [];

    above_thresh = z_values > z_thresh;
    if ~any(above_thresh)
        return;
    end

    % Label adjacent supra-threshold timepoints (like ADAM's bwlabel)
    labels = bwlabel(above_thresh);
    for c = 1:max(labels)
        idx = find(labels == c);
        clusters{end+1} = idx;
        cluster_stats(end+1) = sum(z_values(idx));  % maxsum
    end
end

function max_run = max_consecutive_true(vec)
    max_run = 0;
    current_run = 0;
    for i = 1:numel(vec)
        if vec(i)
            current_run = current_run + 1;
            if current_run > max_run
                max_run = current_run;
            end
        else
            current_run = 0;
        end
    end
end
