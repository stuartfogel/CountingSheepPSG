function vers = eegplugin_countingSheepPSG(fig, trystrs, catchstrs)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% eegplugin_countingSheepPSG() - EEGLAB plugin for sleep scoring, event
% marking and signal processing.
%
% Usage:
%   >> eegplugin_countingSheepPSG(fig, trystrs, catchstrs)
%
% Inputs:
%   fig        - [integer] EEGLAB figure.
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks. 
%
% See also:
%   countingSheepPSG, pop_countingSheepPSG, eeglab
%
% Dec 28, 2022: Version 1.0
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
%
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

% version
vers = '1.0';

% handle input arguments from EEGLAB
if nargin < 3
    error('eegplugin_countingSheepPSG requires 3 arguments');
end

% add plugin folder to path
if exist('pop_countingSheepPSG.m','file')
    p = which('eegplugin_countingSheepPSG');
    p = p(1:findstr(p,'eegplugin_countingSheepPSG.m')-1);
    addpath(p);
end

% find tools menu
menu = findobj(fig, 'tag', 'tools');

% menu callbacks
countingSheepPSG_cback = [trystrs.no_check '[EEG,LASTCOM] = pop_countingSheepPSG(EEG);' catchstrs.add_to_hist trystrs.no_check '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);eeglab redraw;' catchstrs.add_to_hist];

% create menu
uimenu(menu, 'Label', 'Counting Sheep PSG', 'CallBack', countingSheepPSG_cback);