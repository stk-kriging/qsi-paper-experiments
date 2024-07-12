clear all;  close all

[prm, f, s_trnsf] = branin_mod_struct();

PTS_X = 500;
PTS_S = 500;

dim_tot = prm.dim_x+prm.dim_s;
if dim_tot > 1
    xf = stk_sampling_regulargrid(PTS_X, 1, prm.BOXx);
    sf = stk_sampling_regulargrid(PTS_S,prm.dim_s, prm.BOXs);
    sf = s_trnsf(sf);
    df = double(adapt_set(xf,sf));
end
zf = f(df);
figure (1);


h1 = subplot (4, 7, [1 8 15]);

hold on
A = 0:0.01:15;
[~, pdf] = branin_mod_s_trnsf(A);
area(A, pdf, 'FaceAlpha',0.2);
ylabel("density")
xticks([])
camroll(90);
hold on;
%%
sf = stk_sampling_sobol(PTS_S,prm.dim_s, prm.BOXs);
sf = s_trnsf(sf);
sf = sort(sf);
df = double(adapt_set(xf,sf));
zf = f(df);
h3 = subplot (4, 7, [5 6 7 12 13 14 19 20 21]);

[set, proba] = get_true_quantile_set(zf, PTS_X, PTS_S, prm.alpha, prm.const);
stairs(double(xf),set,'LineWidth',4, 'color', 'green', 'DisplayName','$\mathrm{1}_{\Gamma(f)}(x)$');
hold on
plot(double(xf),proba,'LineWidth',4, 'color', 'black', 'DisplayName','$\mathrm{P}(f(x,S) \in C)$');
hold on
plot(double(xf),prm.alpha+zeros(1,PTS_X),'LineWidth',3, 'color','blue','DisplayName','$\alpha$');
xlabel("X")
legend('Location','northwest', 'Interpreter', 'latex');
hold on
%%
h2 = subplot (4, 7, [2 3 4 9 10 11 16 17 18]);
sf = stk_sampling_regulargrid(PTS_S,prm.dim_s, prm.BOXs);
df = adapt_set(xf, sf);
zf = f(df);

hold on
contour(double(xf), double(sf)', reshape((zf<=prm.const(2,1)), PTS_X, PTS_S)',[1],'black','LineWidth',2,'DisplayName','boundary');

hold on
colorbar
xlabel("X")
ylabel("S")
hleg2 = legend('Location',"southwest",'AutoUpdate','off');
p = pcolor(double(xf), double(sf)', reshape(f(df), PTS_X, PTS_S)');
p.EdgeColor = 'none';
hold on
contour(double(xf), double(sf)', reshape((zf<=prm.const(2,1)), PTS_X, PTS_S)',[1],'black','LineWidth',4);
hold on

sf = stk_sampling_sobol(PTS_S,prm.dim_s, prm.BOXs);
sf = s_trnsf(sf);
sf = sort(sf);
df = double(adapt_set(xf,sf));
[set, proba] = get_true_quantile_set(f(df), PTS_X, PTS_S, prm.alpha, prm.const);
set_selector = (set == 1);
abs_quantile = nan(1, size(xf, 1));
abs_quantile(set_selector) = 0;
plot(xf, abs_quantile, 'Color', 'green', 'LineWidth', 4);
