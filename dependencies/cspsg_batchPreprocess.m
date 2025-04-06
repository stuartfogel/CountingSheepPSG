function cspsg_batchPreprocess(app)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PREPROCESSING PIPELINE FOR PSG DATA (Counting Sheep PSG branch)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% For preprocessing PSG data in the following steps:
% 1) Re-referencing
% 2) Filtering
% 3) Downsampling
%
% NOTES ON FILTERING:
%
% Filtering done using eeglab's pop_eegfiltnew
% Filter low cut and high cut are defined per channel type (required)
%   (e.g., EEG, EMG, EOG, etc...)
% Filter type is FIR
% Filter window is Hanning (default)
% Filter transition band width is 25% of the lower passband edge, but not
% lower than 2Hz, where possible (default).
%
% Copyright Stuart Fogel, Sleep Research Laboratory, University of Ottawa
% 2025/03/23. Modifed for Counting Sheep PSG batch preprocessing.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% START BATCH PREPROCESSING "WIZZARD"
dlgTitle = 'Batch Pre-processing';
dlgQuestion = ['The following steps are part of the batch pre-processing: ' newline newline ...
    '1. Prompt to select file(s) to be preprocessed' newline newline ...
    '2. Prompt to select directory to save new files' newline newline ...
    '3. Prompt to select Re-Referencing settings (optional)' newline newline ...
    '4. Prompt to select Filter settings (optional)' newline 'Note: new optional prompt for each channel type' newline newline ...
    '5. Prompt to select Downsampling settings (optional)' newline newline ...
    'Do you want to continue?'];
choice = uiconfirm(app.figure1,dlgQuestion,dlgTitle,'Options',{'No','Next >>'});
if strcmp(choice,'No')
    return
end
clear dlgTitle dlgQuestion choice

%% SELECT EEGLAB FILES(S)
[filename,pathname] = uigetfile2({'*.set', 'eeglab dataset (*.SET)'; ...
    '*.*', 'All Files (*.*)'}, ...
    'Choose files to process', ...
    'Multiselect', 'on');
% Check the filename(s)
if isequal(filename,0) % no files were selected
    disp('User selected Cancel')
    return;
else
    if ischar(filename) % only one file was selected
        filename = cellstr(filename); % put the filename in the same cell structure as multiselect
    end
end
if ~iscell(filename)
    return % no files selected by user
else
    %% SELECT OUTPUT DIRECTORY
    disp('Please select a directory in which to save the results.');
    resultDir = uigetdir('', 'Select the directory in which to save the results');
    if ~ischar(resultDir)
        return % no directory selected by user
    else
        %% VERIFY THAT CHANLOCS AND SRATE ARE ALL IDENTICAL
        if length(filename) > 1
            for nfile = 1:length(filename)
                progress = uiprogressdlg(app.figure1,'Title','Verifying Datasets','Indeterminate','on'); progress.Message = ['Verifying that channel information and sampling rate are consistent. ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                EEG = pop_loadset('filename',filename{1,nfile},'filepath',pathname);
                chanlocs{nfile} = EEG.chanlocs;
                % chaninfo{nfile} = EEG.chaninfo; % not implemented, but might be needed in the future?
                srate{nfile} = EEG.srate;
            end
            if ~isequaln(chanlocs{1:end}) % checks that all fieldnames and field values are identical
                choice = uiconfirm(app.figure1,['Channel information is not identical for all datasets.' newline newline 'Check dataset channel information.'],'Input Error','Icon','error');
                waitfor(choice);
                return
            end
            if ~isequaln(srate{1:end}) % checks that all fieldnames and field values are identical
                choice = uiconfirm(app.figure1,['Sampling rate is not identical for all datasets.' newline newline 'Check dataset sampling rate.'],'Input Error','Icon','error');
                waitfor(choice);
                return
            end
            clear chanlocs srate
        else
            progress = uiprogressdlg(app.figure1,'Title','Loading Dataset','Indeterminate','on');
            EEG = pop_loadset('filename',filename{1,1},'filepath',pathname);
        end
        close(progress);
        %% PROMPT INPUT FOR STUDY-SPECIFIC PARAMETERS
        % note: uses truncated section of the most recently loaded dataset,
        % after verification of channel info and sampling rate to collect options
        EEG = pop_select(EEG,'time',[1 4]); % just grab 4 seconds of data
        [~,rerefOpt] = pop_reref(EEG); % get re-ref options using EEGLAB pop function
        [~,filtOpt{1}] = pop_eegfiltnew(EEG); % get filter options using EEGLAB pop function
        if ~isempty(filtOpt{1})
            dlgTitle = 'Filter additional channel types?';
            dlgQuestion = 'Do you want to filter an additional group/type of channels?';
            choice = uiconfirm(app.figure1,dlgQuestion,dlgTitle,'Options',{'Yes','No'});
            while strcmp(choice,'Yes')
                [~,filtOpt{end+1}] = pop_eegfiltnew(EEG); % get filter options using EEGLAB pop function
                dlgTitle = 'Filter additional channel types?';
                dlgQuestion = 'Do you want to filter an additional group/type of channels?';
                choice = uiconfirm(app.figure1,dlgQuestion,dlgTitle,'Options',{'Yes','No'});
            end
        end
        [~,dsOpt] = pop_resample(EEG); % get resample options using EEGLAB pop function
        clear EEG
        %% RUN PREPROCESSING
        if isempty(rerefOpt) && isempty(filtOpt{:}) && isempty(dsOpt)
            return % all steps cancelled by user. But why?
        else
            %% PREPROCESS EACH FILE
            for nfile = 1:length(filename)
                %% LOAD DATASET
                progress = uiprogressdlg(app.figure1,'Title','Loading Dataset','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                EEG = pop_loadset('filename',filename{1,nfile},'filepath',pathname);
                EEG = eeg_checkset(EEG);
                disp(['File: ',filename{1,nfile},' loaded'])
                %% UPDATE FILE NAME AND SET NAME INFO
                if ~isempty(rerefOpt) && isempty(filtOpt{:}) && isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_reref'));
                end
                if isempty(rerefOpt) && ~isempty(filtOpt{:}) && isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_filt'));
                end
                if isempty(rerefOpt) && isempty(filtOpt{:}) && ~isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_ds'));
                end
                if ~isempty(rerefOpt) && ~isempty(filtOpt{:}) && isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_reref_filt'));
                end
                if isempty(rerefOpt) && ~isempty(filtOpt{:}) && ~isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_filt_ds'));
                end
                if ~isempty(rerefOpt) && isempty(filtOpt{:}) && ~isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_reref_ds'));
                end
                if ~isempty(rerefOpt) && ~isempty(filtOpt{:}) && ~isempty(dsOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_reref_filt_ds'));
                end
                if isempty(rerefOpt) && isempty(filtOpt{:}) && isempty(dsOpt)
                    error('INVALID PARAMETER: CHOOSE AT LEAST ONE PREPROCESSING STEP!')
                end
                EEG.filename = char(strcat(EEG.setname,'.set'));
                EEG.filepath = [resultDir,filesep];
                outputPath = EEG.filepath;
                outputFile = EEG.filename;
                %% 1) RE-REFERENCE
                try
                    if ~isempty(rerefOpt)
                        progress = uiprogressdlg(app.figure1,'Title','Re-referencing Dataset','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                        eval(rerefOpt); % run re-referenceing using history options
                    end
                catch
                    choice = uiconfirm(app.figure1,'Re-Referencing failed. Check study-specific parameters.','Input Error','Icon','error');
                    waitfor(choice);
                    return
                end
                %% 2) FILTER BASED ON CHANNEL TYPE
                try
                    if ~isempty(filtOpt{:})
                        progress = uiprogressdlg(app.figure1,'Title','Filtering Dataset','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                        for nFilt = 1:length(filtOpt)
                            eval(filtOpt{nFilt}); % run filter using history options
                        end
                    end
                catch
                    choice = uiconfirm(app.figure1,'Filtering failed. Check study-specific parameters.','Input Error','Icon','error');
                    waitfor(choice);
                    return
                end
                %% 3) DOWNSAMPLE
                try
                    if ~isempty(dsOpt)
                        progress = uiprogressdlg(app.figure1,'Title','Downsampling Dataset','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                        eval(dsOpt); % run downsample using history options
                    end
                catch
                    choice = uiconfirm(app.figure1,'Downsampling failed. Check study-specific parameters.','Input Error','Icon','error');
                    waitfor(choice);
                    return
                end
                %% 4) SAVE PREPROCESSED FILE
                if exist([outputPath outputFile],'file') == 2
                    dlgTitle = 'Warning!';
                    dlgQuestion = ['Overwrite protection enabled.' newline newline 'Do you want to overwrite existing files with same file name?'];
                    choice = uiconfirm(app.figure1,dlgQuestion,dlgTitle,'Options',{'Yes','No'});
                    if strcmp(choice,'Yes')
                        pop_saveset(EEG, 'filename',outputFile,'filepath',outputPath, 'savemode','onefile');
                    else
                        choice = uiconfirm(app.figure1,'User cancelled batch. Files not saved.','Error','Icon','error');
                        waitfor(choice);
                        return
                    end
                    clear dlgTitle dlgQuestion choice
                else
                    pop_saveset(EEG, 'filename',outputFile,'filepath',outputPath, 'savemode','onefile');
                end
                close(progress);
            end
            choice = uiconfirm(app.figure1,'Batch pre-processing complete!','Batch Processing','Icon','success');
            waitfor(choice);
        end
    end
end
end