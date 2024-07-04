% Create figures comparing sampling criterion surface of QSI-SUR
% and maximum misclassification probability for the initial design it, on
% the test function f_1.

% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr>
%             Julien Bect <julien.bect@centralesupelec.fr>

set_pts = 50;  % Square root of the number of candidates
nb_steps = 2;  % Number of steps to visualize
it = 99;       % Id of the initial DoEs to use

here = fileparts (mfilename ('fullpath'));
data_dir = fullfile (here, '..', '..', 'data');

[prm, f, s_trnsf] = branin_mod_struct(); %loading function and parameters
config = branin_mod_config ();

dim_tot = prm.dim_x+prm.dim_s;

%If size output = 1, initizalize Gaussian quadrature
if prm.M == 1
    quantOpt.nbLevels = config.nVar;
    quantOpt.useGaussHermite = 1;
end

% Initial design
file_grid = sprintf ('doe_init_%s_%d_init.csv', prm.name, it);
di = readmatrix(fullfile(data_dir, 'doe_init', file_grid));
zi = f(di);

% Create dataframes
dn = stk_dataframe(di);
zn = stk_dataframe(zi);

% Estimate and save parameters
Model = stk_model ();
for m = 1:prm.M
    [Model(m), ind_cov] = estim_matern ...
        (dn, zn(:,m), prm.list_cov, config.lognugget);
end

for t = 1:nb_steps %loop on steps
    disp(sprintf("QSI step %d", t)); %#ok<DSPSP>
    tic

    %sampling points in X x S
    xt = stk_sampling_randomlhs(config.pts_x,prm.dim_x,prm.BOXx);
    st = stk_sampling_randomlhs(config.pts_s,prm.dim_s,prm.BOXs);
    st = s_trnsf(st);
    dt = adapt_set(xt,st);

    %evaluate misclassification probability of \tau(x)
    proba_x = proba_tau(Model, dn , zn, xt, st, prm, config);
    misclass_x = min(proba_x, 1-proba_x);

    [~, sort_misclass_x] = sort(misclass_x,'descend');
    ranking_x = [sort_misclass_x(1)]; %keeping most uncertain point

    %importance sampling on X
    if sum((misclass_x > 0))<=config.keep_x
        ranking_x = sort_misclass_x(1:config.keep_x);
    else
        candidate_set = setdiff(find(misclass_x > 0),ranking_x);
    end

    while size(ranking_x, 1) < config.keep_x

        candidate = randsample(candidate_set, 1, true, misclass_x(candidate_set));

        candidate_set = setdiff(candidate_set, candidate); %enforce without replacement constraint
        ranking_x = [ranking_x; candidate];
    end

    % Define IS weights
    IS = zeros (config.keep_x, config.nVar);
    for j = 1:config.nVar
        IS(:, j) = 1 / misclass_x(ranking_x);
    end

    %keeping useful parts of dataframe
    xt = xt(ranking_x,:);
    dt = adapt_set(xt,st);

    pts = set_pts;
    x_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXx));
    s_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXs));
    cand_set = double(adapt_set(x_pcolor, s_pcolor));

    traj = zeros(size(dn,1)+size(dt,1)+1, config.nTraj, prm.M);
    traj_base = zeros(size(dn,1)+size(dt,1)+size(cand_set,1), config.nTraj, prm.M);

    for m = 1:prm.M
        traj_base(:,:,m) = stk_generate_samplepaths(Model(m), [dn;cand_set;dt], config.nTraj);
    end

    crit_tab = inf + zeros(1,size(cand_set,1));

    % Loop on candidate points
    for r = 1:size(cand_set,1)

        i = r;

        pt = double(cand_set(i,:));

        crit = 0;

        ind_design = size(dn,1);

        for m = 1:prm.M
            traj(1:ind_design,:,m) = traj_base(1:ind_design,:,:);
            traj(ind_design+1,:,m) = traj_base(ind_design + i, :, :);
            traj(ind_design+2:ind_design+size(dt,1)+1,:,m) = traj_base(ind_design+size(cand_set,1)+1:size(traj_base,1), : ,:);
        end

        % Draw variables, get kriging matrix
        var = [];

        for m = 1:prm.M
            p = stk_predict(Model(m),dn,zn(:,m),pt);
            if prm.M == 1
                [var, weight] = quantization(p.mean, sqrt(p.var), quantOpt);
            else
                var = [var; p.mean+sqrt(p.var)*randn(config.nVar,1)'];
                weight = 1/prm.nVar*ones(size(var));
            end
        end

        xc = double([dn;pt]);
        xc_ind = size(xc,1)-1;

        bool = cell (config.nVar, prm.M);

        %Generate conditional sample paths
        for m = 1:prm.M
            [~, lambda]  = stk_predict (Model(m), [dn; pt], [], [dn;pt; dt]);
            lambda_dn = lambda(1:size(lambda,1)-1,:); %cond to dn
            lambda_pt = lambda(size(lambda,1),xc_ind+2:size(traj,1)); %cond to pt restricted to dt

            trajCond_dn = stk_conditioning(lambda_dn,zn(:,m),traj(:,:,m),[1:xc_ind]); %Sample paths on dt condt to dn
            trajCond_dn = trajCond_dn(xc_ind+2:size(trajCond_dn,1),:); %Delete on dn

            %%% Prepare inputs for probability computation
            lambda_pt = reshape(lambda_pt,config.keep_x,config.pts_s);
            tensor_dn = reshape(trajCond_dn,config.keep_x, config.pts_s, config.nTraj);

            %traj_dt = traj(xc_ind+2:size(traj,1),:,m); %Delete observations on dn
            traj_ind = reshape(traj(xc_ind+1,:,:),1,1,config.nTraj);

            %Compute criterion for every variables
            for k=1:config.nVar
                bool{k,m} = check_constraints_trajs(tensor_dn,traj_ind,var(k),lambda_pt,prm.const(:,m));
            end

        end

        proba = proba_tau_trajs(bool, prm.alpha);

        switch config.critName
            case "m"
                s = min (proba, 1 - proba);
            case "v"
                s = proba .* (1 - proba);
            case "e"
                qroba = 1 - proba;
                s = tools.nan2zero (-proba .* log2(proba)) ...
                    + tools.nan2zero (-qroba .* log2(qroba));
            otherwise
                error("Invalid criterion name")
        end

        crit_tab(r) = sum (weight .* (mean (IS .* s, 1)));

    end
    [~, ind_newpt] = min(crit_tab);
    newpt = cand_set(ind_newpt,:);

    xt = sort(stk_sampling_randomlhs(config.pts_x,prm.dim_x,prm.BOXx));
    st = sort(stk_sampling_randomlhs(config.pts_s,prm.dim_s,prm.BOXs));
    dt = adapt_set(xt,st);
    boundary = reshape((f(dt) <= prm.const(2,1)), size(xt,1), size(st, 1))';
    pred = stk_predict(Model, dn, zn, dt);
    boundary_pred = reshape((pred.mean <= prm.const(2,1)), size(xt,1), size(st, 1))';

    xf = stk_sampling_regulargrid(1000, 1, prm.BOXx);
    xf = sort(xf);
    sf = stk_sampling_regulargrid(1000 ,prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    sf = sort(sf);
    df = double(adapt_set(xf,sf));
    zf = f(df);

    set = get_true_quantile_set(zf, 1000, 1000, prm.alpha, prm.const);
    set_selector = nan(1,size(xf,1));
    set_selector(set == 1) = 0;

    set_pred = get_expected_quantile_set(Model, df, 1000, 1000 ,dn,zn, prm.const, prm.alpha);
    set_pred_selector = nan(1, size(xf, 1));
    set_pred_selector(set_pred == 1) = 0+1/4;

    pts = set_pts;
    x_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXx));
    s_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXs));

    figure()
    crit_tab = reshape(crit_tab, pts, pts)';
    pcolor(x_pcolor, s_pcolor', crit_tab);
    hold on
    contour(double(xt), double(st)', boundary, ...
        [1], 'LineWidth', 3, 'LineColor', 'black')
    hold on
    contour(double(xt), double(st)', boundary_pred, ...
        [1], 'LineWidth', 3, 'LineColor', 'red')
    hold on
    scatter(dn(21:20+t-1, 1), dn(21:20+t-1,2), 70, 'filled', 'MarkerFaceColor', "red", "MarkerEdgeColor", "green")
    line(double(xf), set_selector, 'LineWidth', 4, 'Color', 'black')
    hold on
    line(double(xf), set_pred_selector, 'LineWidth', 4, 'Color', 'red')
    caxis([min(crit_tab, [], "all") max(crit_tab, [], "all")])
    colormap(flipud(parula))
    colorbar()
    xlim([0 10])
    ylim([0 15])
    title(sprintf('Qsi %d', t))
    xlabel("X")
    ylabel("S")

    dn = stk_dataframe([dn;newpt]);
    zn = stk_dataframe([zn;f(newpt)]);

    for m = 1:prm.M
        [Model(m), ind_cov] = estim_matern ...
            (dn, zn(:,m), prm.list_cov, config.lognugget);
    end

end

Model = stk_model ();
for m = 1:prm.M
    [Model(m), ind_cov] = estim_matern ...
        (dn, zn(:,m), prm.list_cov, config.lognugget);
end

for t = 1:nb_steps %loop on steps

    disp(sprintf("Misclass. step %d", t))

    proba = proba_xi(Model, dn, zn, cand_set, prm);
    crit_tab = min(proba,1-proba);

    [~, ind_newpt] = max(crit_tab);
    newpt = cand_set(ind_newpt,:);

    xt = sort(stk_sampling_randomlhs(config.pts_x,prm.dim_x,prm.BOXx));
    st = sort(stk_sampling_randomlhs(config.pts_s,prm.dim_s,prm.BOXs));
    %st = s_trnsf(st);
    dt = adapt_set(xt,st);
    boundary = reshape((f(dt) <= prm.const(2,1)), size(xt,1), size(st, 1))';
    pred = stk_predict(Model, dn, zn, dt);
    boundary_pred = reshape((pred.mean <= prm.const(2,1)), size(xt,1), size(st, 1))';

    xf = stk_sampling_regulargrid(1000, 1, prm.BOXx);
    xf = sort(xf);
    sf = stk_sampling_regulargrid(1000 ,prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    sf = sort(sf);
    df = double(adapt_set(xf,sf));
    zf = f(df);

    set = get_true_quantile_set(zf, 1000, 1000, prm.alpha, prm.const);
    set_selector = nan(1,size(xf,1));
    set_selector(set == 1) = 0;

    set_pred = get_expected_quantile_set(Model, df, 1000, 1000 ,dn,zn, prm.const, prm.alpha);
    set_pred_selector = nan(1, size(xf, 1));
    set_pred_selector(set_pred == 1) = 0+1/4;

    pts = set_pts;
    x_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXx));
    s_pcolor = double (stk_sampling_regulargrid(pts, 1, prm.BOXs));

    figure()
    crit_tab = reshape(crit_tab, pts, pts)';
    pcolor(x_pcolor, s_pcolor', crit_tab);
    hold on
    contour(double(xt), double(st)', boundary, ...
        [1], 'LineWidth', 3, 'LineColor', 'black')
    hold on
    contour(double(xt), double(st)', boundary_pred, ...
        [1], 'LineWidth', 3, 'LineColor', 'red')
    hold on
    scatter(dn(21:20+t-1, 1), dn(21:20+t-1,2), 70, "filled", 'MarkerFaceColor', "red", "MarkerEdgeColor", "green")
    line(double(xf), set_selector, 'LineWidth', 4, 'Color', 'black')
    hold on
    line(double(xf), set_pred_selector, 'LineWidth', 4, 'Color', 'red')
    caxis([min(crit_tab, [], "all") max(crit_tab, [], "all")])
    colorbar()
    xlim([0 10])
    ylim([0 15])
    title(sprintf('misclass %d', t))
    xlabel("X")
    ylabel("S")

    dn = stk_dataframe([dn;newpt]);
    zn = stk_dataframe([zn;f(newpt)]);

    for m = 1:prm.M
        [Model(m), ind_cov] = estim_matern ...
            (dn, zn(:,m), prm.list_cov, config.lognugget);
    end

end
