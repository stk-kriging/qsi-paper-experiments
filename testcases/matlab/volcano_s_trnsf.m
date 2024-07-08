% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>

function s_transfo = volcano_s_trnsf(s)

alpha = 2;
beta = 2;

s_transfo = betainv(double(s), alpha, beta);

end
