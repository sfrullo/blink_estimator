function crosscorr_blink_estimator(input_dir, output_dir)

sub_ids = dir(input_dir);
sub_ids = sort_nat({sub_ids(3:end).name});

for i=1:length(sub_ids)
    
    sub_id = char(sub_ids(i));
    fprintf('Process subject #%s ...', sub_id);
    tic; 
    
    le_dir = [input_dir '/' sub_id '/left/'];
    re_dir = [input_dir '/' sub_id '/right/'];
    
    le_file = dir([le_dir '*.jpg']);
    le_file = sort_nat({le_file.name});
    
    re_file = dir([re_dir '*.jpg']);
    re_file = sort_nat({re_file.name});
    
    % get template
    l_template = rgb2gray(imread([le_dir '/template.jpg']));
    r_template = rgb2gray(imread([re_dir '/template.jpg']));
    
    % [r,c] = size(l_template);
    % l_cc = zeros(2*r - 1, 2*c - 1, length(le_file));
%     r_cc = zeros(size(r_template,1), size(r_template,2), length(re_file));

    % compute cross-correlation between each frame and the template
    fps = 61;
    step = floor(61/fps);
    
    start_f = 1;
    stop_f = length(le_file);
    
    for j=start_f:step:stop_f
        l_im = rgb2gray(imread([le_dir char(le_file(j))]));
        r_im = rgb2gray(imread([re_dir char(re_file(j))]));
        
        % l_cc(:,:,(i-start_f)+1) = normxcorr2(l_template, l_im);
        % l_cc_max(i) = max(max(l_cc(:,:,(i-start_f)+1)));
        l_cc = normxcorr2(l_template, l_im);
        l_cc_max(j) = max(max(l_cc));

        % r_cc(:,:,(i-start_f)+1) = normxcorr2(r_template, r_im);
        % r_cc_max(i) = max(max(r_cc(:,:,(i-start_f)+1)));
        r_cc = normxcorr2(r_template, r_im);
        r_cc_max(j) = max(max(r_cc));
        
        clear *_im;
    end
    
    % Estimate blinks with simple (single threshold) and double threshold
    % methods.
    TL = .5:.01:.7;
    TH = .6:.01:.8;
    showpeaks = false;
    [l_blink_pos, l_blink_dur, l_blink_count, ...
        l_simple_blink_pos, l_simple_blink_count, ~] = estimate_blink(l_cc_max, TL, TH, showpeaks);
    
    [r_blink_pos, r_blink_dur, r_blink_count, ...
        r_simple_blink_pos, r_simple_blink_count, thresh_comb] = estimate_blink(r_cc_max, TL, TH, showpeaks);
    
    % Save subject's data
    save([output_dir '/crosscorr_s' sub_id '.mat'], '*_cc_max', '*_blink*', 'thresh_comb');
    % save([output_dir '/crosscorr_s' sub_id '.mat'], '*_cc', '-append')
    
    clear *_template *_cc *_cc_max;
    
    fprintf('completed in %f seconds.\n', toc);
end
end


