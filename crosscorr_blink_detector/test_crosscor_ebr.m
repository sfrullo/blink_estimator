close all;
clear all;

%%
im_dir = 'eyes_image';
sub_ids = dir('eyes_image');
sub_ids = {sub_ids(3:end).name};

le_dir = [im_dir '/' sub_id '/left/'];
re_dir = [im_dir '/' sub_id '/right/'];

le_file = dir([le_dir '*.jpg']);
le_file = sort_nat({le_file.name});

re_file = dir([re_dir '*.jpg']);
re_file = sort_nat({re_file.name});

nfile = length(le_file);

template = rgb2gray(imread([le_dir char(le_file(1))]));
%figure; image(template);
%colormap(gray);

%% Test Corr 2D
%{
% Test Open/Close eye template crosscorrelation
o_eye = rgb2gray(imread([le_dir char(le_file(3))]));
figure; image(o_eye);
colormap(gray);

c_eye = rgb2gray(imread([le_dir char(le_file(808))]));
figure; image(c_eye);
colormap(gray);

o_c = normxcorr2(template, o_eye);
figure; plot(o_c);

c_c = normxcorr2(template, c_eye);cross
figure; plot(c_c);
%}
%% Get crosscorrelation for each frame

fps = 61;
step = floor(61/fps);

start_f = 2;
stop_f = length(le_file);

for i=start_f:step:stop_f
    im = rgb2gray(imread([le_dir char(le_file(i))]));
    c(:,:,(i-start_f)+1) = normxcorr2(template, im);
    c_max((i-start_f)+1) = max(max(abs(c(:,:,(i-start_f)+1))));
end

save('crosscorr_s22', 'c');