function points = interpolatePoints(points)
% INTERPOLATEPOINTS function interpolates -inf values in singular points
% vector.
%
% It expects points matrix (or column vector) as in data structure: a NxM
% matrix with N frames and M points. Return a NxM matrix (or column vector)
% with interpolated values.

for i=1:size(points,2)
    p = points(:,i)';
    p(p == -inf) = nan;
    p(p == 0) = nan;
    t = linspace(min(p), max(p), numel(p));
    nans = isnan(p);
    p(nans) = interp1(t(~nans), p(~nans), t(nans), 'pchip');
    points(:,i) = p';
end

end

