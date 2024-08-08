POOL = 0;  % If POOL > 0, use POOL as the number of parallel workers.
nb_runs = 100;  % Number of runs of the different algorithms.

% Problem structure and configuration.
funct_struct = @branin_mod_struct;
funct_config = @branin_mod_config;

here = fileparts (mfilename ('fullpath'));
data_dir = fullfile (here, '..', '..', 'data');

delete (gcp ('nocreate'));

if POOL > 0

    delete (gcp ('nocreate'));
    [clust, clustClean] = get_cluster (); %create temporary files to avoid bug when using several pools.
    parpool (clust, POOL);
    pctRunOnAll run startup.m
    pctRunOnAll warning ('off','all');

    disp ('Starting QSI-SUR')
    parfor it = 1:nb_runs
        QSI_SUR (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting Joint-SUR')
    parfor it = 1:nb_runs
        joint_SUR (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting maximum misclassification')
    parfor it = 1:nb_runs
        misclassification (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting Ranjan')
    parfor it = 1:nb_runs
        Ranjan (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting random sampling')
    parfor it = 1:nb_runs
        random (funct_struct, funct_config, it, data_dir)
    end

else

    disp ('Starting QSI-SUR')
    for it = 1:nb_runs
        QSI_SUR (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting Joint-SUR')
    for it = 1:nb_runs
        joint_SUR(funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting maximum misclassification')
    for it = 1:nb_runs
        misclassification (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting Ranjan')
    for it = 1:nb_runs
        Ranjan (funct_struct, funct_config, it, data_dir)
    end

    disp ('Starting random sampling')
    for it = 1:nb_runs
        random (funct_struct, funct_config, it, data_dir)
    end

end

delete (gcp ('nocreate'));
