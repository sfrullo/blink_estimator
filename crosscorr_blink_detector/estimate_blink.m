function [blink_pos, blink_dur, blink_count, simple_blink_pos, simple_blink_count, thresh_comb] = estimate_blink(cc, TL, TH, showpeaks)

if nargin < 4
    showpeaks = false;
end

% thresh_comb is a Mx2 matrix with M = number of low and high threshold
% combinations
if length(TL) > 1 || length(TL) > 1,
    thresh_comb = combvec(TH,TL)';
    % invert columns to get all same lower thresholds near to each other
    thresh_comb(:, [1,2]) = thresh_comb(:, [2,1]);
else
    thresh_comb = [TL, TH];
end

% simple_blink_pos, blink_pos and blink_dur are a MxN matrix with M =
% number of low and high threshold combinations, N = length of input
% vector. They store positions (frame number) and durations of blinks
% found.
simple_blink_pos = zeros(size(thresh_comb,1),length(cc));
blink_pos = zeros(size(thresh_comb,1),length(cc));
blink_dur = zeros(size(thresh_comb,1),length(cc));

% set minimun and max peak width. Accept only blinks longer than 150ms and
% shorter than 1s.
min_ms = 50;
max_ms = 1000;
fps = 61;
min_pw = floor(min_ms * fps / 1000);
max_pw = floor(max_ms * fps / 1000);

if showpeaks
    figure();
    plot(cc);
    simple_t = title('Simple');
    hold on;
    simple_m_p = plot(0, 0, 'r*');
    simple_lt_p = plot(zeros(1, length(cc)), 'b-');
    
    figure();
    plot(cc);
    t = title('');
    hold on;
    m_p = plot(0, 0, 'r*');
    lt_p = plot(zeros(1, length(cc)), 'b-');
    ht_p = plot(zeros(1, length(cc)), 'r-');
end

tr = zeros(1,2);
for i=1:size(thresh_comb,1)
    tr(:) = thresh_comb(i,:);
    
    simple_blink = compute_simple(cc, tr(1), min_pw, max_pw);
    simple_blink_pos(i,1:length(simple_blink)) = simple_blink;
    
    [pos, dur] = compute(cc, tr(1), tr(2), min_pw, max_pw);
    blink_pos(i,1:length(pos)) = pos;
    blink_dur(i,1:length(dur)) = dur;
    
    if showpeaks
        simple_t.String = ['Simple -> TL:' num2str(tr(1)) ' TR:' num2str(tr(2))];
        simple_m_p.XData = simple_blink;
        simple_m_p.YData = cc(simple_blink);
        simple_lt_p.YData = tr(1) * ones(1,length(cc));
        
        
        t.String = ['TL:' num2str(tr(1)) ' TR:' num2str(tr(2))];
        m_p.XData = pos;
        m_p.YData = cc(pos);
        lt_p.YData = tr(1) * ones(1,length(cc));
        ht_p.YData = tr(2) * ones(1,length(cc));
        
        drawnow;
        pause(.1);
    end
end

simple_blink_pos = simple_blink_pos(:, any(simple_blink_pos));
blink_pos = blink_pos(:, any(blink_pos));
blink_dur = blink_dur(:, any(blink_dur));

% *blink_count is a column vector Mx1 with M = number of low and high
% threshold combinations. It stores the estimated number of blinks at a
% specific pair of threshold value.
simple_blink_count = sum(simple_blink_pos>0,2);
blink_count = sum(blink_pos>0,2);

end

function blinks_pos = compute_simple(cc, TL, min_pw, max_pw)
cc(cc < TL) = 0;
cc(cc > TL) = 1;
[~, blinks_pos] = findpeaks(-cc, 'MinPeakWidth', min_pw, 'MaxPeakWidth', max_pw);
end

function [blink_pos, blink_dur] = compute(cc, TL, TH, min_pw, max_pw)

blink_pos = [];
blink_dur = [];

tl_cc = [ 0 (cc < TL) 0];
%th_cc = [ 0 (cc > TH) 0];

blink_onset = find(diff(tl_cc) > 0);
%blink_offset = find(diff(th_cc) > 0);

for i=1:length(blink_onset)
    if blink_onset(i) + min_pw < length(cc) && blink_onset(i) + max_pw < length(cc)
        w = [blink_onset(i) + min_pw, blink_onset(i) + max_pw];
        w = [0 (cc(w) > TH) 0];
        blink_offset = find(diff(w) > 0);
        if ~isempty(blink_offset)
            blink_pos = [blink_pos blink_onset(i)];
            blink_dur = [blink_dur blink_offset(1) - blink_onset(i)];
        end
    end
end
end