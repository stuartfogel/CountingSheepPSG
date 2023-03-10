function [electrodes , colors] = sleep_montage_default(app)

%% IMPORTANT: DO NOT MODIFY, MOVE, DELETE OR RENAME THIS FILE
% USE THIS FILE AS A TEMPLATE TO MANUALLY CREATE NEW MONTAGES
% Create a new montage by 'saving as' a new file, and then, modify below

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% User-defined scoring montage settings required by countingSheep
%
% Author:   Stuart Fogel, University of Ottawa Sleep Research Laboratory
% Contact:  sfogel@uottawa.ca
% Date:     November 26, 2022
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USER-DEFINED SETTINGS FOR COUNTING SHEEP

% Electrode names that should be ploted
% The order is from the BOTTOM of the axes to the TOP of the axes

electrodes = {'EMG';'REOG';'LEOG';'Oz';'Pz';'Cz';'Fz'};

% Colours for each electrode (k=black, r=red, b=blue)
% The order and length must match the electrode list

colors = 'kbbkkkk';

% IMPORTANT!!! stages = list of sleep stage event labels in eeglab dataset.
% labels must correspond inclusively in the following order, with 6 stages to match numerical coding scheme: 
% Wake = 0; NREM1 = 1; NREM2 = 2; SWS = 3; REM = 5; Unscored = 6)
stages = {'W';'N1';'N2';'SWS';'REM';'Unscored'};

% epoch length for sleep stages (e.g., 30)
winSize = 30;

% lights on/off event labels
lightsONtag = 'Lights On';
lightsOFFtag = 'Lights Off';

% recording start time event format
recStartFormat = 'yyyy-mm-dd HH:MM:SS.FFF';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

app.handles.userChannelLabels = electrodes;
app.handles.userChannelColors = colors;
app.handles.userStageNames = stages;
app.handles.userlightsONtag = lightsONtag;
app.handles.userlightsOFFtag = lightsOFFtag;
app.handles.userRecStartFormat = recStartFormat;
app.handles.winIN = num2str(winSize);

end