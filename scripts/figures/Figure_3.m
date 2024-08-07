% Create figures comparing sampling criterion surface of QSI-SUR
% and maximum misclassification probability for a random initial design, on
% the test function f_1.


[prm, f, s_trnsf] = branin_mod_struct(); %loading function and parameters
config = branin_mod_config();

dim_tot = prm.dim_x+prm.dim_s;

%If size output = 1, initizalize Gaussian quadrature
if prm.M == 1
    quantOpt.nbLevels = config.nVar;
    quantOpt.useGaussHermite = 1;
end

%Initial design
di = stk_sampling_maximinlhs(20, 2, prm.BOX);
zi = f(di);

% Create dataframes
dn = stk_dataframe(di);
zn = stk_dataframe(zi);

%stocking parameters
save_param = zeros(config.T+1,dim_tot+1,prm.M);
save_cov = zeros(config.T+1, 1, prm.M);

time = [];

% Estimate and save parameters
Model = stk_model ();
for m = 1:prm.M
    [Model(m), ind_cov] = estim_matern ...
        (dn, zn(:,m), prm.list_cov, config.lognugget);
    save_cov(1,:,m) = ind_cov;
    save_param(1,:,m) = Model(m).param;
end

for t = 1:1 %loop on steps
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

    %evaluate misclassification probability of \xi(x,s)
    proba_xs = proba_xi(Model, dn, zn, dt, prm);

    misclass_xs = min(proba_xs,1-proba_xs)';

    [~, sort_misclass_xs] = sort(misclass_xs,'descend');
    ranking_xs = [sort_misclass_xs(1)];

    if sum((misclass_xs > 0))<=config.keep_xs
        ranking_xs = sort_misclass_xs(1:config.keep_xs);
    else

        candidate_set = setdiff(find(misclass_xs > 0), ranking_xs);

        while size(ranking_xs, 1) < config.keep_xs

            candidate = randsample(candidate_set, 1, true, misclass_xs(candidate_set));

            ranking_xs = [ranking_xs; candidate];
            candidate_set = setdiff(candidate_set, candidate);
        end

    end

    traj = zeros(size(dn,1)+size(dt,1), config.nTraj, prm.M);

    for m = 1:prm.M
        traj(:,:,m) = stk_generate_samplepaths(Model(m), [dn;dt], config.nTraj);
    end
    crit_tab = inf + zeros(1,config.keep_xs);

    %loop on candidate points
    for r = 1:config.keep_xs

        i = ranking_xs(r);

        pt = double(dt(i,:));
        crit = 0;


        %Draw variables, get kriging matrix
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
            [~, lambda]  = stk_predict (Model(m), [dn; pt], [], [dn; dt]);
            lambda_dn = lambda(1:size(lambda,1)-1,:); %cond to dn
            lambda_pt = lambda(size(lambda,1),xc_ind+1:size(traj,1)); %cond to pt restricted to dt

            trajCond_dn = stk_conditioning(lambda_dn,zn(:,m),traj(:,:,m),[1:xc_ind]); %Sample paths on dt condt to dn
            trajCond_dn = trajCond_dn(xc_ind+1:size(trajCond_dn,1),:); %Delete on dn

            %%% Prepare inputs for probability computation
            lambda_pt = reshape(lambda_pt,config.keep_x,config.pts_s);
            tensor_dn = reshape(trajCond_dn,config.keep_x, config.pts_s, config.nTraj);

            traj_dt = traj(xc_ind+1:size(traj,1),:,m); %Delete observations on dn
            traj_ind = reshape(traj_dt(i,:),1,1,config.nTraj);

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
end

x_plot = sort(stk_sampling_randomlhs(1000,prm.dim_x,prm.BOXx));
s_plot = sort(stk_sampling_randomlhs(1000,prm.dim_s,prm.BOXs));
s_plot = s_trnsf(s_plot);
d_plot = adapt_set(x_plot, s_plot);
boundary = reshape((f(d_plot) <= prm.const(2,1)), size(x_plot,1), size(s_plot, 1))';
pred = stk_predict(Model, dn, zn, d_plot);
boundary_pred = reshape((pred.mean <= prm.const(2,1)), size(x_plot,1), size(s_plot, 1))';

z_plot = f(d_plot);

set = get_true_quantile_set(z_plot, size(x_plot,1), size(s_plot,1), prm.alpha, prm.const);
set_selector = nan(1,size(x_plot,1));
set_selector(set == 1) = 0;

set_pred = get_expected_quantile_set(Model, d_plot, size(x_plot,1), size(s_plot,1) ,dn,zn, prm.const, prm.alpha);
set_pred_selector = nan(1, size(x_plot, 1));
set_pred_selector(set_pred == 1) = 0+1/4;



figure()
contour(double(x_plot), double(s_plot)', boundary, ...
    [1], 'LineWidth', 3, 'LineColor', 'black')
hold on
contour(double(x_plot), double(s_plot)', boundary_pred, ...
    [1], 'LineWidth', 3, 'LineColor', 'red')
hold on
scatter(dn(:,1), dn(:,2), 30, 'o', 'filled', 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black')
hold on
scatter(dt(:,1), dt(:,2), 30, 'o', 'MarkerEdgeColor', 'blue', 'MarkerEdgeAlpha', 0.1)
hold on
line(double(x_plot), set_selector, 'LineWidth', 4, 'Color', 'green')
hold on
line(double(x_plot), set_pred_selector, 'LineWidth', 4, 'Color', 'red')
xlim([0 10])
ylim([0 15])
grid on

figure()
contour(double(x_plot), double(s_plot)', boundary, ...
    [1], 'LineWidth', 3, 'LineColor', 'black')
hold on
contour(double(x_plot), double(s_plot)', boundary_pred, ...
    [1], 'LineWidth', 3, 'LineColor', 'red')
hold on
scatter(dn(:,1), dn(:,2), 30, 'o', 'filled', 'MarkerFaceColor', 'black')
hold on
scatter(dt(ranking_xs,1), dt(ranking_xs,2), 30, crit_tab, 'o', 'filled', 'MarkerFaceAlpha', 0.6)
hold on
line(double(x_plot), set_selector, 'LineWidth', 4, 'Color', 'green')
hold on
line(double(x_plot), set_pred_selector, 'LineWidth', 4, 'Color', 'red')
caxis([min(crit_tab, [], "all") max(crit_tab, [], "all")])
colormap(flipud(parula))
colorbar()
grid on
xlim([0 10])
ylim([0 15])
