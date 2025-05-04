function countingSheepPSG

%% Launch splash screen prior to launch app

% add directories to path
sleepPath = which('countingSheepPSG');
addpath(genpath(fileparts(sleepPath)));

% create a figure that is not visible yet, and has minimal titlebar properties
fh = figure('Visible','off','MenuBar','none','NumberTitle','off','DockControls','off');
% put an axes in it
ah = axes('Parent',fh,'Visible','on');
% put the image in it
ih = imshow('CountingSheepPSGsplash.jpg','Parent',ah);
% set the figure1 size to be just big enough for the image, and centered at the center of the screen
imxpos = get(ih,'XData');
imypos = get(ih,'YData');
set(ah,'Unit','Normalized','Position',[0,0,1,1]);
figpos = get(fh,'Position');
figpos(3:4) = [imxpos(2) imypos(2)];
set(fh,'Position',figpos);
movegui(fh,'center')
% make the figure1 visible
set(fh,'Visible','on');
pause(3);
close(fh);

countingSheepPSGapp

end