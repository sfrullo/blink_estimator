function parallel_process_video(video_input_folder, video_output_folder, data_output_folder)

    addpath(genpath('landmark_estimator'));

    % Initialize landmark_estimator

    % select pre-trained model
    load face_p99.mat
    % load face_p146_small.mat
    % load multipie_independent.mat

    % 5 levels for each octave
    model.interval = 5;
    % set up the threshold
    model.thresh = min(-0.65, model.thresh);

    % define the mapping from view-specific mixture id to viewpoint
    if length(model.components)==13
        posemap = 90:-15:-90;
    elseif length(model.components)==18
        posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
    else
        error('Can not recognize this model');
    end

    files = dir(fullfile(video_input_folder, '*.avi'));

    % define constants
    FRAMERATE_SCALE_FACTOR = 2;
    DUR_IN_SEC = 73;

    % for each file in video input folder
    for p=1:length(files)

        file = files(p);
        fprintf('Process file %s ...', file.name);

        tic;
        v = VideoReader(fullfile(video_input_folder, file.name));
        dur = floor(v.FrameRate * DUR_IN_SEC);
        frameCount = 0;

        data = struct();
        data.model = model;
        data.posemap = posemap;
        data.file = file;
        data.trackerValidity = nan(dur,68);
        data.xpoints = -inf(dur,68);
        data.ypoints = -inf(dur,68);

        % until a valid set of landmark points was not found
        while true
            if mod(frameCount, FRAMERATE_SCALE_FACTOR) == 0
                % read frame
                videoFrame = readFrame(v);
                
                % Find landmarks in frame
                bs = getPoints(videoFrame, model);
                
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
                    % save landmark points of first valid frame
                    data.xpoints(frameCount+1,1:npt) = points(:,1)';
                    data.ypoints(frameCount+1,1:npt) = points(:,2)';
                    break;
                end
            else
                readFrame(v);
            end
            frameCount = frameCount + 1;
        end

        % Create figure and initialize handles for the first frame
        f = figure('Visible', 'off');
        imhandle = imagesc;
        set(imhandle.Parent, 'YDir', 'reverse');
        hold on;
        axis image;
        axis off;
        plothandle = plot(0,0, 'r.', 'markersize',15);
        
        showPoints(imhandle, videoFrame, plothandle, points, 'r');

        % Create Video Obj and write first frame
        vidObj = VideoWriter(fullfile(video_output_folder, file.name));
        set(vidObj, 'FrameRate', v.FrameRate / FRAMERATE_SCALE_FACTOR);
        open(vidObj);
        writeVideo(vidObj,getframe(f));

        % Initialize tracker
        pointTracker = vision.PointTracker('MaxBidirectionalError', 1);
        initialize(pointTracker, points, videoFrame);

        %clear videoFrame;

        while frameCount <= dur
            
            frameCount = frameCount + 1;

            % if the frame's number is correct to the scale factor
            if mod(frameCount, FRAMERATE_SCALE_FACTOR) == 0
                
                % Uncommet to proflie code
                % profile on;
                
                % read frame
                videoFrame = readFrame(v);

                %fprintf('%d, \n', frameCount+1)
                %if mod(frameCount, FRAMERATE_SCALE_FACTOR*20) == 0, fprintf('\n'); end

                % tracking
                [points, validity] = step(pointTracker, videoFrame);

                % if the tracker is confident for all points
                if all(validity)
                    showPoints(imhandle, videoFrame, plothandle, points, 'r');
                    
                else % else recompute landmarks
                    bs = getPoints(videoFrame, model);
                    
                    % if the estimator works correctly
                    if ~isempty(bs)
                        
                        points = zeros(size(bs.xy,1), 2);
                        for i = 1:size(bs.xy,1);
                            x1 = bs.xy(i,1);
                            y1 = bs.xy(i,2);
                            x2 = bs.xy(i,3);
                            y2 = bs.xy(i,4);
                            points(i,:) = [(x1+x2)/2, (y1+y2)/2];
                            npt = size(points,1);
                        end

                        % re-init point tracker with the new set of points
                        setPoints(pointTracker, points);

                        % plot new points with a different color
                        showPoints(imhandle, videoFrame, plothandle, points, 'y');
                    end
                end
                
                % save frame validity
                data.trackerValidity(frameCount+1,1:size(validity,1)) = validity';
                % save the new set of points
                data.xpoints(frameCount+1,1:npt) = points(:,1)';
                data.ypoints(frameCount+1,1:npt) = points(:,2)';
             
                % write current frame to file
                writeVideo(vidObj,getframe(f));
                %clear videoFrame;

            else % else skipframe
                readFrame(v);
            end
        
        % Uncomment to profile code
        % profile viewer
            
        end
        
            % close VideoWriter object
            close(vidObj)
            
            % save data variable
            save(fullfile(data_output_folder, strrep(file.name, '.avi', '')), 'data');

            % clear env
            %clear data file videoFrame pointTracker vidObj v f imhandle plothandle;

            dtime = toc;
            fprintf('completed %s in %f seconds\n', file.name, dtime);
    end
end