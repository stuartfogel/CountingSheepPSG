function [PARAM, EEG] = cspsg_detectMovement(PARAM, EEG)

%% MOVEMENT ARTIFACT DETECTION
%
% Detects movement on EMG channel using RMS of the signal beyond a defined
% threshold.
%
% Stuart Fogel, uOttawa Sleep Research Laboratory, University of Ottawa
% sfogel@uottawa.ca
%
% 17-02-2023: Adapted from detect_spindles toolbox to be stand-alone.
% 5-11-2025:  Adapted to use RMS of signal and SD threshold
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
%

%% CHECK INPUT ARGUMENTS

if nargin < 2
    EEG = eeg_emptyset();
end
if nargin < 1 % use defaults
    PARAM = struct(...
        'autoThresh', 1, ... 1 for default/automatic calculation of threshold
        'gradient_duration', 1, ... sec, 1 second works well for most good quality EMG signals.
        'EMGCh', 'EMG' ... channel label for EMG. Normally EMG should be used to detect movement. If not available, try EEG, but adjust above parameters.
        );
end
PARAM.suffix = '_art'; % default file suffix for batch.

%% SELECT DATASET FILES(S)

if isempty(EEG.filename)
    [PARAM.filename,PARAM.filepath] = uigetfile2( ...
        {'*.set', 'edf file (*.SET)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Choose files to process', ...
        'Multiselect', 'on');
    % Check the filename(s)
    if isequal(PARAM.filename,0) || isequal(PARAM.filepath,0) % no files were selected
        disp('User selected Cancel')
        return;
    else
        if ischar(PARAM.filename) % only one file was selected
            PARAM.filename = cellstr(PARAM.filename); % put the filename in the same cell structure as multiselect
        end
        disp('User selected files:')
        disp(char(PARAM.filepath))
        disp(char(PARAM.filename))
    end
end

%% PROCESS EACH FILE

for nFile = 1:length(PARAM.filename)

    % EEG = pop_loadset()
    EEG = pop_loadset('filename',PARAM.filename{1,nFile},'filepath',PARAM.filepath);
    EEG.setname = [EEG.setname PARAM.suffix]; % update setname
    EEG.filename = [EEG.setname '.set'];
    EEG.filepath = [PARAM.filepath filesep];

    % calculate the envelope of the signal
    PARAM.EMGChIdx = find(strcmp({EEG.chanlocs.labels}, PARAM.EMGCh));
    signal = EEG.data(PARAM.EMGChIdx,:);
    if any(isnan(signal))
        signal(isnan(signal)) = 0; % if there are sections of NaN, zero them for now.
    end
    gradient = detrend(envelope(signal,EEG.srate*10,'rms'));
    % calculate threshold
    meanSig = mean(gradient);
    stdSig = std(gradient);
    if PARAM.autoThresh == 1
        PARAM.gradient_threshold = meanSig + stdSig*0.5; % default is 0.5 SD. Note if data is very noisy / has bad data, custom may be needed.
    else % custom
        PARAM.gradient_threshold = meanSig + stdSig*PARAM.gradient_threshold;
    end
    clear meanSig stdSig
    nb_points = EEG.pnts;
    arttime = logical(sum(gradient>PARAM.gradient_threshold,1));
    tWIN = round(EEG.srate*PARAM.gradient_duration);
    WIN = -tWIN:tWIN;
    t = 0;
    CONTINUE = 1;
    while CONTINUE
        t = t+1;
        if arttime(t)
            arttime(max(min(t+WIN,nb_points-1),1)) = 1;
            t = t+tWIN;
        end
        if t > nb_points-2
            CONTINUE = 0;
        end
    end
    arttime(nb_points) = 0; % because of Diff
    % create empty EEGlab event structure to match existing to merge
    fields = fieldnames(EEG.event)';
    fields{2,1} = {};
    movement = struct(fields{:});
    clear fields
    t = 0;
    CONTINUE = 1;
    while CONTINUE
        temp = find(arttime((t+1):end),1);
        if isempty(temp)
            CONTINUE = 0;
        else
            long = find(~arttime((t+temp):end),1);
            if isempty(long)
                long = nb_points-t-temp;
                CONTINUE = 0;
            end
            movement(end+1).type = 'Movement';
            movement(end).latency = temp+t;
            movement(end).duration = long;
            movement(end).channel = ''; % all channels
            movement(end).urevent = 0;
            t = t+temp+long+1;
        end
    end
    % Merge markers with existing events
    EEG.event = [EEG.event movement];
    EEG = eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset(EEG);

    % Save dataset
    pop_saveset(EEG, 'filepath', PARAM.filepath, 'filename', EEG.setname, 'savemode', 'onefile');
    clear EEG

end

disp('ALL DONE!!!')

end