clear all;
close all;

%%
addpath('classifier_blink_detector/');
addpath(genpath('eye_region_extractor'));

%%
load('classifierModel.mat');

%% Initialize landmark_estimator
% select pre-trained model
load face_p99.mat
% load face_p146_small.mat
% load multipie_independent.mat

% 5 levels for each octave
model.interval = 5;
% set up the threshold
model.thresh = min(-0.65, model.thresh);

%%
cam = webcam;

%%
f = snapshot(cam);

% Find landmarks in frame
bs = getPoints(f, model);

if ~isempty(bs)
    % Extract landmark points from first valid frame
    points = zeros(size(bs.xy,1), 2);
    for i = 1:size(bs.xy,1);
        x1 = bs.xy(i,1);
        y1 = bs.xy(i,2);
        x2 = bs.xy(i,3);
        y2 = bs.xy(i,4);
        points(i,:) = [(x1+x2)/2, (y1+y2)/2];
        npt = size(points,1);
    end
end

lx = points(getPointsOfRegion({'leye'}),1);
ly = points(getPointsOfRegion({'leye'}),2);
medlx = median(lx,2);
medly = median(ly,2);


rx = points(getPointsOfRegion({'reye'}),1);
ry = points(getPointsOfRegion({'reye'}),2);
medrx = median(rx,2);
medry = median(ry,2);

%% Initialize tracker
pointTracker = vision.PointTracker('MaxBidirectionalError', 1);
initialize(pointTracker, [medlx medly; medrx medry], f);

%%

figure();
im = imagesc();
axis image, axis off, hold on;
set(gca,'YDir', 'reverse')
l_t = text(0,.9, 'Blink', 'Units', 'normalized', 'BackgroundColor', 'g');
r_t = text(.9,.9, 'Blink', 'Units', 'normalized', 'BackgroundColor', 'g');

scale_factor = 1;
ab = 30*scale_factor;
cd = 20*scale_factor;

curv = [0 0];
r_rect_h = rectangle('Parent', gca, 'Position', [medrx(1)*scale_factor-ab/2 medry(1)*scale_factor-cd/2 ab cd], 'Curvature', curv);
l_rect_h = rectangle('Parent', gca, 'Position', [medlx(1)*scale_factor-ab/2 medly(1)*scale_factor-cd/2 ab cd], 'Curvature', curv);

%%
while true
    
    f = snapshot(cam);
    
    [points, validity] = step(pointTracker, f);
    if ~all(validity)
        
        bs = getPoints(f, model);
        
        if ~isempty(bs)
            % Extract landmark points from first valid frame
            points = zeros(size(bs.xy,1), 2);
            for i = 1:size(bs.xy,1);
                x1 = bs.xy(i,1);
                y1 = bs.xy(i,2);
                x2 = bs.xy(i,3);
                y2 = bs.xy(i,4);
                points(i,:) = [(x1+x2)/2, (y1+y2)/2];
                npt = size(points,1);
            end
        end
        
        lx = points(getPointsOfRegion({'leye'}),1);
        ly = points(getPointsOfRegion({'leye'}),2);
        medlx = median(lx,2);
        medly = median(ly,2);
        
        
        rx = points(getPointsOfRegion({'reye'}),1);
        ry = points(getPointsOfRegion({'reye'}),2);
        medrx = median(rx,2);
        medry = median(ry,2);
        
        setPoints(pointTracker, [medlx medly; medrx medry]);
        
    else
        medlx = points(1);
        medly = points(2);
        medrx = points(3);
        medry = points(4);
    end
    
    reye = imcrop(f,[medrx*scale_factor-ab/2 medry*scale_factor-cd/2 ab cd]);
    leye = imcrop(f,[medlx*scale_factor-ab/2 medly*scale_factor-cd/2 ab cd]);
    
    l_bw = double(reshape(rgb2gray(leye), 1, []));
    r_bw = double(reshape(rgb2gray(reye), 1, []));
    
    [l_label, score] = predict(l_svm, l_bw);
    [r_label, score] = predict(r_svm, r_bw);
    
    im.CData = f;
    r_rect_h.Position = [medrx*scale_factor-ab/2 medry*scale_factor-cd/2 ab cd];
    l_rect_h.Position = [medlx*scale_factor-ab/2 medly*scale_factor-cd/2 ab cd];
    if l_label == 1, l_t.BackgroundColor = 'r'; else l_t.BackgroundColor = 'g'; end
    if r_label == 1, r_t.BackgroundColor = 'r'; else r_t.BackgroundColor = 'g'; end
    
    drawnow;
    pause(1/15);
end