function [prm, f, s_trnsf] = volcano_struct()

f = @volcano;

s_trnsf = @volcano_s_trnsf;

prm = struct();

prm.M = 1;

prm.dim_x = 5;
prm.dim_s = 2;

prm.BOX = stk_hrect(repmat([0;1],1,prm.dim_x+prm.dim_s));
prm.BOXx = stk_hrect(repmat([0;1],1,prm.dim_x));
prm.BOXs = stk_hrect(repmat([0;1],1,prm.dim_s));


prm.const = [0.015 ; inf];
prm.alpha = 0.9;


prm.name = "volcano";
prm.name_sub = ["volcano"];



prm.list_cov = ["stk_expcov_aniso"; "stk_materncov32_aniso"; "stk_materncov52_aniso"; "stk_gausscov_aniso"];


end
