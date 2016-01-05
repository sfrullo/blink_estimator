function playVideoWithPoints(sub_id, m, p_id, nframes)

if nargin < 2
    fprintf('Set mode to "both".\n');
    m = 'both';
end

if ~ismember(m, {'both', 'sub'})
    error('Mode parameter m must be "both" or "sub"');
end

if nargin < 3,
    fprintf('None subset of points was selected. The plot will show all points.\n');
    p_id = 1:68;
end

if nargin < 4,
    nframes = nan;
end

sub_id = num2str(sub_id);

v = VideoReader(['../movies/' sub_id '.avi']);
load(['mat_data_face_p99/' sub_id '.mat']);

xpoints = interpolatePoints(data.xpoints);
ypoints = interpolatePoints(data.ypoints);

x = xpoints(:,p_id);
y = ypoints(:,p_id);

f = readFrame(v);

if strcmp(m, 'both')
    figure('Position', [0 0 1000 1000]);
    ih1 = imagesc(f);
    set(gca, 'YDir', 'reverse');
    hold on; axis image; axis off;
    ph1 = plot(xpoints(1,:), ypoints(1,:), 'r.', 'MarkerSize', 12);
    label1 = strsplit(num2str(1:68), ' ');
    t1 = text(xpoints(1,:), ypoints(1,:), label1);
end

if ~isempty(p_id)
    figure('Position', [0 0 1000 1000]);
    ih2 = imagesc(f);
    set(gca, 'YDir', 'reverse');
    hold on; axis image; axis off;
    ph2 = plot(x(1,:), y(1,:), 'r.', 'MarkerSize', 12);
    label2 = strsplit(num2str(p_id), ' ');
    t2 = text(x(1,:), y(1,:), label2);
end

if isnan(nframes), 
    nframes = numel(x); 
end

for i=2:nframes
    f = readFrame(v);
    
    if strcmp(m, 'both')
        ih1.CData = f;
        ph1.XData = xpoints(i,:);
        ph1.YData = ypoints(i,:);
        for j=1:size(t1,1)
            t1(j).Position = [xpoints(i,j) ypoints(i,j) 0];
        end
    end
    
    if ~isempty(f_id)
        ih2.CData = f;    
        ph2.XData = x(i,:);
        ph2.YData = y(i,:);
        for j=1:size(t2,1)
            t2(j).Position = [x(i,j) y(i,j) 0];
        end
    end
    
    pause(1/v.FrameRate);
end
end