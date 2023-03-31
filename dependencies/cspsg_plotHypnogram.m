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

%% Get stage labels and recode
stageTime = app.handles.stageData.stageTime;
stageLabels = app.handles.userStageNames; % labels of sleep stage epoch, default: {{'W'},{'REM'},{'N1'},{'N2'},{'SWS'},{'Unscored'}}. NOTE: order important for plotting
stages = app.handles.stageData.stages;
% recode to plot
stageRecode(stages == 0) = 1;
stageRecode(stages == 1) = 3;
stageRecode(stages == 2) = 4;
stageRecode(stages == 3) = 5;
stageRecode(stages == 4) = 2;
stageRecode(stages == 5) = 6;
stageTime(find(diff(stageRecode))+1) = stageTime(find(diff(stageRecode))); % shift time at stage differences so they are aligned vertically

%% plot hyponogram
% plot the sleep stage data
figure('units', 'normalized', 'outerposition', [0 0 1 1]);
plot(stageTime,stageRecode, 'color',[0 0 0], 'LineWidth', 2); hold;
% plot REM as thick line
R = (stageRecode == 2)*2;
R(R == 0) = NaN;
plot(stageTime, R, 'color',[0 0 0], 'LineWidth', 16);
% set axes
ylim([min(stageRecode)-1 max(stageRecode)+1]) % upper and lower limits of y-axis to fit stage labels
set(gca, 'YDir', 'reverse') % reverse the y-axis
yticklabels([' ', [stageLabels(1),stageLabels(5),stageLabels(2),stageLabels(3),stageLabels(4),stageLabels(6)], ' ']) % label y-axis tick marks
xlim([0 stageTime(end-1)]) % set upper and lower limits of x-axis to fit EEG.times
colorbar('off')
% labels
title(['Hypnogram: ' app.handles.EEG.setname], 'fontweight', 'bold', 'fontsize', 16, 'Interpreter', 'none'); % figure title
xlabel('Time', 'fontweight', 'bold', 'fontsize', 16); % x-axis label
ylabel('Sleep Stage', 'fontweight', 'bold', 'fontsize', 16); % y-axis label
set(get(gca, 'YAxis'), 'FontWeight', 'bold', 'fontsize', 16); % change font
set(get(gca, 'XAxis'), 'FontWeight', 'bold', 'fontsize', 16); % change font
set(gca, 'LineWidth', 2); % adjust line width

%% Save it
saveas(gcf,[app.handles.EEG.filepath app.handles.EEG.setname '_hypnogram.png'])

end
