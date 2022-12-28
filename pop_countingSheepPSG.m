function [EEG, com] = pop_countingSheepPSG(EEG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pop_countingSheepPSG() - EEGLAB plugin for sleep scoring, event marking 
% and signal processing. If no arguments, pop up main app to create new 
% montage and load or import new dataset.
%
% Usage:
%   >>  EEGOUT = pop_countingSheepPSG; % pop up main app
%   >>  EEGOUT = pop_countingSheepPSG(EEG); % create montage and load
%
% Inputs:
%   'EEG'   - EEG dataset structure
%    
% Outputs:
%   EEGOUT  - EEG dataset structure
%
% See also: 
%   countingSheepPSG, pop_countingSheepPSG, eeglab
%
% REQUIREMENTS:
% MATLAB version R2019a or later
% EEGlab 2019 or later (https://eeglab.org)
%
% USAGE:
% Loads an EEGlab PSG dataset
% Customize display montage in:
% ~/montages/sleep_montage_default.m (rename and save to new file)
%
% Works best if recording includes:
% - Recording start time event (at first data point)
% - Lights Off and Lights On events
%
% SLEEP SCORING KEYBORAD SHORTCUTS:
% 0 - Wake
% 1 - NREM 1
% 2 - NREM 2
% 3 - SWS
% 4 - REM
% . - Unscored
%
% EVENT MARKING MODE:
% Note: keyboard shortcuts do not work in event marking mode
% Single point events can be created using single-click
% Events with a duration can be created using single-click (start) + shift-click (end)
% Single-click existing event to select for Delete

% Dec 28, 2022: Version 1.0
%
% Copyright (C), Stuart Fogel & Sleep Well, 2022.
% See the GNU General Public License v3.0 for more details.
% https://socialsciences.uottawa.ca/sleep-lab/
% https://www.sleepwellpsg.com
%
% A revision of sleepSMG. sleepSMG originally developed by:
% Stephanie Greer and Jared Saletin
% Walker Lab, UC Berekeley, 2011
% https://sleepsmg.sourceforge.net
% https://www.jaredsaletin.org/hume
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle history
com = '';
if nargin < 1
    help pop_countingSheepPSG;
    return;
end

% launch Counting Sheep PSG
countingSheepPSG(EEG);
com = sprintf('countingSheepPSG(%s);',inputname(1));

end