clear all;
close all;

%% Import needed paths
addpath('utils/');
addpath('movies/')
addpath('classifier_blink_detector/');
addpath('eye_region_extractor/');

%% Load ground Truth value
load('blink_ground_truth.mat');

%% Load Pre-trained classifiers Model
load('bof_svm_classifier');

%% Load files paths
points_mat_path = 'eye_region_extractor/mat_data_face_p99/';

movies_root_path = 'movies_fix/';
movies_path = dir([movies_root_path '*.avi']);
movies_path = sort_nat({movies_path.name});

output_movies_path = 'blinks_svm_movie/';
if ~exist(output_movies_path, 'file')
    mkdir(output_movies_path);
end

% initialize output frame
v_in = VideoReader([movies_root_path char(movies_path(1))]);
f = figure('Position', [0 0 v_in.Width+50 v_in.Height+50], 'Visible', 'off', 'MenuBar', 'none', 'ToolBar', 'none', 'Color', 'k');
clear v_in;

% video frames
video_frame_h = subtightplot(2,3,4:5);
im_h = imagesc();
set(gca, 'YDir', 'reverse');
axis image, axis off, hold on;
curv = [0 0]; % plot a rectangle
r_rect_h = rectangle('Parent', gca, 'Position', [0 0 0 0], 'Curvature', curv);
l_rect_h = rectangle('Parent', gca, 'Position', [0 0 0 0], 'Curvature', curv);

% eye region
l_eye_h = subtightplot(2,3,1);
l_eye_im_h = imagesc();
set(gca, 'YDir', 'reverse');
axis image, axis off, hold on;

r_eye_h = subtightplot(2,3,2);
r_eye_im_h = imagesc();
set(gca, 'YDir', 'reverse');
axis image, axis off, hold on;

% text box
text_h = subtightplot(2,3,[3 6]);
axis off, hold on;
t_h = text('Units', 'normalized', 'Position', [ .45 .8 ], 'String', 'Open', 'BackgroundColor', 'g', 'FontSize', 18, 'Margin', 20);
blinks = 0;
b_h = text('Units', 'normalized', 'Position', [ .2 .5 ], 'String', sprintf('Blink counter: %d', blinks), 'BackgroundColor', 'w','FontSize', 14);
gt_h = text('Units', 'normalized', 'Position', [ .2 .4 ], 'String', sprintf('Ground truth: %d', 0), 'BackgroundColor', 'w', 'FontSize', 14);

%% Process Video to plot
for m_id=1:length(movies_path)
    m = char(movies_path(m_id));
    sub_id = char(strrep(m, '.avi', ''));
    fprintf('Process video from subject #%s ...\n', sub_id);
    tic;
    
    v_in = VideoReader([movies_root_path m]);
    v_out = VideoWriter([output_movies_path m]);
    set(v_out, 'FrameRate', v_in.FrameRate);
    open(v_out);
    
    % Prepare data
    d = load([points_mat_path sub_id '.mat']);
    
    % Interpolate missing frames value
    x = interpolatePoints(d.data.xpoints);
    y = interpolatePoints(d.data.ypoints);
    
    clear d
    
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
    
    scale_factor = 2;
    ab = 60*scale_factor;
    cd = 40*scale_factor;
    
    % update rectangle
    r_rect_h.Position = [medrx(1)*scale_factor-ab/2 medry(1)*scale_factor-cd/2 ab cd];
    l_rect_h.Position = [medlx(1)*scale_factor-ab/2 medly(1)*scale_factor-cd/2 ab cd];

    % reset blinks
    blinks = 0;
    b_h.String = sprintf('Blink counter: %d', blinks);

    % update ground truth text
    gt_h.String = sprintf('Ground truth: %d', blink_gt(m_id));
    
    is_open = false;
    % Export eye regions for each frame
    for i=1:size(medrx,1)
        
        fprintf('%d, ', i);
        if mod(i,20) == 0, fprintf('\n'); end
        
        frame = readFrame(v_in);
        frame = imresize(frame, scale_factor);
        
        % get eye images
        l_im = imcrop(frame,[medlx(i)*scale_factor-ab/2 medly(i)*scale_factor-cd/2 ab cd]);
        r_im = imcrop(frame,[medrx(i)*scale_factor-ab/2 medry(i)*scale_factor-cd/2 ab cd]);
        
        % classify eye images
        [l_labelIdx, l_score] = predict(l_eye_classifier.categoryClassifier, l_im);
        [r_labelIdx, r_score] = predict(r_eye_classifier.categoryClassifier, r_im);
        l_label = l_eye_classifier.categoryClassifier.Labels(l_labelIdx);
        r_label = r_eye_classifier.categoryClassifier.Labels(r_labelIdx);
        
        % draw frames
        im_h.CData = frame;
        l_eye_im_h.CData = l_im;
        r_eye_im_h.CData = r_im;
        l_rect_h.Position = [medlx(i)*scale_factor-ab/2 medly(i)*scale_factor-cd/2 ab cd];
        r_rect_h.Position = [medrx(i)*scale_factor-ab/2 medry(i)*scale_factor-cd/2 ab cd];
        
        if (strcmp(l_label, 'close') && abs(l_score(1)) < 0.1) && ...
           (strcmp(r_label, 'close') && abs(r_score(1)) < 0.1),
       
            if is_open,
                blinks = blinks + 1;
                b_h.String = sprintf('Blinks: %d', blinks);
                b_h.Color = 'r';
            end
            t_h.BackgroundColor = 'r';
            t_h.Color = 'w';
            t_h.String = 'Blink';
            is_open = false;
        else
            is_open = true;
            b_h.Color = 'k';
            t_h.Color = 'k';
            t_h.BackgroundColor = 'g';
            t_h.String = 'Open';
        end
        
        % write frame to video file
        writeVideo(v_out, getframe(f));
        clear frame
    end
    
    fprintf('completed in %f seconds\n', toc);
    
    % close file and clear env
    close(v_out);
    clear v_out v_in
end
