function [PARAM, EEG] = cspsg_detectMovement(PARAM, EEG)

%% MOVEMENT ARTIFACT DETECTION
%
% Detects movement on EMG channel using first derivative of the signal
% beyond a defined threshold.
%
% Stuart Fogel, uOttawa Sleep Research Laboratory, University of Ottawa
% sfogel@uottawa.ca
% 
% 17-02-2023: Adapted from detect_spindles toolbox to be stand-alone.
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
    PARAM.artifact = struct(...
        'suffix', '_art', ... file suffix
        'gradient_threshold', 25, ...  µV/ms, 25 works well for most good quality EMG signals. If EEG used, try 100 instead.
        'gradient_duration', 1, ... sec, 1 or 2 seconds works well for most good quality EMG signals.
        'ch_detect', 'EMG' ... channel label for EMG. Normally EMG should be used to detect movement. If not available, try EEG, but adjust above parameters.
        );
end

%% SPECIFY FILENAME(S) - OPTIONAL

% you can manually specify filenames here, or leave empty for pop-up
PARAM.pathname = '';
PARAM.filename = {'',...
    ''
    };
% Specify output directory, or leave empty to use pop-up
PARAM.resultDir = '';

%% SELECT DATASET FILES(S)

if isempty(PARAM.pathname)
    [PARAM.filename,PARAM.pathname] = uigetfile2( ...
        {'*.set', 'edf file (*.SET)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Choose files to process', ...
        'Multiselect', 'on');
    % Check the filename(s)
    if isequal(PARAM.filename,0) || isequal(PARAM.pathname,0) % no files were selected
        disp('User selected Cancel')
        return;
    else
        if ischar(PARAM.filename) % only one file was selected
            PARAM.filename = cellstr(PARAM.filename); % put the filename in the same cell structure as multiselect
        end
        disp('User selected files:')
        disp(char(PARAM.pathname))
        disp(char(PARAM.filename))
    end
end

%% SELECT OUTPUT DIRECTORY

if isempty(PARAM.resultDir)
    disp('Please select a directory in which to save the results.');
    PARAM.resultDir = uigetdir('', 'Select the directory in which to save the results');
end

%% PROCESS EACH FILE

for nFile = 1:length(PARAM.filename)

    % EEG = pop_loadset()
    EEG = pop_loadset('filename',PARAM.filename{1,nFile},'filepath',PARAM.pathname);
    EEG.setname = [EEG.setname PARAM.artifact.suffix]; % update setname
    EEG.filename = [EEG.setname '.set'];
    EEG.filepath = [PARAM.resultDir filesep];

    % setup
    GoodCh = logical(ismember({EEG.chanlocs.labels},PARAM.artifact.ch_detect));
    gradient = diff(EEG.data(GoodCh,:),1,2);
    nb_points = EEG.pnts;
    arttime = logical(sum(gradient>PARAM.artifact.gradient_threshold,1));
    tWIN = round(EEG.srate*PARAM.artifact.gradient_duration);
    WIN = -tWIN:tWIN;
    clear GoodCh gradient

    % loop over points
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
    clear tWIN WIN t CONTINUE

    % create empty EEGlab event structure to match existing to merge
    fields = fieldnames(EEG.event)';
    fields{2,1} = {};
    if ~any(ismember(fields(1,:),'channel'))
        fields(1,end+1) = {'channel'};
        [EEG.event.channel] = deal('');
    end
    movement = struct(fields{:});
    clear fields

    % create event markers
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
            movement(end+1) = struct('type','Movement', ...
                'latency',temp+t, ...
                'duration',long, ...
                'channel','', ...
                'urevent',0 ...
                );
            t = t+temp+long+1;
        end
    end
    clear nb_points arttime t CONTINUE temp long

    % Merge markers with existing events
    EEG.event = [EEG.event movement];
    EEG = eeg_checkset(EEG,'eventconsistency');
    EEG = eeg_checkset(EEG,'checkur');
    EEG = eeg_checkset(EEG);
    clear movement

    % Save dataset
    pop_saveset(EEG, 'filepath', PARAM.resultDir, 'filename', EEG.setname, 'savemode', 'onefile');
    clear EEG

end

disp('ALL DONE!!!')

end