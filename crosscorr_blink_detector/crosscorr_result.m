%%
clear all;
close all;

%%
addpath('../utils');

%% Import groundtruth
make_groundtruth;

%% SIMPLE METHOD
%Import data for each subject and compare result to ground_truth
data_dir = 'mat_crosscorr_blink/';
s = dir([data_dir '*.mat']);
s = sort_nat({s.name});
data = load([data_dir  s{1}]);

% global algorithm performance variable
l_err = zeros(length(s),length(data.thresh_comb));
l_accuracy = zeros(length(s),length(data.thresh_comb));
l_precision = zeros(length(s),length(data.thresh_comb));
l_recall = zeros(length(s),length(data.thresh_comb));

r_err = zeros(length(s),length(data.thresh_comb));
r_accuracy = zeros(length(s),length(data.thresh_comb));
r_precision = zeros(length(s),length(data.thresh_comb));
r_recall = zeros(length(s),length(data.thresh_comb));

for i=1:length(s)
    
    n_sub = strsplit(s{i}, {'_s', '.'});
    n_sub = char(n_sub(2));
    fprintf('Import data for subject #%s\n', n_sub);
    data = load([data_dir  s{i}]);
    
    % Declare per subject performance variable
    l = struct;
    l.blink_count = data.l_blink_count';
    l.TP = zeros(1,length(data.thresh_comb));
    l.FP = zeros(1,length(data.thresh_comb));
    l.FN = zeros(1,length(data.thresh_comb));
    l.err = zeros(1,length(data.thresh_comb));
    l.accuracy = zeros(1,length(data.thresh_comb));
    l.precision = zeros(1,length(data.thresh_comb));
    l.recall = zeros(1,length(data.thresh_comb));
    
    r = struct;
    r.blink_count = data.r_blink_count';
    r.TP = zeros(1,length(data.thresh_comb));
    r.FP = zeros(1,length(data.thresh_comb));
    r.FN = zeros(1,length(data.thresh_comb));
    r.err = zeros(1,length(data.thresh_comb));
    r.accuracy = zeros(1,length(data.thresh_comb));
    r.precision = zeros(1,length(data.thresh_comb));
    r.recall = zeros(1,length(data.thresh_comb));
    
    % true positive = detected blinks which positions are present in sub_gt.
    for row=1:size(data.thresh_comb,1)
        
        % LEFT
        % if at least a blink is found
        if any(data.l_blink_pos(row,:))
            % fetch subject's ground truth
            gt = bgt.(['s_' n_sub]);
            pos = data.l_blink_pos(row,:);
            pos = pos(pos > 0);
            
            % for each position
            for p=1:length(pos)
                % check if it is a valid value
                indx = find(cellfun(@(x) ismember(pos(p),x), gt));
                % if so..
                if any(indx)
                    % increase true positive counter
                    l.TP(row) = l.TP(row) + 1;
                    % remove related blink values from the gt list
                    gt(indx) = [];
                    
                    % if pos is not a valid value or refers to a used blink ..
                else
                    % increase False Positive counter
                    l.FP(row) = l.FP(row) + 1;
                end
            end
        end
        
        % RIGHT
        % if at least a blink is found
        if any(data.l_blink_pos(row,:))
            % fetch subject's ground truth
            gt = bgt.(['s_' n_sub]);
            pos = data.r_blink_pos(row,:);
            pos = pos(pos > 0);
            
            % for each position
            for p=1:length(pos)
                % check if it is a valid value
                indx = find(cellfun(@(x) ismember(pos(p),x), gt));
                % if so..
                if any(indx)
                    % increase true positive counter
                    r.TP(row) = r.TP(row) + 1;
                    % remove related blink values from the gt list
                    gt(indx) = [];
                    
                    % if pos is not a valid value or refers to a used blink ..
                else
                    % increase False Positive counter
                    r.FP(row) = r.FP(row) + 1;
                end
            end
        end
    end
    
    % compute the remaining parameters
    l.FN = length(bgt.(['s_' n_sub])) - l.TP;
    l.err = abs(length(bgt.(['s_' n_sub])) - (l.TP + l.FP)) ./ length(bgt.(['s_' n_sub]));
    l.accuracy = l.TP ./ (l.TP + l.FP + l.FN);
    l.precision = l.TP ./ (l.TP + l.FP);
    l.recall = l.TP ./ (l.TP + l.FN);
    
    r.FN = length(bgt.(['s_' n_sub])) - r.TP;
    r.err = abs(length(bgt.(['s_' n_sub])) - (r.TP + r.FP)) ./ length(bgt.(['s_' n_sub]));
    r.accuracy = l.TP ./ (l.TP + l.FP + l.FN);
    r.precision = l.TP ./ (l.TP + l.FP);
    r.recall = l.TP ./ (l.TP + l.FN);
    
    % fix nan values
    l.accuracy(isnan(l.accuracy)) = 0;
    l.precision(isnan(l.precision)) = 0;
    l.recall(isnan(l.recall)) = 0;

    r.accuracy(isnan(r.accuracy)) = 0;
    r.precision(isnan(r.precision)) = 0;
    r.recall(isnan(r.recall)) = 0;
    
    % Save results for each subject
    save(['results/' s{i}], 'l', 'r');
    
    % add values to global algorithm performance variable
    l_err(i,:) = l.err;
    l_accuracy(i,:) = l.accuracy;
    l_precision(i,:) = l.precision;
    l_recall(i,:) = l.recall;
    
    r_err(i,:) = r.err;
    r_accuracy(i,:) = r.accuracy;
    r_precision(i,:) = r.precision;
    r_recall(i,:) = r.recall;
    
end

% compute mean values
l_accuracy_mean = mean(l_accuracy, 1);
l_precision_mean = mean(l_precision,1);
l_recall_mean = mean(l_recall,1);

r_accuracy_mean = mean(r_accuracy, 1);
r_precision_mean = mean(r_precision,1);
r_recall_mean = mean(r_recall,1);

% save global performance
save(['results/' 'global.mat'], 'l_*', 'r_*');