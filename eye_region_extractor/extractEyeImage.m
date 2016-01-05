close all;
clear all;

files = dir('movies/*.avi');
for findex=1:length(files)
    %% Import data
    file = files(findex);
    sub_id = strrep(file.name, '.avi', '');
    fprintf('Extract images from subject #%s ...', sub_id);
    tic;
    v = VideoReader(['../movies/' file.name]);
    load(['mat_data_face_p99/' sub_id '.mat']);
    
    %% Make output directories
    outputdir = 'eyes_image';
    if ~exist(fullfile(outputdir,sub_id), 'dir')
        mkdir(fullfile(outputdir,sub_id));
    end
    if ~exist(fullfile(outputdir,sub_id,'left'), 'dir')
        mkdir(fullfile(outputdir,sub_id,'left'));
    end
    if ~exist(fullfile(outputdir,sub_id,'right'), 'dir')
        mkdir(fullfile(outputdir,sub_id,'right'));
    end
    
    %% Prepare data
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
    
    %% Export eye regions from frames
    for i=1:size(rx,1)
        frame = readFrame(v);
        scale_factor = 2;
        frame = imresize(frame,2);
        ab = 60*scale_factor;
        cd = 40*scale_factor;
        % get eye images
        reye = imcrop(frame,[medrx(i)*scale_factor-ab/2 medry(i)*scale_factor-cd/2 ab cd]);
        leye = imcrop(frame,[medlx(i)*scale_factor-ab/2 medly(i)*scale_factor-cd/2 ab cd]);
        % save eye images
        imwrite(reye, fullfile(outputdir,sub_id,'right',[num2str(i) '.jpg']), 'jpg');
        imwrite(leye, fullfile(outputdir,sub_id,'left',[num2str(i) '.jpg']), 'jpg');
    end
    dt = toc;
    fprintf('completed in %f seconds\n', dt);
clear frame v data;    
end