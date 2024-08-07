% Create cluster for parallel computing. Useful in the particular case
% of several instances of Matlab each using parpool.


function [local_cluster, cleanUp] = get_cluster(profile)

    if nargin < 1
        profile = 'local';
    end
    
    iodir_base = fullfile (tempdir (), 'cluster_tmp');
    if ~ exist (iodir_base, 'dir')
        mkdir (iodir_base);
    end
    if ~ exist (iodir_base, 'dir')
        error ('This should never happen...');
    end

    iodir = tempname (iodir_base);
    cleanUp = onCleanup(@()rmdir(iodir, 's')); %delete tempdir at the end.

    if exist (iodir, 'dir')
        error ('This should never happen...');
    end
    mkdir (iodir);
    if ~ exist (iodir, 'dir')
        error ('This should never happen...');
    end


    local_cluster = parcluster(profile);
    
    %solve bug multiple parallel jobs
    local_cluster.JobStorageLocation = iodir;

end
