function EEG = cspsg_eeg_interp(ORIEEG, bad_elec, good_elec)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% eeg_interp() - interpolate data channels
%
% 11-01-2023: Modified to work with Counting Sheep PSG.
% Stuart Fogel. University of Ottawa.
%
% Usage: EEGOUT = eeg_interp(EEG, badchans, good_elec);
%
% Inputs:
%     EEG       - EEGLAB dataset
%     badchans  - [integer array] indices of channels to interpolate.
%                 For instance, these channels might be bad.
%                 [chanlocs structure] channel location structure containing
%                 either locations of channels to interpolate or a full
%                 channel structure (missing channels in the current
%                 dataset are interpolated).
%     good_elec - [integer array] indices of good channels used to 
%                 interpolate bad channels.
%     
% Output:
%     EEGOUT   - data set with bad electrode data replaced by
%                interpolated data
%
% Author: Arnaud Delorme, CERCO, CNRS, Mai 2006-
%
% Copyright (C) Arnaud Delorme, CERCO, 2006, arno@salk.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% handle input arguments
if nargin < 3
    help eeg_interp;
    return;
end
EEG = ORIEEG;

% check channel structure
tmplocs = ORIEEG.chanlocs;
if isempty(tmplocs) || isempty([tmplocs.X])
    error('Interpolation require channel location');
end

% get channel indices for interp
badchans = bad_elec;
goodchans = good_elec;
origoodchans = setdiff_bc(1:EEG.nbchan, badchans);
EEG.data(badchans,:) = [];
EEG.nbchan = length(goodchans);

% get theta, rad of electrodes
tmpgoodlocs = EEG.chanlocs(goodchans);
xelec = [ tmpgoodlocs.X ];
yelec = [ tmpgoodlocs.Y ];
zelec = [ tmpgoodlocs.Z ];
rad = sqrt(xelec.^2+yelec.^2+zelec.^2);
xelec = xelec./rad;
yelec = yelec./rad;
zelec = zelec./rad;
tmpbadlocs = EEG.chanlocs(badchans);
xbad = [ tmpbadlocs.X ];
ybad = [ tmpbadlocs.Y ];
zbad = [ tmpbadlocs.Z ];
rad = sqrt(xbad.^2+ybad.^2+zbad.^2);
xbad = xbad./rad;
ybad = ybad./rad;
zbad = zbad./rad;

% interpolate using sperical spline method
[~, ~, ~, badchansdata] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, EEG.data(goodchans,:));

% put everything back together
tmpdata = zeros(length(bad_elec), EEG.pnts, EEG.trials);
tmpdata(origoodchans, :,:) = EEG.data;
tmpdata(badchans,:,:) = badchansdata;
EEG.data = tmpdata;
EEG.nbchan = size(EEG.data,1);
EEG = eeg_checkset(EEG);

end

%% spherical spline
function [xbad, ybad, zbad, allres] = spheric_spline( xelec, yelec, zelec, xbad, ybad, zbad, values)

newchans = length(xbad);
numpoints = size(values,2);

Gelec = computeg(xelec,yelec,zelec,xelec,yelec,zelec);
Gsph  = computeg(xbad,ybad,zbad,xelec,yelec,zelec);

% compute solution for parameters C
meanvalues = mean(values);
values = values - repmat(meanvalues, [size(values,1) 1]); % make mean zero

values = [values;zeros(1,numpoints)];
C = pinv([Gelec;ones(1,length(Gelec))]) * values;
clear values;
allres = zeros(newchans, numpoints);

% apply results
for j = 1:size(Gsph,1)
    allres(j,:) = sum(C .* repmat(Gsph(j,:)', [1 size(C,2)]));
end
allres = allres + repmat(meanvalues, [size(allres,1) 1]);

end

%% compute G function
function g = computeg(x,y,z,xelec,yelec,zelec)

unitmat = ones(length(x(:)),length(xelec));
EI = unitmat - sqrt((repmat(x(:),1,length(xelec)) - repmat(xelec,length(x(:)),1)).^2 +...
    (repmat(y(:),1,length(xelec)) - repmat(yelec,length(x(:)),1)).^2 +...
    (repmat(z(:),1,length(xelec)) - repmat(zelec,length(x(:)),1)).^2);

g = zeros(length(x(:)),length(xelec));
% dsafds
m = 4; % 3 is linear, 4 is best according to Perrin's curve
for n = 1:7
    if ismatlab
        L = legendre(n,EI);
    else % Octave legendre function cannot process 2-D matrices
        for icol = 1:size(EI,2)
            tmpL = legendre(n,EI(:,icol));
            if icol == 1, L = zeros([ size(tmpL) size(EI,2)]); end
            L(:,:,icol) = tmpL;
        end
    end
    g = g + ((2*n+1)/(n^m*(n+1)^m))*squeeze(L(1,:,:));
end
g = g/(4*pi);

end