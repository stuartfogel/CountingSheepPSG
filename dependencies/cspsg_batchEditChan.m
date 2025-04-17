function cspsg_batchEditChan(app)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EDIT CHANNEL BATCH PIPELINE FOR PSG DATA (Counting Sheep PSG branch)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Copyright Stuart Fogel, Sleep Research Laboratory, University of Ottawa
% 2025/03/23. Modifed for Counting Sheep PSG batch edit channels
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        %% VERIFY THAT CHANLOCS ARE ALL IDENTICAL
        if length(filename) > 1
            for nfile = 1:length(filename)
                progress = uiprogressdlg(app.figure1,'Title','Verifying Datasets','Indeterminate','on'); progress.Message = ['Verifying that channel information and sampling rate are consistent. ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                EEG = pop_loadset('filename',filename{1,nfile},'filepath',pathname);
                chanlocs{nfile} = EEG.chanlocs;
                % chaninfo{nfile} = EEG.chaninfo; % not implemented, but might be needed in the future?
            end
            if ~isequaln(chanlocs{1:end}) % checks that all fieldnames and field values are identical
                choice = uiconfirm(app.figure1,['Channel information is not identical for all datasets.' newline newline 'Check dataset channel information.'],'Input Error','Icon','error');
                waitfor(choice);
                return
            end
            clear chanlocs
        else
            progress = uiprogressdlg(app.figure1,'Title','Loading Dataset','Indeterminate','on');
            EEG = pop_loadset('filename',filename{1,1},'filepath',pathname);
        end
        close(progress);
        %% PROMPT INPUT FOR STUDY-SPECIFIC PARAMETERS
        % note: uses truncated section of the most recently loaded dataset,
        % after verification of channel info to collect options
        EEG = pop_select(EEG,'time',[1 4]); % just grab 4 seconds of data
        [~,~,~,chOpt] = pop_chanedit(EEG); % get edit channel options using EEGLAB pop function
        clear EEG
        %% RUN PROCESSING
        if isempty(chOpt)
            return % cancelled by user
        else
            %% PROCESS EACH FILE
            for nfile = 1:length(filename)
                %% LOAD DATASET
                progress = uiprogressdlg(app.figure1,'Title','Loading Dataset','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                EEG = pop_loadset('filename',filename{1,nfile},'filepath',pathname);
                EEG = eeg_checkset(EEG);
                disp(['File: ',filename{1,nfile},' loaded'])
                %% UPDATE FILE NAME AND SET NAME INFO
                if ~isempty(chOpt)
                    EEG.setname=char(strcat(filename{1,nfile}(1:end-4),'_edCh'));
                end
                if isempty(chOpt)
                    error('INVALID PARAMETER: CHOOSE AT LEAST ONE PROCESSING STEP!')
                end
                EEG.filename = char(strcat(EEG.setname,'.set'));
                EEG.filepath = [resultDir,filesep];
                outputPath = EEG.filepath;
                outputFile = EEG.filename;
                %% EDIT CHANNELS
                try
                    if ~isempty(chOpt)
                        progress = uiprogressdlg(app.figure1,'Title','Editing Channels','Indeterminate','on'); progress.Message = ['Processing dataset ' num2str(nfile) ' of ' num2str(length(filename)) ' ...'];
                        eval(chOpt); % run re-referenceing using history options
                    end
                catch
                    choice = uiconfirm(app.figure1,'Edit channels failed. Check study-specific parameters.','Input Error','Icon','error');
                    waitfor(choice);
                    return
                end
                %% 4) SAVE PROCESSED FILE
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
            choice = uiconfirm(app.figure1,'Batch processing complete!','Batch Processing','Icon','success');
            waitfor(choice);
        end
    end
end
end