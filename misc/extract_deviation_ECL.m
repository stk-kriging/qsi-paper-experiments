%Extract proportion of misclassief points for ECL (Cole et al. 2023)
%strategy

% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 


function QSI_SUR(funct_struct, config_func, it, DEMO, filePath)


function extract_deviation_ECL(funct_struct, config, it, filePath)

disp("Run number "+int2str(it))

if nargin < 4
    filePath = '../data';
end

PTS_X = 2^12;
PTS_S = 2^10;

[prm, f, s_trnsf] = funct_struct();
config = config();

here = fileparts(mfilename('fullpath'));

dim_tot = prm.dim_x+prm.dim_s;

file = sprintf('results_grid_%s.csv', prm.name);
file = fullfile(here, '..', 'data/grid', file);
if ~exist(file, "file")
    xf = stk_sampling_sobol(PTS_X, prm.dim_x, prm.BOXx);
    sf = stk_sampling_sobol(PTS_S, prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    df = adapt_set(xf,sf);
    zf = f(df);
    csvwrite(file, zf);
else
    zf = csvread(file);
end
zf = double(zf);

trueSet = get_true_quantile_set(zf, PTS_X, PTS_S, prm.alpha, prm.const);


    file_design = sprintf('doe_ecl_%s_%d.csv', prm.name, it);
    design = readmatrix(fullfile(here, filePath, 'results/design', file_design));

    dev = [];

    for j = 1:config.axT:config.T+1

        dt = design(1:config.pts_init+j-1,:);

        pred = get_ecl_predictions(prm.name, dt);
        mu = pred(:,1);
        std = pred(:,2);

        proba = stk_distrib_normal_cdf(prm.const(2,1),mu, std)-stk_distrib_normal_cdf(prm.const(1,1), mu, std);
        proba = reshape(proba, PTS_X, PTS_S);
        proba = sum(proba,2)/PTS_S;
        approxSet = (proba <= prm.alpha)';
        
        dev = [dev, lebesgue_deviation(trueSet,approxSet)];
        



    end

    filename_dev = sprintf('dev_ecl_%s_%d.csv', prm.name, it);
    writematrix(dev,fullfile(here, filePath, 'results/deviations', filename_dev));

end

