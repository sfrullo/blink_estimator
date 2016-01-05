%%
clear all;
close all;

%%
addpath('../utils');

%% Import groundtruth
load('../blink_ground_truth.mat');
[left_pos, right_pos] = make_groundtruth('../training_set_separated/');


%% SIMPLE METHOD 
% Declare variable
l_res = struct;
l_res.blink_count = [];
l_res.TP = [];
l_res.FP = [];
l_res.FN = [];
l_res.rel_err = [];
l_res.abs_err = [];

r_res = struct;
l_res.blink_count = [];
r_res.TP = [];
r_res.FP = [];
r_res.FN = [];
r_res.rel_err = [];
r_res.abs_err = [];

%Import data for each subject and compare result to ground_truth
data_dir = 'mat_crosscorr_blink/';
s = dir([data_dir '*.mat']);
s = sort_nat({s.name});
for i=1:length(s)
    n_sub = strsplit(s{i}, {'_s', '.'});
    n_sub = char(n_sub(2));
    fprintf('Import data for subject #%s\n', n_sub);
    data = load([data_dir  s{i}]);
    
    % blink count
    l_res.blink_count(i,:) = data.l_simple_blink_count';
    r_res.blink_count(i,:) = data.r_simple_blink_count';
    
    % true positive = detected blinks that are present in left_pos
    l_res.TP(i,:) = sum(ismember(data.l_simple_blink_pos, left_pos), 2)';
    r_res.TP(i,:) = sum(ismember(data.r_simple_blink_pos, right_pos), 2)';
    
    % false positive = detected blinks that are NOT present in left_pos
    temp = data.l_simple_blink_pos;
    temp(find(ismember(temp, left_pos))) = 0;
    l_res.FP(i,:) = sum(~ismember(temp,0),2)';
    temp = data.r_simple_blink_pos;
    temp(find(ismember(temp, right_pos))) = 0;
    r_res.FP(i,:) = sum(~ismember(temp,0),2)';
    
    % false negative
    pos = left_pos(i,:);
    temp = repmat(pos(~isnan(pos)), size(data.l_simple_blink_pos,1),1);
    l_res.FN(i,:) = sum(~ismember(temp, data.l_simple_blink_pos), 2)';
    pos = right_pos(i,:);
    temp = repmat(pos(~isnan(pos)), size(data.r_simple_blink_pos,1),1);
    r_res.FN(i,:) = sum(~ismember(temp, data.r_simple_blink_pos), 2)';
    
    l_res.abs_err(i,:) = abs(l_res.blink_count(i,:) - blink_gt(i));
    r_res.abs_err(i,:) = abs(r_res.blink_count(i,:) - blink_gt(i));
    
    l_res.rel_err(i,:) = abs(l_res.blink_count(i,:) - blink_gt(i)) ./ blink_gt(i);
    r_res.rel_err(i,:) = abs(r_res.blink_count(i,:) - blink_gt(i)) ./ blink_gt(i);
end

clear data_dir n_sub temp data s i

%% DOUBLE THRESHOLD METHOD
% Declare variable
l_res = struct;
l_res.blink_count = [];
l_res.TP = [];
l_res.FP = [];
l_res.FN = [];
l_res.rel_err = [];
l_res.abs_err = [];

r_res = struct;
l_res.blink_count = [];
r_res.TP = [];
r_res.FP = [];
r_res.FN = [];
r_res.rel_err = [];
r_res.abs_err = [];

%Import data for each subject and compare result to ground_truth
data_dir = 'mat_crosscorr_blink/';
s = dir([data_dir '*.mat']);
s = sort_nat({s.name});
for i=1:length(s)
    n_sub = strsplit(s{i}, {'_s', '.'});
    n_sub = char(n_sub(2));
    fprintf('Import data for subject #%s\n', n_sub);
    data = load([data_dir  s{i}]);
    
    % blink count
    l_res.blink_count(i,:) = data.l_blink_count';
    r_res.blink_count(i,:) = data.r_blink_count';
    
    % true positive = detected blinks that are present in left_pos
    l_res.TP(i,:) = sum(ismember(data.l_blink_pos, left_pos), 2)';
    r_res.TP(i,:) = sum(ismember(data.r_blink_pos, right_pos), 2)';
    
    % false positive = detected blinks that are NOT present in left_pos
    temp = data.l_blink_pos;
    temp(find(ismember(temp, left_pos))) = 0;
    l_res.FP(i,:) = sum(~ismember(temp,0),2)';
    temp = data.r_blink_pos;
    temp(find(ismember(temp, right_pos))) = 0;
    r_res.FP(i,:) = sum(~ismember(temp,0),2)';
    
    % false negative
    pos = left_pos(i,:);
    temp = repmat(pos(~isnan(pos)), size(data.l_blink_pos,1),1);
    l_res.FN(i,:) = sum(~ismember(temp, data.l_blink_pos), 2)';
    pos = right_pos(i,:);
    temp = repmat(pos(~isnan(pos)), size(data.r_blink_pos,1),1);
    r_res.FN(i,:) = sum(~ismember(temp, data.r_blink_pos), 2)';
    
    l_res.abs_err(i,:) = abs(l_res.blink_count(i,:) - blink_gt(i));
    r_res.abs_err(i,:) = abs(r_res.blink_count(i,:) - blink_gt(i));
    
    l_res.rel_err(i,:) = abs(l_res.blink_count(i,:) - blink_gt(i)) ./ blink_gt(i);
    r_res.rel_err(i,:) = abs(r_res.blink_count(i,:) - blink_gt(i)) ./ blink_gt(i);
end

clear data_dir n_sub temp data s i

%% Comptute and plot mean error
figure();
e = mean(l_res.rel_err, 1);
plot(e);