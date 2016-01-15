%% 
clear all;
close all;

%%
addpath('../utils');

%%
l_eye_dataset = '../eyes_dataset_small/left';
r_eye_dataset = '../eyes_dataset_small/right';

partition_ratio = .3;

%% Image vector SVM classifier
l_eye_classifier = train_svm_im_vect(l_eye_dataset, partition_ratio)
r_eye_classifier = train_svm_im_vect(r_eye_dataset, partition_ratio)
save('im_vec_svm_classifier_prob.mat', 'l_eye_classifier', 'r_eye_classifier');

%% Image vector KNN classifier
l_eye_classifier = train_knn_classifier(l_eye_dataset, partition_ratio);
r_eye_classifier = train_knn_classifier(r_eye_dataset, partition_ratio);
save('knn_classifier.mat', 'l_eye_classifier', 'r_eye_classifier');

%% Bag-of-Feature SVM classifier
l_eye_classifier = train_svm_with_bof(l_eye_dataset, partition_ratio);
r_eye_classifier = train_svm_with_bof(r_eye_dataset, partition_ratio);
save('bof_svm_classifier.mat', 'l_eye_classifier', 'r_eye_classifier');
