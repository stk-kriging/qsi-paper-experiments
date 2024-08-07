% Construct convergence graphs for the different competitors.


here = fileparts (mfilename ('fullpath'));
data_dir = fullfile (here, '..', '..', 'data');

SAVE = 0;       % SAVE = 1 to save figures in data/results/figures.
nb_runs = 100;  % Number of runs to query.

% Problem structure and configuration.
prm = branin_mod_struct ();
config = branin_mod_config ();

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

%%Plot all sample paths.
max_plot = 0;
med_dev = [];
med_dev_75 = [];
med_dev_95 = [];

max_plot = 0;

for j = 1:size(methods,2)
    dev = [];
    algo = methods(j);

    for it = 1:nb_runs

        filename = sprintf("dev_%s_%s_%d.csv", algo, prm.name, it);
        file = readmatrix(fullfile(data_dir, 'results/deviations', filename));
        file = file(:,AXfile);

        dev = [dev; file];
        max_plot = max([max_plot, max(dev,[],"all")],[], "all");
    end
end

for j = 1:size(methods,2)
    dev = [];
    algo = methods(j);

    for it = 1:nb_runs

        filename = sprintf("dev_%s_%s_%d.csv", algo, prm.name, it);
        file = readmatrix(fullfile(data_dir, 'results/deviations', filename));
        file = file(:,AXfile);

        dev = [dev; file];
    end

    figure('Position', [10 10 wid hei], 'Renderer','painters')
    for it = 1:nb_runs
        plot(AX, dev(it,:))
        hold on
    end
    ylim([0 max_plot])
    grid on
    xlabel("steps")
    ylabel("prop. misclass")
    hold on
    title(name(j) + " (sample paths)","Interpreter","none")
    if SAVE == 1
        saveas(gcf, data_dir+"/results/graphs/trajs_"+prm.name+"_"+algo, 'epsc')
        saveas(gcf, data_dir+"/results/graphs/trajs_"+prm.name+"_"+algo)
    end

end

%Plot strategy individually
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


    figure('Position', [10 10 wid hei], 'Renderer','painters')

    patch([AX, fliplr(AX)],[dev_010, fliplr(dev_090)], ...
        'black','FaceAlpha',0.3, 'EdgeColor','none','DisplayName','5%-95%');
    hold on
    patch([AX, fliplr(AX)],[dev_025, fliplr(dev_075)], ...
        'black','FaceAlpha',0.4, 'EdgeColor','none','DisplayName',"25%-75%");
    hold on
    plot(AX,dev_05, 'LineWidth',3,'Color','red','DisplayName',"median")
    hold on
    grid on
    ylim([0 max_plot])
    legend('Interpreter','none','FontSize',7)
    xlabel("steps")
    ylabel("prop. misclass")
    hold on
    title(name(j),"Interpreter","none")
    if SAVE == 1
        saveas(gcf,data_dir+"/results/graphs/metric_"+prm.name+"_"+algo, 'epsc')
        saveas(gcf,data_dir+"/results/graphs/metric_"+prm.name+"_"+algo)
    end


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
title("Medians")
if SAVE == 1
    saveas(gcf,data_dir+"/results/graphs/metric_"+prm.name, 'epsc')
    saveas(gcf,data_dir+"/results/graphs/metric_"+prm.name)
end

%Compare 075
figure('Position', [10 10 wid hei], 'Renderer','painters')
for m = 1:size(methods,2)
    plot(AX,med_dev_75(m,:), type(m),'DisplayName',name(m),'LineWidth',3, 'color', col(m))
    hold on
end
ylim([0 1.1*max(med_dev_75,[],"all")]);
grid on
legend('Interpreter','none', 'Location','best','FontSize',7)
hold on
xlabel("steps")
ylabel("prop. misclass")
title("Quantiles (75th)")
if SAVE == 1
    saveas(gcf,data_dir+"/results/graphs/metric_75_"+prm.name, 'epsc')
    saveas(gcf,data_dir+"/results/graphs/metric_75_"+prm.name)
end

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
title("Quantiles (95th)")
if SAVE == 1
    saveas(gcf,data_dir+"/results/graphs/metric_95_"+prm.name, 'epsc')
    saveas(gcf,data_dir+"/results/graphs/metric_95_"+prm.name)
end

