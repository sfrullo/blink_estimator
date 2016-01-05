function points = getPointsOfRegion(regions)

regions_name = {'mouth', 'eyes', 'leye', 'reye', 'eyebrows' , 'nose', 'face'};

if nargin < 1
    s = 'At least a region must be selected. Please select one of: ';
    for i=regions_name
        s = sprintf('%s %s ',s, char(i));
    end
    error(s)
end

regions = lower(regions);
%fprintf('Region selected:\n');
for i=1:numel(regions)
    if ~ismember(regions{i}, regions_name);
        error('%s is not a valid region.', regions{i});
    end
    %fprintf('\t%s\n', regions{i});
end

mouth = 39:51;
leye = 10:15;
reye = 21:26;
eyes = [leye reye];
eyebrows = [16:17 27:31];
nose = 1:9;
face = 52:68;

points = [];
for i=1:length(regions)
    switch regions{i}
        case {'mouth'}
            points = [points mouth];
        case {'leye'}
            points = [points leye];
        case {'reye'}
            points = [points reye];
        case {'eyes'}
            points = [points eyes];
        case {'eyebrows'}
            points = [points eyebrows];
        case {'nose'}
            points = [points nose];
        case {'face'}
            points = [points face];
    end
end

points = unique(points);

end

