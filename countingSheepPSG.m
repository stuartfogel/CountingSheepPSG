function countingSheepPSG(EEG)

%% Launch splash screen prior to launch app

% Copyright (C) Stuart Fogel & Sleep Well, 2026.
% 
% This file is part of 'Counting Sheep PSG'.
%
% See https://github.com/stuartfogel/CountingSheepPSG for details.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
% 1. Redistributions of source code must retain the above author, licence, 
% copyright notice, this list of conditions, and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above author, 
% licence, copyright notice, this list of conditions, and the following 
% disclaimer in the documentation and/or other materials provided with the 
% distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
% 
% THIS SOFTWARE IS INTENDED FOR RESEARCH PURPOSES ONLY. ANY COMMERCIAL 
% USE OR MEDICAL USE OF THIS SOFTWARE AND SOURCE CODE IS STRICTLY 
% PROHIBITED.

% add directories to path
sleepPath = which('countingSheepPSG');
addpath(genpath(fileparts(sleepPath)));

% kudos to julianfperez for this code
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

if nargin < 1
    countingSheepPSGapp
else
    countingSheepPSGapp(EEG)
end

end