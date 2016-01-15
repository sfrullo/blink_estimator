function classifier = train_svm_im_vect(datasetpath, partition_ratio)
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
for i=1:validationSets(1).Count
	im_close = double(rgb2gray(read(validationSets(1), i)));
	im_open = double(rgb2gray(read(validationSets(2), i)));
	validator(i,:) = reshape(im_close, 1, []);
	validator(i+trainingSets(1).Count,:) = reshape(im_open, 1, []);
	validator_labels{i} = 'close';
	validator_labels{i+trainingSets(1).Count} = 'open';
end

% Train a classifier
svm_class = fitcsvm(predictors, response, 'KernelFunction', 'linear', 'PolynomialOrder', [], 'KernelScale', 'auto', 'BoxConstraint', 1, 'Standardize', 1, 'ResponseName', 'label', 'ClassNames', {'close' 'open'});

% compute k-fold validation
crossval_svm = crossval(svm_class, 'KFold', 10);

for i=1:length(crossval_svm.Trained),
    [label,~] = predict(crossval_svm.Trained{i},validator);
    val_set_confMatrix = confusionmat(validator_labels,label); 
    val_set_confMatrix = val_set_confMatrix ./ repmat(sum(val_set_confMatrix,1)',1,2);
    cls(i) = mean(diag(val_set_confMatrix));
end

[~, i_max] = max(cls);

% test on training set
[label,~] = predict(crossval_svm.Trained{i_max},predictors);

% compute confusion matrix on trainging set
tr_set_confMatrix = confusionmat(response,label);
tr_set_confMatrix = tr_set_confMatrix ./ repmat(sum(tr_set_confMatrix,1)',1,2);

% test on validation set
[label,~] = predict(crossval_svm.Trained{i_max},validator);

% compute confusion matrix on validation set
val_set_confMatrix = confusionmat(validator_labels,label);
val_set_confMatrix = val_set_confMatrix ./ repmat(sum(val_set_confMatrix,1)',1,2);

% Fit posterior probabilities to find score to posterior probabilities
% transformation function
[ScoreCVSVMModel,ScoreParameters] = fitSVMPosterior(crossval_svm.Trained{i_max}, predictors, response);

classifier.categoryClassifier = ScoreCVSVMModel;
classifier.trainingset_confmatrix = tr_set_confMatrix;
classifier.validationset_confmatrix = val_set_confMatrix;