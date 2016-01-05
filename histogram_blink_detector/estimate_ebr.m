close all;
clear all;

%%

im_dir = 'eyes_image';
sub_id = '18';
le_dir = [im_dir '/' sub_id '/left/'];
re_dir = [im_dir '/' sub_id '/right/'];
le_file = dir([le_dir '*.jpg']);
re_file = dir([re_dir '*.jpg']);

nfile = length(le_file);

%% Compute tau
le_tau = zeros(1,nfile);
le_hist = zeros(nfile,256);
le_cumhist = zeros(nfile,256);

re_tau = zeros(1,nfile);
re_hist = zeros(nfile,256);
re_cumhist = zeros(nfile,256);

tr = 0.1;

parfor i=1:nfile
    % read left eye image
    le_im = imread([le_dir le_file(i).name]);
    % [tau, meanIntensity, cumhist, nhist, hist,ny, nyf] = computeTau(le_im, tr);
    [le_tau(i), ~, le_cumhist(i,:), le_hist(i,:)]  = computeTau(le_im, tr);
    % read right eye image
    re_im = imread([re_dir re_file(i).name]);
    [re_tau(i), ~, re_cumhist(i,:), ~, re_hist(i,:)] = computeTau(re_im, tr);
end

%% Compute dtau
le_dtau = diff(le_tau);
re_dtau = diff(le_tau);

%% Compute tmin, tmax and Td
% we distinguish tiny magnitude from main magnitude as peaks which values
% are less than the mean between zero and maximum peak value
le_m = mean([0, max(findpeaks(le_dtau))]);
re_m = mean([0, max(findpeaks(re_dtau))]);

% tmax is one unit smaller than the minimum of the main magnitude peaks of
% dtau
le_tmax = min(le_dtau(le_dtau > le_m)) - 1;
re_tmax = min(re_dtau(re_dtau > re_m)) - 1;
if numel(le_dtau(le_dtau > le_m)) > 2
    p = findpeaks(le_dtau(le_dtau > le_m));
    if  numel(p) > 1
        le_tmax = min(p) - 1;
    end
end
if numel(re_dtau(re_dtau > re_m)) > 2
    p = findpeaks(re_dtau(re_dtau > re_m));
    if  numel(p) > 1
        re_tmax = min(p) - 1;
    end
end

% tmin is chosen in such a way that it must be bigger than the maximum of
% the tiny magnitude peaks of dtau
le_tmin = max(le_dtau(le_dtau < le_m)) + 1;
re_tmin = max(re_dtau(re_dtau < re_m)) + 1;
if numel(le_dtau(le_dtau < le_m)) > 3
    p = findpeaks(le_dtau(le_dtau < le_m));
    if numel(p) > 1
        tmin = max(p) + 1;
    end
end
if numel(re_dtau(re_dtau < re_m)) > 3
    p = findpeaks(re_dtau(re_dtau < re_m));
    if numel(p) > 1
        re_tmin = max(p) + 1;
    end
end

% compute Td as Td = (tmax - tmin) + 1
le_td = (le_tmax + le_tmin)/2 + 1;
re_td = (re_tmax + re_tmin)/2 + 1;

%% Plot images and histograms

% initialize handles
figure();
% left eye
subplot(241); lim_h = imagesc(); set(gca, 'YDir', 'reverse'), axis image, axis off;
subplot(242); limf_h = image('CDataMapping', 'direct'); set(gca, 'YDir', 'reverse'), axis image, axis off;
subplot(243); axis square;
subplot(244); axis square;
% right eye
subplot(245); rim_h = imagesc(); set(gca, 'YDir', 'reverse'), axis image, axis off;
subplot(246); rimf_h = image('CDataMapping', 'direct'); set(gca, 'YDir', 'reverse'), axis image, axis off;
subplot(247); axis square;
subplot(248); axis square;

for i=1:length(le_file)
    le_im = imread([le_dir le_file(i).name]);
    le_y = rgb2ycbcr(le_im);
    le_y = le_y(:,:,1);
    le_ny = imadjust(le_y);
    le_nyf = medfilt2(le_ny);
    lim_h.CData = le_im;
    limf_h.CData = le_nyf;
    limf_h.CDataMapping = 'direct';
    subplot(243); histogram(le_nyf,0:255,'Normalization','probability'); xlim([0 255]), ylim([0 .1]), axis square;
    subplot(244); bar(le_cumhist(i,:)); xlim([0 255]), ylim([0 1]), axis square;
    
    re_im = imread([re_dir re_file(i).name]);
    re_y = rgb2ycbcr(re_im);
    re_y = re_y(:,:,1);
    re_ny = imadjust(re_y);
    re_nyf = medfilt2(re_ny);
    rim_h.CData = re_im;
    rimf_h.CData = re_nyf;
    rimf_h.CDataMapping = 'direct';
    subplot(247); histogram(re_nyf,0:255,'Normalization','probability'); xlim([0 255]), ylim([0 .1]), axis square;
    subplot(248); bar(re_cumhist(i,:));  xlim([0 255]), ylim([0 1]), axis square;
    
    % wait for sample rate
    pause(1/61);
end

%% Plot tau series

figure(); hold on;
title('Left Eye');
plot(le_dtau);
plot(le_tmin * ones(1,length(le_dtau)));
plot(le_tmax * ones(1,length(le_dtau)));
plot(le_td * ones(1,length(le_dtau)));
legend('tmin', 'tmax', 'td');

figure(); hold on;
title('Right Eye');
plot(re_dtau);
plot(re_tmin * ones(1,length(re_dtau)));
plot(re_tmax * ones(1,length(re_dtau)));
plot(re_td * ones(1,length(re_dtau)));
legend('tmin', 'tmax', 'td');
