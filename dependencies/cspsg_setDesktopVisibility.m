function currentState = cspsg_setDesktopVisibility(newState)

% setDesktopVisibility displays or hides the Matlab desktop window
%
% Syntax:
%    currentState = setDesktopVisibility(newState)
%
% Description:
%    setDesktopVisibility(newState) sets the Matlab desktop window
%    visibility state. Valid values for newState are true, false, 'on' &
%    'off' (case insensitive).
%
%    Note: when the desktop visibility is false/'off' (i.e. hidden), the
%    command window is not accessible for user input. Therefore, this
%    function is very useful for GUI-based applications but not for regular
%    interactive (command-window) use.
%
%    state = setDesktopVisibility returns the current visibility state of
%    the desktop window (prior to any modification). The returned state is
%    either true/false (Matlab 7) or 'on'/'off' (Matlab 6).
%
%    A minor modification of this function will enable any interested user
%    to enable/disable (rather than show/hide) the desktop.
%
% Examples:
%    curState = setDesktopVisibility;
%    oldState = setDesktopVisibility('off');     % hide desktop window
%    oldState = setDesktopVisibility(result>0);
%    oldState = setDesktopVisibility(true);      % restore visibility
%
% Bugs and suggestions:
%    Please send to Yair Altman (altmany at gmail dot com)
%
% Warning:
%    This code relies on undocumented and unsupported Matlab
%    functionality. It works on Matlab 6+, but use at your own risk!
%
% Change log:
%    2007-09-12: First version posted on <a href="http://www.mathworks.com/matlabcentral/fileexchange/loadAuthor.do?objectType=author&mfx=1&objectId=1096533#">MathWorks File Exchange</a>
%
% See also:
%    gcf, findjobj (last two on the File Exchange)
% Programmed by Yair M. Altman: altmany(at)gmail.com
% $Revision: 1.0 $  $Date: 2007/09/12 02:12:41 $

  try
      % Check args
      error(nargchk(0,1,nargin));
      % Require Java engine to run
      if ~usejava('jvm')
          error([mfilename ' requires Java to run.']);
      end
      % Get the desktop Java frame
      dtf = getDTFrame;
      % Get the current frame's state
      currentState = get(dtf,'Showing');
      % Set the new desktop visibility state, if requested
      if exist('newState','var')
          % Parse 'on'/'off' string input (case-insensitive)
          if ischar(newState)
              newState = lower(newState);
              if ~any(strcmp(newState,{'on','off'}))
                  error('newState must be one of: ''on'', ''off'', true, false')
              end
              newState = strcmp(newState,'on');
          end
          % Display or hide the desktop window, as requested
          % Note: use dtf.setEnable(...) or set(dtf,'enable',...) to enable/disable, rather than show/hide
          if newState
              dtf.show;
          else
              dtf.hide;
          end
      end
  % Error handling
  catch
      v = version;
      if v(1)<='6'
          err.message = lasterr;  % no lasterror function...
      else
          err = lasterror;
      end
      try
          err.message = regexprep(err.message,'Error using ==> [^\n]+\n','');
      catch
          try
              % Another approach, used in Matlab 6 (where regexprep is unavailable)
              startIdx = findstr(err.message,'Error using ==> ');
              stopIdx = findstr(err.message,char(10));
              for idx = length(startIdx) : -1 : 1
                  idx2 = min(find(stopIdx > startIdx(idx)));  %#ok ML6
                  err.message(startIdx(idx):stopIdx(idx2)) = [];
              end
          catch
              % never mind...
          end
      end
      if isempty(findstr(mfilename,err.message))
          % Indicate error origin, if not already stated within the error message
          err.message = [mfilename ': ' err.message];
      end
      if v(1)<='6'
          while err.message(end)==char(10)
              err.message(end) = [];  % strip excessive Matlab 6 newlines
          end
          error(err.message);
      else
          rethrow(err);
      end
  end
%% Get the desktop Java frame
function dtframe = getDTFrame
  try
      % Matlab 7
      dtframe = com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame;
  catch
      % Matlab 6
      dtframe = com.mathworks.ide.desktop.MLDesktop.getMLDesktop.getMainFrame;
  end
  % Sanity check
  if isempty(dtframe)
      % should never happen...
      error('Cannot retrieve desktop''s java frame');
  end
