POOL = 0; %If POOL > 0, use POOL as the number of parallel workers.
nb_runs = 100; %Number of runs of the different algorithms.

%Problem structure and configuration.
funct_struct = @branin_mod_struct;
funct_config = @branin_mod_config;

here = fileparts (mfilename ('fullpath'));
data_dir = fullfile (here, '..', '..', 'data');

[prm, f, s_trnsf] = funct_struct();
config = funct_config();

PTS_X = config.pts_eval_x;
PTS_S = config.pts_eval_s;
dim_tot = prm.dim_x+prm.dim_s;

xf = stk_sampling_sobol(PTS_X, prm.dim_x, prm.BOXx);
sf = stk_sampling_sobol(PTS_S, prm.dim_s, prm.BOXs);
sf = s_trnsf(sf);
df = adapt_set (xf, sf);

file = sprintf ('grid_%s.csv', prm.name);
file = fullfile (data_dir, 'grid', file);
if ~ exist (file, "file")
    writematrix (double(df), file);
else
    test_df = readmatrix(file);
    if size(test_df,1) ~= PTS_X*PTS_S
        writematrix (double(df), file);
    end
end


file = sprintf('results_grid_%s.csv', prm.name);
file = fullfile(data_dir, 'grid', file);
if ~exist(file, "file")
    xf = stk_sampling_sobol(PTS_X, prm.dim_x, prm.BOXx);
    sf = stk_sampling_sobol(PTS_S, prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    df = adapt_set(xf,sf);
    zf = f(df);
    writematrix(zf, file);
else
    test_zf = readmatrix(file);
    if size(test_zf,1) ~= PTS_X*PTS_S
        zf = f(df);
        writematrix (zf, file);
    end
end

if POOL > 0

    delete(gcp('nocreate'))
    [clust, clustClean] = get_cluster(); %create temporary files to avoid bug when using several pools.
    parpool(clust, POOL)
    pctRunOnAll run startup.m
    pctRunOnAll warning ('off','all');

    disp('Computing QSI-SUR results')
    parfor it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "QSI_m", it, data_dir)
    end

    disp('Computing Joint-SUR results')
    parfor it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "joint_m", it, data_dir)
    end

    disp('Computing maximum misclassification results')
    parfor it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "misclassification", it, data_dir)
    end

    disp('Computing Ranjan results')
    parfor it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "Ranjan", it, data_dir)
    end

    disp('Computing random sampling results')
    parfor it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "random", it, data_dir)
    end
    
    disp('Computing ECL results')
    parfor it=1:nb_runs
        extract_deviation_ECL(funct_struct, funct_config, it, data_dir)
    end


else

    disp('Computing QSI-SUR results')
    for it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "QSI_m", it, data_dir)
    end

    disp('Computing Joint-SUR results')
    for it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "joint_m", it, data_dir)
    end

    disp('Computing maximum misclassification results')
    for it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "misclassification", it, data_dir)
    end

    disp('Computing Ranjan results')
    for it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "Ranjan", it, data_dir)
    end

    disp('Computing random sampling results')
    for it=1:nb_runs
        extract_deviation(funct_struct, funct_config, "random", it, data_dir)
    end

    disp('Computing ECL results')
    for it=1:nb_runs
        extract_deviation_ECL(funct_struct, funct_config, it, data_dir)
    end

end
