% Allows to create sequential graphs representing the obtained DoEs for the
% different algorithms on the branin_mod function.


FROM_DATA = 1; %If FROM_DATA == 0, compute the sequential designs.

it = 60; %id of the run to display
AX = [30]; %steps to show

PTS_DIM = 250;%number of points 

%Names of the files to retrieve.
name_list = ["QSI_m", "joint_m", "misclassification", "Ranjan"];
%Titles of the graphs.
name_graphs = ["QSI-SUR", "Joint-SUR", "misclassification", "Ranjan"];

[prm, f, s_trnsf] = branin_mod_struct();
conf = @branin_mod_config;

if FROM_DATA == 0
    struct = @branin_mod_struct;
    if LIGHT_MODE == 1
        conf = @branin_mod_config_light;
    end
    for it = it_list
            QSI_SUR(struct, conf, it, 0, '../../../data')
            joint_SUR(struct, conf, it, '../../../data')
            misclassification(struct, conf, it, '../../../data')
            Ranjan(struct, conf, it, '../../../data')
    end
end

config = conf();


wid = int64(450);
hei = int64(0.76*wid);

for m = 1:size(name_list,2)

    name = name_list(m);

    xf = stk_sampling_regulargrid(PTS_DIM, prm.dim_x, prm.BOXx);
    sf = stk_sampling_regulargrid(PTS_DIM, prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    df = adapt_set(xf,sf);
    zf = f(df);

    trueSet = get_true_quantile_set(zf, PTS_DIM, PTS_DIM, prm.alpha, prm.const);

        for T = AX

            warning('off','all')

            filename = "data/results/design/doe_"+name+"_"+prm.name+"_"+int2str(it)+".csv";
            filename_para = "data/results/param/param_"+name+"_1_"+prm.name+"_"+int2str(it)+".csv";
            filename_cov = "data/results/param/cov_"+name+"_1_"+prm.name+"_"+int2str(it)+".csv";
            file = readmatrix(filename);
            file_para = readmatrix(filename_para);
            file_cov = readmatrix(filename_cov);

            cov = convertStringsToChars(prm.list_cov(file_cov(T+1,:)));

            Model = stk_model(cov,2);
            Model.param = file_para(T+1, :);
            set = get_expected_quantile_set(Model,df,PTS_DIM, PTS_DIM,file(1:config.pts_init+T,:),f(file(1:config.pts_init+T,:)),prm.const,prm.alpha);

            figure('Position', [10 10 wid hei], 'visible', 'on', 'Renderer','painters')
            p = pcolor(double(xf), double(sf)', reshape(f(df), PTS_DIM, PTS_DIM)');
            p.EdgeColor = 'none';

            hold on
            contour(double(xf), double(sf)' ,reshape((f(df)<=prm.const(2,1)), PTS_DIM, PTS_DIM)',[1],'black','LineWidth',1);
            hold on
            contour(double(xf), double(sf)' ,reshape(((stk_predict(Model,file(1:config.pts_init+T,:),f(file(1:config.pts_init+T,:)),df).mean)<=prm.const(2,1)), PTS_DIM, PTS_DIM)',[1],'red','LineWidth',1);
            hold on
            scatter(file(1:20,1),file(1:20,2),15,'black','filled')
            hold on
            scatter(file(config.pts_init+1:config.pts_init+T,1),file(config.pts_init+1:config.pts_init+T,2),15,'red','filled')
            hold on
            colorbar
            xlabel("\bfX")
            ylabel("\bfS")
            hold on
            title(sprintf("%s - n = %d (run %d)", name_graphs(m), T, it))

        end

    end
