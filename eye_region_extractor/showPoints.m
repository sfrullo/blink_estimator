function showPoints(imhandle, im, plothandle, points, color)
% set(groot,'CurrentFigure',fhandle);
imhandle.CData = im;
% hold on
% axis image
% axis off
% for i = 1:length(points)
%     x = points(i,1);
%     y = points(i,2);
%     plot(x,y, [color '.'],'markersize',15);
% end
plothandle.XData = points(:,1)';
plothandle.XData = points(:,2)';
plothandle.Color = color;
end

