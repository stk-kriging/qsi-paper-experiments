% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>

function config = volcano_config ()

% Set default parameters
config = example_config (5, 2);

% Number of iterations of the algorithm
config.T = 150;

% Number of iterations between two performance evaluations
config.axT = 3;

end
