function [tau, meanIntensity, cumhist, nhist, hist,ny, nyf] = computeTau(eyeimage, Tr)

% get luminance component Y of YCbCr color space
y = rgb2ycbcr(eyeimage);
y = y(:,:,1);

% adjust image contrast
ny = imadjust(y);

% compute image mean intensity
meanIntensity = mean2(y);

% applay median filter (3-by-3 neighborhood)
nyf = medfilt2(ny);

% compute the image histogram
[hist, nbin] = imhist(nyf);

% normalize histogram
nhist = hist / numel(nyf);

% compute comulative histogram
cumhist = cumsum(nhist);

% compute tau as the highest intensity value in the histogram which is less
% than threshold Tr
tau = find(cumhist(cumhist <= Tr), 1, 'last');

end