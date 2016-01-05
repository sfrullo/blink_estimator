openclose = 'open';
filepath = [ openclose '_eye/'];
d = dir(filepath);
d = {d(3:end).name};

if ~exist('left', 'file')
    mkdir('left');
end
if ~exist('right', 'file')
    mkdir('right');
end

for i = 1:length(d)

    lfile = dir([filepath char(d(i)) '/left/*.jpg']);
    rfile = dir([filepath char(d(i)) '/right/*.jpg']);

    for j = 1:length(lfile)
        movefile([filepath char(d(i)) '/left/' lfile(j).name], ['left/' openclose '/' char(d(i)) '_' lfile(j).name]);
    end
    
    for j = 1:length(rfile)
        movefile([filepath char(d(i)) '/right/' rfile(j).name], ['right/' openclose '/' char(d(i)) '_' rfile(j).name]);
    end
end

