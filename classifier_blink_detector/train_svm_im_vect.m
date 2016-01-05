function classifier = train_svm_im_vect(datasetpath, partition_ratio, verboseflag)
% Import image dataset
lset = imageSet(datasetpath, 'Recursive');

% Prepare Training and Validation set
% select an equal number of image from each category
lset_min = partition(lset, min([lset.Count]), 'randomize');

%Separate the sets into training and validation data. Pick partition_ratio
%of images from each set for the training data and the remainder,
%(1-partition_ratio), for the validation data. Randomize the split to avoid
%biasing the results.
[trainingSets, validationSets] = partition(lset_min, partition_ratio, 'randomize');

% load training sets
for i=1:trainingSets(1).Count
	im_close = double(rgb2gray(read(trainingSets(1), i)));
	im_open = double(rgb2gray(read(trainingSets(2), i)));
	predictors(i,:) = reshape(im_close, 1, []);
	predictors(i+trainingSets(1).Count,:) = reshape(im_open, 1, []);
	response{i} = 'close';
	response{i+trainingSets(1).Count} = 'open';
end

% load validation sets
for i=1:trainingSets(1).Count
	im_close = double(rgb2gray(read(trainingSets(1), i)));
	im_open = double(rgb2gray(read(trainingSets(2), i)));
	validator(i,:) = reshape(im_close, 1, []);
	validator(i+trainingSets(1).Count,:) = reshape(im_open, 1, []);
	validator_labels{i} = 'close';
	validator_labels{i+trainingSets(1).Count} = 'open';
end

% Train a classifier
svm_class = fitcsvm(predictors, response, 'KernelFunction', 'linear', 'PolynomialOrder', [], 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1, 'ResponseName', 'label', 'ClassNames', {'close' 'open'});

% compute k-fold validation
crossval_svm = crossval(svm_class, 'KFold', 10);

% test on training set
[label,score] = predict(crossval_svm.Trained{1},predictors);

% compute confusion matrix on trainging set
tr_set_confMatrix = confusionmat(validator_labels,response);

% test on validation set
[label,score] = predict(crossval_svm.Trained{1},validator);

% compute confusion matrix on validation set
val_set_confMatrix = confusionmat(validator_labels,label);

classifier.categoryClassifier = crossval_svm.Trained{1};
classifier.trainingset_confmatrix = tr_set_confMatrix;
classifier.validationset_confmatrix = val_set_confMatrix;