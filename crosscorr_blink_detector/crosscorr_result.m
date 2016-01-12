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
for i=1%:length(s)
    
    n_sub = strsplit(s{i}, {'_s', '.'});
    n_sub = char(n_sub(2));
    fprintf('Import data for subject #%s\n', n_sub);
    data = load([data_dir  s{i}]);
    
    % Declare variable
    l = struct;
    l.blink_count = data.l_blink_count';
    l.TP = zeros(1,length(data.thresh_comb));
    l.FP = zeros(1,length(data.thresh_comb));
    l.FN = zeros(1,length(data.thresh_comb));
    l.rel_err = zeros(1,length(data.thresh_comb));
    l.abs_err = zeros(1,length(data.thresh_comb));
    
    r = struct;
    r.blink_count = data.r_blink_count';
    r.TP = zeros(1,length(data.thresh_comb));
    r.FP = zeros(1,length(data.thresh_comb));
    r.FN = zeros(1,length(data.thresh_comb));
    r.rel_err = zeros(1,length(data.thresh_comb));
    r.abs_err = zeros(1,length(data.thresh_comb));
    
    % true positive = detected blinks which positions are present in sub_gt.
    for row=1:size(data.thresh_comb,1)
        
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
    end
end