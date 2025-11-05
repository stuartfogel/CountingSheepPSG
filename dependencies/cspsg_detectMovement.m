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
%

%% CHECK FOR EEGLAB

if isempty(which('eeglab')) % check for EEGlab
    error('eeglab missing from MATLAB path')
else
    eeglab nogui; clearvars -except PARAM EEG; clc % requires EEGlab top folder to be on path
end

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