clear all;
close all;

%% Load images paths
dataset_path = 'eyes_dataset_small/';
close_eyes_path = import_dataset([dataset_path 'close_eye/']);
open_eyes_path = import_dataset([dataset_path 'open_eye/']);


%% Import left images
n_close = length(close_eyes_path.left(1,:));
for i=1:n_close
    im = rgb2gray(imread(close_eyes_path.left{i}));
    close_eye(i,:) = reshape(im.',1,[]);
end
open_eye_data = open_eyes_path.left(1,:);
n_open = length(open_eye_data);
for i=1:n_open
    im = rgb2gray(imread(open_eyes_path.left{i}));
    open_eye(i,:) = reshape(im.',1,[]);
end

%%
label = [ones(n_close,1);zeros(n_open,1)];
training_value = [close_eye;open_eye];

%% Left eye training set
l_training_value = table(training_value);
l_training_value.label = label;

clear i im label training_value close_eye open_eye n_close n_open

%% Import Right images
n_close = length(close_eyes_path.right(1,:));
for i=1:n_close
    im = rgb2gray(imread(close_eyes_path.right{i}));
    close_eye(i,:) = reshape(im.',1,[]);
end
open_eye_data = open_eyes_path.right(1,:);
n_open = length(open_eye_data);
for i=1:n_open
    im = rgb2gray(imread(open_eyes_path.right{i}));
    open_eye(i,:) = reshape(im.',1,[]);
end

%%
label = [ones(n_close,1);zeros(n_open,1)];
training_value = [close_eye;open_eye];

%% Right Eye training Set
r_training_value = table(training_value);
r_training_value.label = label;

%% training SVM Classifier
fprintf('training_valueing SVM classifier..');
[l_svm, l_accuracy] = train_svm_classifier(l_training_value);
[r_svm, r_accuracy] = train_svm_classifier(r_training_value);
fprintf('done\n');


%% training Knn Classifier
fprintf('training_valueing KNN classifier..');
[l_knn, l_accuracy] = train_knn_classifier(l_training_value);
[r_knn, r_accuracy] = train_knn_classifier(r_training_value);
fprintf('done\n');

fprintf('Saving models..')
save('classifierModel.mat', 'l_svm', 'r_svm', 'l_knn', 'r_knn');
fprintf('done\n');

clear i im open_eye_data open_eyes_path close_eyes_path dataset_path
