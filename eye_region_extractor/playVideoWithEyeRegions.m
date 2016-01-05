function playVideoWithEyeRegions(sub_id, nframes)

if nargin < 2,
    nframes = nan;
end

% Import data
sub_id = num2str(sub_id);
v = VideoReader(['../movies/' sub_id '.avi']);
load(['mat_data_face_p99/' sub_id '.mat']);

% Interpolate missing frames value
x = interpolatePoints(data.xpoints);
y = interpolatePoints(data.ypoints);

% Get only eyes landmarks
rx = x(:, getPointsOfRegion({'reye'}));
ry = y(:, getPointsOfRegion({'reye'}));
lx = x(:, getPointsOfRegion({'leye'}));
ly = y(:, getPointsOfRegion({'leye'}));

% Compute median values for each frame
medrx = median(rx,2);
medry = median(ry,2);
medlx = median(lx,2);
medly = median(ly,2);

% Plot on frames
f = readFrame(v);

figure('Position', [20 20 750 750]);
ih = imagesc(f);
set(gca, 'YDir', 'reverse');
hold on; axis image; axis off;
% plot landmarks
rploth = plot(rx(1,:), ry(1,:), 'r.', 'MarkerSize', 12);
lploth = plot(lx(1,:), ly(1,:), 'r.', 'MarkerSize', 12);
% plot median point
rmedploth = plot(medrx(1), medry(1), 'y.', 'MarkerSize', 12);
lmedploth = plot(medlx(1), medly(1), 'y.', 'MarkerSize', 12);
% plot eye region based on median point
ab = 60;
cd = 40;
%curv = [1 1]; % plot an ellipse
curv = [0 0]; % plot a rectangle
rrecth = rectangle('Position', [medrx(1)-ab/2 medry(1)-cd/2 ab cd], 'Curvature', curv);
lrecth = rectangle('Position', [medlx(1)-ab/2 medly(1)-cd/2 ab cd], 'Curvature', curv);

if isnan(nframes), 
    nframes = size(rx,1); 
end

for i=2:nframes
    f = readFrame(v);
    ih.CData = f;
    
    % update landmarks plot
    rploth.XData = rx(i,:);
    rploth.YData = ry(i,:);
    
    lploth.XData = lx(i,:);
    lploth.YData = ly(i,:);
    
    % update median point 
    rmedploth.XData = medrx(i,:);
    rmedploth.YData = medry(i,:);
    
    lmedploth.XData = medlx(i,:);
    lmedploth.YData = medly(i,:);
    
    % update rectangles
    rrecth.Position = [medrx(i)-ab/2 medry(i)-cd/2 ab cd];
    lrecth.Position = [medlx(i)-ab/2 medly(i)-cd/2 ab cd];
    
    % wait frame rate
    pause(1/v.FrameRate);
end
end
