function dataset = import_dataset(dataset_path)
disp(dataset_path)
sub_dir = dir(dataset_path);
sub_dir = {sub_dir(3:end).name};
left = [];
right = [];
for s=sub_dir
    subject_path = [dataset_path char(s)];
    left_pic = dir([subject_path '/left/*.jpg']);
    right_pic = dir([subject_path '/right/*.jpg']);
    left = [left strcat([subject_path '/left/'],{left_pic.name})];
    right = [right strcat([subject_path '/right/'],{right_pic.name})];
end
dataset = struct();
dataset.left = left;
dataset.right = right;
end