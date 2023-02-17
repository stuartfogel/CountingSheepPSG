function cspsg_plotHypnogram(app)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Plot Hypnogram and save as png from EEGLAB dataset
%
% 18/01/2023: Stuart fogel, sfogel@uottawa.ca, University of Ottawa
%
% Copyright (C) Stuart Fogel & Sleep Well, 2022.
% See the GNU General Public License v3.0 for more information.
%
% This file is part of 'Counting Sheep PSG'.
% See https://github.com/stuartfogel/CountingSheepPSG for details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above author, license,
% copyright notice, this list of conditions, and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above author, license,
% copyright notice, this list of conditions, and the following disclaimer in
% the documentation and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.
%
% Counting Sheep PSG is intended for research purposes only. Any commercial 
% or medical use of this software and source code is strictly prohibited.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% User-defined stage labels
EEG = app.handles.EEG;
stageLabels = app.handles.userStageNames; % labels of sleep stage epoch, default: {{'W'},{'REM'},{'N1'},{'N2'},{'SWS'},{'Unscored'}}. NOTE: order important for plotting

%% find stage labels and recode

% find stages
StageTimes = zeros(1,length(EEG.times)); % times for length of recording.
StageTimes(StageTimes == 0) = 6; % change zeros to unscored = 6
stages = {EEG.event.type};
stageIndexW = find(strcmp(stages,stageLabels{1}));
stageIndexN1 = find(strcmp(stages,stageLabels{2}));
stageIndexN2 = find(strcmp(stages,stageLabels{3}));
stageIndexN3 = find(strcmp(stages,stageLabels{4}));
stageIndexR = find(strcmp(stages,stageLabels{5}));
stageIndexU = find(strcmp(stages,stageLabels{6}));

% replace with numerical code
for nStage=1:length(stageIndexW)
    StageTimes(EEG.event(stageIndexW(nStage)).latency:EEG.event(stageIndexW(nStage)).latency+EEG.event(stageIndexW(nStage)).duration-1) = 1;
end
for nStage=1:length(stageIndexN1)
    StageTimes(EEG.event(stageIndexN1(nStage)).latency:EEG.event(stageIndexN1(nStage)).latency+EEG.event(stageIndexN1(nStage)).duration-1) = 3;
end
for nStage=1:length(stageIndexN2)
    StageTimes(EEG.event(stageIndexN2(nStage)).latency:EEG.event(stageIndexN2(nStage)).latency+EEG.event(stageIndexN2(nStage)).duration-1) = 4;
end
for nStage=1:length(stageIndexN3)
    StageTimes(EEG.event(stageIndexN3(nStage)).latency:EEG.event(stageIndexN3(nStage)).latency+EEG.event(stageIndexN3(nStage)).duration-1) = 5;
end
for nStage=1:length(stageIndexR)
    StageTimes(EEG.event(stageIndexR(nStage)).latency:EEG.event(stageIndexR(nStage)).latency+EEG.event(stageIndexR(nStage)).duration-1) = 2;
end
for nStage=1:length(stageIndexU)
    StageTimes(EEG.event(stageIndexU(nStage)).latency:EEG.event(stageIndexU(nStage)).latency+EEG.event(stageIndexU(nStage)).duration-1) = 6;
end

%% plot hyponogram

% plot the sleep stage data
figure ('units', 'normalized', 'outerposition', [0 0 1 1]);
plot(EEG.times,StageTimes, 'color',[0 0 0], 'LineWidth', 2);

% set axes
ylim([min(StageTimes)-1 max(StageTimes)+1]) % upper and lower limits of y-axis to fit stage labels
set(gca, 'YDir', 'reverse') % reverse the y-axis
yticklabels([' ', {stageLabels{:}}, ' ']) % label y-axis tick marks
xlim([1 EEG.times(end)]) % set upper and lower limits of x-axis to fit EEG.times
colorbar('off')

% labels
title('Hypnogram', 'fontweight', 'bold', 'fontsize', 16); % figure title
xlabel('Time', 'fontweight', 'bold', 'fontsize', 16); % x-axis label
ylabel('Sleep Stage', 'fontweight', 'bold', 'fontsize', 16); % y-axis label
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'fontsize', 16); % change font
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'fontsize', 16); % change font
set(gca, 'LineWidth', 2); % adjust line width

% save it
saveas(gcf,[EEG.filepath EEG.setname '_hypnogram.png'])

end
