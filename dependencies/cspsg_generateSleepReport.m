function completed = cspsg_generateSleepReport(app,filename,filepath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Calculate sleep architecture report from one or more countingSheep output mat files
%
% Variables calculated from countingSheep's "stageData" structure 
% and table saved out as excel:
%
% recStartTime = Recording Start Time
% recStopTime = Recording Stop Time
% TRT = Total Recording Time
% TSWP = Total Sleep / Wake Period (Lights off to Lights on)
% TST = Total Sleep Time
% SOL = Sleep Onset Latency
% SE = Sleep Efficiency (TST / TSWP)
% NA = Number of Awakenings
% WASO = Wake after Sleep Onset
% N1latency = Sleep Latency to N1
% N2latency = Sleep Latency to N2
% SWSlatency = Sleep Latency to SWS
% REMlatency = Sleep Latency to REM
% Unscored = Unscored Time
% WAKE = Wake Time
% N1 = N1 Time
% N2 = N2 Time
% SWS = SWS Time
% REM = REM Time
% N1percent = N1 % of TST
% N2percent = N2 % of TST
% SWSpercent = SWS % of TST
% REMpercent = REM % of TST
%
% 29/11/2022: Stuart fogel, sfogel@uottawa.ca, University of Ottawa
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

completed = 0;

if nargin > 1 
    if ischar(filename) % only one file was selected
        filename = cellstr(filename); % put the filename in the same cell structure as multiselect
    end
    resultDir = [filepath filesep];
else
    filename = cellstr(app.handles.EEG.filename); % put the filename in the same cell structure as multiselect
    filepath = app.handles.EEG.filepath;
    resultDir = app.handles.EEG.filepath;
    stageData = app.handles.stageData;
end

% create empty structure
summaryTable = struct('ID',cell(1,length(filename)), ...
                      'recStartTime',cell(1,length(filename)), ...
                      'recStopTime',cell(1,length(filename)), ...
                      'lightsOFFtime',cell(1,length(filename)), ...
                      'lightsONtime',cell(1,length(filename)), ...
                      'TRT',cell(1,length(filename)), ...
                      'TSWP',cell(1,length(filename)), ...
                      'TST',cell(1,length(filename)), ...
                      'SOL',cell(1,length(filename)), ...
                      'SE',cell(1,length(filename)), ...
                      'NA',cell(1,length(filename)), ...
                      'WASO',cell(1,length(filename)), ...
                      'N1latency',cell(1,length(filename)), ...
                      'N2latency',cell(1,length(filename)), ...
                      'SWSlatency',cell(1,length(filename)), ...
                      'REMlatency',cell(1,length(filename)), ...
                      'Unscored',cell(1,length(filename)), ...
                      'WAKE',cell(1,length(filename)), ...
                      'N1',cell(1,length(filename)), ...
                      'N2',cell(1,length(filename)), ...
                      'SWS',cell(1,length(filename)), ...
                      'REM',cell(1,length(filename)), ...
                      'N1percent',cell(1,length(filename)), ...
                      'N2percent',cell(1,length(filename)), ...
                      'SWSpercent',cell(1,length(filename)), ...
                      'REMpercent',cell(1,length(filename)) ...
                      );

for nfile = 1:length(filename)
    if nargin > 1
        % load countingSheep output file
        disp(['loading data from file: ' char(filename(nfile)) '...'])
        load([filepath filesep filename{nfile}],'stageData')
    end
    % ID
    summaryTable(nfile).ID = filename{nfile}(1:end-4);
    % Recording Start Time
    summaryTable(nfile).recStartTime = datetime(datevec(stageData.recStart));
    % Recording Stop Time
    summaryTable(nfile).recStopTime = datetime(datevec(stageData.recStop));
    % Lights OFF Time
    summaryTable(nfile).lightsOFFtime = datetime(datevec(stageData.lightsOFF)); 
    % Lights ON Time
    summaryTable(nfile).lightsONtime = datetime(datevec(stageData.lightsON));
    % Total Recording Time
    summaryTable(nfile).TRT = minutes(datetime(summaryTable(nfile).recStopTime,'InputFormat','dd-MM-yyyy HH:mm:ss.SSS') - datetime(summaryTable(nfile).recStartTime,'InputFormat','dd-MM-yyyy HH:mm:ss.SSS'));
    % SE = Sleep Efficiency (TST / TSWP)
    lOFFlatency = ceil(minutes(datetime(datevec(stageData.lightsOFF)) - datetime(datevec(stageData.recStart)))/(stageData.win/60))*(stageData.win/60); % find the latency of lights off in minutes, rounded to nearest epoch
    lONlatency = floor(minutes(datetime(datevec(stageData.lightsON)) - datetime(datevec(stageData.recStart)))/(stageData.win/60))*(stageData.win/60); % find the latency of lights on in minutes, rounded to nearest epoch
    lOFFidx = find(stageData.stageTime == lOFFlatency); % find the epoch that has lights off 
    lONidx = find([stageData.stageTime stageData.stageTime(end) + stageData.win/60 stageData.stageTime(end) + 1] == lONlatency); % find the epoch that has lights on, accounting for the last epoch at end of the recording
    if lONidx == length(stageData.stages) + 1 || lONidx == length(stageData.stages) + 2 % in case the lights ON tag is right at the end of the recording, round it down
        lONidx = length(stageData.stages);
    end
    summaryTable(nfile).SE = round(((sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2)) * stageData.win) / seconds(datetime(datevec(stageData.lightsON)) - datetime(datevec(stageData.lightsOFF)))) * 100,2);
    clear lOFFlatency lONlatency
    % Total Sleep / Wake Period (Lights off to Lights on)
    summaryTable(nfile).TSWP = stageData.stageTime(lONidx) - stageData.stageTime(lOFFidx) + stageData.win/60;
    % Total Sleep Time
    summaryTable(nfile).TST = minutes(seconds(sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4)) * stageData.win));
    % Sleep Onset Latency
    summaryTable(nfile).SOL = stageData.stageTime(find(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2),1));
    % NA = Number of Awakenings
    summaryTable(nfile).NA = length(find(find(diff(stageData.stages(lOFFidx:lONidx)' == 0) == 1)));
    % Wake after Sleep Onset
    WASO = stageData.stages' == 0;
    summaryTable(nfile).WASO = minutes(seconds(sum(WASO(find(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2),1):end)) * stageData.win));
    clear WASO
    % N1latency = Sleep Latency to N1
    summaryTable(nfile).N1latency = minutes(minutes(stageData.stageTime(find(stageData.stages(lOFFidx:lONidx)' == 1,1))));
    % N2latency = Sleep Latency to N2
    summaryTable(nfile).N2latency = minutes(minutes(stageData.stageTime(find(stageData.stages(lOFFidx:lONidx)' == 2,1))));
    % SWSlatency = Sleep Latency to SWS
    summaryTable(nfile).SWSlatency = minutes(minutes(stageData.stageTime(find(stageData.stages(lOFFidx:lONidx)' == 3,1))));
    % REMlatency = Sleep Latency to REM
    summaryTable(nfile).REMlatency = minutes(minutes(stageData.stageTime(find(stageData.stages(lOFFidx:lONidx)' == 4,1))));
    % Unscored = Unscored Time
    summaryTable(nfile).Unscored = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 5) * stageData.win));
    % WAKE = Wake Time
    summaryTable(nfile).WAKE = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 0) * stageData.win));
    % N1 = N1 Time
    summaryTable(nfile).N1 = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 1) * stageData.win));
    % N2 = N2 Time
    summaryTable(nfile).N2 = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 2) * stageData.win));
    % SWS = SWS Time
    summaryTable(nfile).SWS = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 3) * stageData.win));
    % REM = REM Time
    summaryTable(nfile).REM = minutes(seconds(sum(stageData.stages(lOFFidx:lONidx)' == 4) * stageData.win));
    % N1percent = N1 % of TST
    summaryTable(nfile).N1percent = round((seconds(sum(stageData.stages(lOFFidx:lONidx)' == 1) * stageData.win) / seconds(sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2)) * stageData.win)) * 100,2);
    % N2percent = N2 % of TST
    summaryTable(nfile).N2percent = round((seconds(sum(stageData.stages(lOFFidx:lONidx)' == 2) * stageData.win) / seconds(sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2)) * stageData.win)) * 100,2);
    % SWSpercent = SWS % of TST
    summaryTable(nfile).SWSpercent = round((seconds(sum(stageData.stages(lOFFidx:lONidx)' == 3) * stageData.win) / seconds(sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2)) * stageData.win)) * 100,2);
    % REMpercent = REM % of TST
    summaryTable(nfile).REMpercent = round((seconds(sum(stageData.stages(lOFFidx:lONidx)' == 4) * stageData.win) / seconds(sum(sum(stageData.stages(lOFFidx:lONidx)' == 1:4,2)) * stageData.win)) * 100,2);
    clear stageData lOFFidx lONidx
end

% Save output file
if length(filename) == 1
    oututFilename = strrep(filename{1}(1:end-4),'.mat','.xlsx');
    oututFilename = [oututFilename '_SleepReport.xlsx'];
else
    timeStamp = strrep(strrep(datestr(datetime("now")),' ','-'),':','-');
    oututFilename = ['SleepReport_' timeStamp '.xlsx'];
end
writetable(struct2table(summaryTable),[resultDir oututFilename],'Sheet','summaryTable');
clear filename filepath resultDir summaryTable oututFilename

completed = 1;

end
