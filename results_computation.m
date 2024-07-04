% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>



POOL = 0; %If POOL > 0, use POOL as the number of parallel workers.
nb_runs = 100; %Number of runs of the different algorithms.

%Problem structure and configuration.
struct = @branin_mod_struct;
config = @branin_mod_config;

if POOL > 0

    delete(gcp('nocreate'))
    [clust, clustClean] = get_cluster(); %create temporary files to avoid bug when using several pools.
    parpool(clust, POOL)
    pctRunOnAll run startup.m
    pctRunOnAll warning ('off','all');

    disp('Computing QSI-SUR results')
    parfor it=1:nb_runs
        extract_deviation(struct, config, "QSI_m", it, '../../../data')
    end

    disp('Computing Joint-SUR results')
    parfor it=1:nb_runs
        extract_deviation(struct, config, "joint_m", it, '../../../data')
    end

    disp('Computing maximum misclassification results')
    parfor it=1:nb_runs
        extract_deviation(struct, config, "misclassification", it, '../../../data')
    end

    disp('Computing Ranjan results')
    parfor it=1:nb_runs
        extract_deviation(struct, config, "Ranjan", it, '../../../data')
    end

    disp('Computing random sampling results')
    parfor it=1:nb_runs
        extract_deviation(struct, config, "random", it, '../../../data')
    end
    
    disp('Computing ECL results')
    parfor it=1:nb_runs
        extract_deviation_ECL(struct, config, it, '../../../data')
    end


else

    disp('Computing QSI-SUR results')
    for it=1:nb_runs
        extract_deviation(struct, config, "QSI_m", it, '../../../data')
    end

    disp('Computing Joint-SUR results')
    for it=1:nb_runs
        extract_deviation(struct, config, "joint_m", it, '../../../data')
    end

    disp('Computing maximum misclassification results')
    for it=1:nb_runs
        extract_deviation(struct, config, "misclassification", it, '../../../data')
    end

    disp('Computing Ranjan results')
    for it=1:nb_runs
        extract_deviation(struct, config, "Ranjan", it, '../../../data')
    end

    disp('Computing random sampling results')
    for it=1:nb_runs
        extract_deviation(struct, config, "random", it, '../../../data')
    end

    disp('Computing ECL results')
    for it=1:nb_runs
        extract_deviation_ECL(struct, config, it, '../../../data')
    end

end

