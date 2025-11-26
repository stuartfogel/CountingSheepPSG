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

% https://www.uottawa-sleeplab.ca
% https://www.sleepwellpsg.com
%
% HOW TO CITE:
% L.B. Ray, D. Baena & S.M. Fogel (2024). “Counting sheep PSG”: EEGLAB-compatible
% open-source matlab software for signal processing, visualization, event marking
% and staging of polysomnographic data, Journal of Neuroscience Methods, 407, 110162.
% https://doi.org/10.1016/j.jneumeth.2024.110162.
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

% version
vers = '1.35'; % minor update to edit setname function

% handle input arguments from EEGLAB
if nargin < 3
    error('eegplugin_countingSheepPSG requires 3 arguments');
end

% add plugin folders to path
if exist('pop_countingSheepPSG.m','file')
    p = which('eegplugin_countingSheepPSG');
    p = p(1:strfind(p,'eegplugin_countingSheepPSG.m')-1);
    s1 = [p 'dependencies' filesep];
    s2 = [p 'icons' filesep];
    s3 = [p 'montages' filesep];
    addpath(p,s1,s2,s3);
end

% find tools menu
menu = findobj(fig, 'tag', 'tools');

% menu callbacks
countingSheepPSG_cback = [trystrs.no_check '[EEG,LASTCOM] = pop_countingSheepPSG(EEG);' catchstrs.add_to_hist trystrs.no_check '[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET);eeglab redraw;' catchstrs.add_to_hist];

% create menu
uimenu(menu, 'Label', 'Counting Sheep PSG', 'CallBack', countingSheepPSG_cback);