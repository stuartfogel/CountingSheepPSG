function [EEG, com] = pop_countingSheepPSG(EEG)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% pop_countingSheepPSG() - EEGLAB plugin for sleep scoring, event marking
% and signal processing. If no arguments, pop up main app to create new
% montage and load or import new dataset.
%
% Usage:
%   >>  pop_countingSheepPSG; % pop up main app
%   >>  pop_countingSheepPSG(EEG); % create montage and load
%
% Inputs:
%   'EEG'   - EEG dataset structure
%
% Outputs:
%   EEG  - EEG dataset structure
%   Note: EEG output adssigned to base workspace internally from app using
%   'assignin'.
%
% See also:
%   countingSheepPSG, pop_countingSheepPSG, eeglab
%
% REQUIREMENTS:
% MATLAB version R2020a or later
% EEGlab 2020 or later (https://eeglab.org)
%
% USAGE:
% Customize display montage in:
% ~/montages/sleep_montage_default.m (rename and save to new file)
% Loads an EEGlab PSG dataset
%
% Works best if recording includes:
% - Recording start time event (at first data point)
% - Lights Off and Lights On events
%
% Sleep scoring keyboard shortcuts:
% 0 - Wake
% 1 - NREM 1
% 2 - NREM 2
% 3 - SWS
% 4 - REM
% . - Unscored
% backspace/delete - delete seelcted event(s)
%
% Event marking mode:
% Single-point events can be created using single mouse click
% Events with a duration can be created using mouse click-and-drag
% Enable 'all channels' mode to mark events without a channel
% Single-click existing event to select/deselect for delete/merge

% Dec 28, 2022: Version 1.0
%
% https://socialsciences.uottawa.ca/sleep-lab/
% https://www.sleepwellpsg.com
%
% A revision of sleepSMG. sleepSMG originally developed by:
% Stephanie Greer and Jared Saletin
% Walker Lab, UC Berekeley, 2011
% https://sleepsmg.sourceforge.net
% https://www.jaredsaletin.org/hume
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

% handle history
com = '';
if nargin < 1
    help pop_countingSheepPSG;
    return;
end

% launch Counting Sheep PSG - uses App Designer instead of EEGLAB GUI
% NOTE: App Designer does not permit output arguments!
% However, when argin = EEG, countingSheepPSG will output EEG to base workspace using 'assignin' function.
% EEG will then be output back to EEGLAB from pop function as expected.
countingSheepPSG(EEG);
com = sprintf('countingSheepPSG(%s);',inputname(1));

end