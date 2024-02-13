% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>



run('algorithms/stk-contrib-qsi/stk-2.8.1/stk_init.m');
addpath(genpath("sys"))
addpath(genpath("testcases"))
addpath(genpath("misc"))


for qsi_paths = ["", "methods", "test_functions", "misc"]
    filepath = sprintf("algorithms/stk-contrib-qsi/contrib-qsi/%s", qsi_paths);
    addpath(genpath(filepath));
end