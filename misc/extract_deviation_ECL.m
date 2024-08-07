%Extract proportion of misclassief points for ECL (Cole et al. 2023)
%strategy


function extract_deviation_ECL(funct_struct, config, it, data_dir)

disp("Run number "+int2str(it))

if nargin < 4
    here = fileparts (mfilename ('fullpath'));
    data_dir = fullfile (here, '..', 'data');
end


[prm, f, s_trnsf] = funct_struct();
config = config();

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
    else
        df = test_df;
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
    else
        zf = test_zf;
    end
end
zf = double(zf);

trueSet = get_true_quantile_set(zf, PTS_X, PTS_S, prm.alpha, prm.const);


    file_design = sprintf('doe_ecl_%s_%d.csv', prm.name, it);
    design = readmatrix(fullfile(data_dir, 'results/design', file_design));

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
    writematrix(dev,fullfile(data_dir, 'results/deviations', filename_dev));

end

