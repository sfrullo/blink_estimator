%% 
clear all;
close all;

%%
addpath('../utils');

%%
l_eye_dataset = '../eyes_dataset_small/left';
r_eye_dataset = '../eyes_dataset_small/right';

%% Train SVM a classifier
% The script extract bag-of-feature feature vectors of images in
% eye_dataset_small and trains a linear SVM classifier. A
% categoryClassifier object was created and it could be use to predict the
% category of a new image.

if exist('bof_svm_classifier.mat', 'file'),
    load bof_svm_classifier.mat;
else
    trainingset_percentage = .3;
    verboseflag = true;
    l_eye_classifier = train_svm_with_bof(l_eye_dataset, trainingset_percentage, verboseflag);
    r_eye_classifier = train_svm_with_bof(r_eye_dataset, trainingset_percentage, verboseflag);
    save('bof_svm_classifier.mat', '*_eye_classifier');
end

%%
figure();
subplot(121);
l_im_h = imagesc;
hold on;
axis image;
axis off;
set(gca, 'YDir', 'reverse');
l_t = text(0,0, '', 'BackgroundColor', 'g');

subplot(122);
r_im_h = imagesc;
hold on;
axis image;
axis off;
set(gca, 'YDir', 'reverse');
r_t = text(0,0, '', 'BackgroundColor', 'g');

%%
l_im_root_dir = 'eyes_dataset/28/left/';
l_im_dir = dir([ l_im_root_dir '*.jpg']);
l_im_dir = sort_nat({l_im_dir.name});

r_im_root_dir = 'eyes_dataset/28/right/';
r_im_dir = dir([ r_im_root_dir '*.jpg']);
r_im_dir = sort_nat({r_im_dir.name});

for i=75%:length(l_im_dir)
    l_im = imread([l_im_root_dir char(l_im_dir(i))]);
    r_im = imread([r_im_root_dir char(r_im_dir(i))]);
    
    % images classification
    [l_labelIdx, l_score] = predict(l_eye_classifier.categoryClassifier, l_im);
    [r_labelIdx, r_scores] = predict(r_eye_classifier.categoryClassifier, r_im);    

    l_im_h.CData = l_im;
    r_im_h.CData = r_im;
    
    if strcmp(l_eye_classifier.categoryClassifier.Labels(l_labelIdx), 'open'),
        l_t.String = 'Open';
    else
        l_t.String = 'Close';
    end
    
    if strcmp(r_eye_classifier.categoryClassifier.Labels(r_labelIdx), 'open')
        r_t.String = 'Open';
    else
        r_t.String = 'Close';
    end
      
    pause(1/61);
end