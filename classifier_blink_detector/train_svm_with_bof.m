function classifier = train_svm_with_bof(datasetpath, partition_ratio, verboseflag)
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

% Create a Visual Vocabulary and Train an Image Category Classifier
bag = bagOfFeatures(trainingSets, 'Verbose', verboseflag);
categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

% Evaluate Classifier 
% over the training set
tr_set_confMatrix = evaluate(categoryClassifier, trainingSets);

% over the validation set
val_set_confMatrix = evaluate(categoryClassifier, validationSets);

classifier.bag = bag;
classifier.categoryClassifier = categoryClassifier;
classifier.trainingset_confmatrix = tr_set_confMatrix;
classifier.validationset_confmatrix = val_set_confMatrix;