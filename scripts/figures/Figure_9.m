%%% More figures can be generated using the script Figures_convergence.m
%%% (using saved datas).

nb_runs = 100;  % Number of runs of the different algorithms.
nb_cores = maxNumCompThreads-1; %Number of computing core to use.

% Problem structure and configuration.
test_case = '"volcano"';
funct_struct = @volcano_struct;
funct_config = @volcano_config;

here = fileparts (mfilename ('fullpath'));
data_dir = fullfile (here, '..', '..', 'data');

delete (gcp ('nocreate'));
[clust, clustClean] = get_cluster (); %create temporary files to avoid bug when using several pools.
parpool (clust, nb_cores);
pctRunOnAll run startup.m
pctRunOnAll warning ('off','all');


%%%%% MATLAB EXPERIMENTS


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

delete (gcp ('nocreate'));


%%% ECL (python) experiments


disp("Starting ECL experiments")

env_ECL = fullfile(here, '../../env_ECL/bin/activate');
env_cmd = sprintf('source %s', env_ECL); %activate virtual env

algo_dir = fullfile(here,'../../algorithms/gramacylab-nasa');
python_import = sprintf('import os; import sys;');
python_path = sprintf('sys.path.append("%s");', algo_dir);
python_import2 = sprintf('from ecl_experiments_launcher import ecl_experiments_launcher;');
python_launch = sprintf('ecl_experiments_launcher(%s, %d);', test_case, nb_runs);

[status, output] = system (sprintf("%s; python3 -c '%s %s %s %s'", env_cmd, python_import, ...
    python_path, python_import2, python_launch), '-echo'); %launching


%%% EXTRACTING MISCLASS. PROPORTION (matlab and python).

delete(gcp('nocreate'))
[clust, clustClean] = get_cluster(); %create temporary files to avoid bug when using several pools.
parpool (clust, nb_cores);
pctRunOnAll run startup.m
pctRunOnAll warning ('off','all');

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
    zf = double(f(df));
    writematrix(zf, file);
else
    test_zf = readmatrix(file);
    if size(test_zf,1) ~= PTS_X*PTS_S
        zf = f(df);
        writematrix (zf, file);
    end
end

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
for it=1:nb_runs
    extract_deviation_ECL(funct_struct, funct_config, it, data_dir)
end


delete(gcp('nocreate'))

%%% GENERATING GRAPHS

prm = funct_struct ();
config = funct_config ();

disp (sprintf ("Plotting convergence graphs for %s", prm.name)) %#ok<DSPSP>

% Methods to query and plotting options (color, names...).
methods = ["random", "Ranjan", "misclassification", "ecl", "joint_m", "QSI_m"];
name = ["random", "Ranjan", "misclassification", "ECL", "Joint-SUR", "QSI-SUR"];
type = [":", "-", "-", "-", "-", "-"];
col = ["black", "#EDB120", "#7E2F8E", "#77AC30", "#0072BD", "#A2142F"];

wid = int64(450);
hei = int64(0.76*wid);

AX = 0:config.axT:config.T;
AXfile = 1:1:config.T/config.axT+1;

%Extract data

med_dev = [];
med_dev_75 = [];
med_dev_95 = [];

for j = 1:size(methods,2)

    algo = methods(j);

    dev = [];
    false_neg = [];
    false_pos = [];

    for it = 1:nb_runs

        filename = sprintf("dev_%s_%s_%d.csv", algo, prm.name, it);
        file = readmatrix(fullfile(data_dir, 'results/deviations', filename));
        file = file(:,AXfile);

        dev = [dev; file];

    end
    dev_0 = min(dev,[],1);
    dev_010 = quantile(dev,0.05,1);
    dev_025 = quantile(dev,0.25,1);
    dev_05 = quantile(dev,0.5,1);
    dev_075 = quantile(dev,0.75,1);
    dev_090 = quantile(dev,0.95,1);
    dev_1 = max(dev,[],1);

    med_dev = [med_dev; dev_05];
    med_dev_75 = [med_dev_75; dev_075];
    med_dev_95 = [med_dev_95; dev_090];

end

%Compare median
figure('Position', [10 10 wid hei], 'Renderer','painters')
for m = 1:size(methods,2)
    plot(AX,med_dev(m,:),type(m),'DisplayName',name(m),'LineWidth', 3, 'Color', col(m))
    hold on
end

ylim([0 1.1*max(med_dev,[],"all")]);
grid on
legend('Interpreter','none', 'Location','best','FontSize',7)
hold on
xlabel("steps")
ylabel("prop. misclass")
title(sprintf("Medians (volcano)"))

%Compare 095
figure('Position', [10 10 wid hei], 'Renderer','painters')
for m = 1:size(methods,2)
    plot(AX,med_dev_95(m,:),type(m),'DisplayName', name(m), 'LineWidth', 3, 'color', col(m))
    hold on
end
ylim([0 1.1*max(med_dev_95,[],"all")]);
grid on
legend('Interpreter','none', 'Location','best','FontSize',7)
hold on
xlabel("steps")
ylabel("prop. misclass")
title(sprintf("Quantiles 95th (volcano)"))

drawnow