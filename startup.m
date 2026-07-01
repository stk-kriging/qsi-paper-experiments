function startup ()

% Locate project root
root = fileparts (mfilename ('fullpath'));

% Add directories to the path
addpath (fullfile (root, 'testcases', 'volcano-case'));
addpath (fullfile (root, 'testcases', 'matlab'));
addpath (fullfile (root, 'misc'));
addpath (genpath (fullfile (root, 'scripts')));

% Download contrib-qsi (if needed)
contrib_qsi = fullfile (root, 'algorithms', 'stk-contrib-qsi');
if ~ exist (contrib_qsi, 'dir')
    % commit 4718660
    % Date: Wed Jul 1 15:01:50 2026 +0200
    git_clone_dependency ('contrib-qsi', contrib_qsi, ...
        'https://github.com/stk-kriging/contrib-qsi.git', '4718660');
end

% Add contrib-qsi to the path
% (this step also clones & initializes STK 2.8.1 if needed)
run (fullfile (contrib_qsi, 'startup.m'));

end % function


function git_clone_dependency (name, dst, url, sha1_or_tag)

if exist (dst, 'dir')
    error (sprintf ('Directory already exists: %s\n', dst)); %#ok<SPERR>
end

fprintf ('Cloning %s... ', name);

here = pwd ();

try

    gitcmd = create_git_call (sprintf ('clone %s %s', url, dst));
    evalc (sprintf ('[status, output] = system (''%s'')', gitcmd));
    if status ~= 0
        error ([ ...
            'git-clone failed with the following ' ...
            'error message:\n\n%s\n\n'], output);
    end

    cd (dst);

    gitcmd = create_git_call (sprintf ('checkout %s', sha1_or_tag));
    evalc (sprintf ('[status, output] = system (''%s'')', gitcmd));
    if status ~= 0
        error ([ ...
            'git-checkout failed with the following ' ...
            'error message:\n\n%s\n\n'], output);
    end

    cd (here);

catch e

    cd (here);

    % Remove partial/failed install
    if exist (dst, 'dir')
        rmdir (dst, 's');
    end

    rethrow (e);

end % try-catch

fprintf ('OK\n');

end % function


function gitcmd = create_git_call (cmd)

if isunix ()
    prefix = 'env -u LD_LIBRARY_PATH ';
else
    prefix = '';
end

gitcmd = sprintf ('%s git %s', prefix, cmd);

end % function

