% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>


POOL = 0;

delete(gcp('nocreate'))

if POOL > 0

delete(gcp('nocreate'))
[clust, clustClean] = get_cluster(); %create temporary files to avoid bug wwhen using several pools.
parpool(clust, POOL)
pctRunOnAll run startup.m
pctRunOnAll warning ('off','all');

disp('Random: Starting Branin_mod experiments')
parfor it=1:100
    random(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Random: Starting Double_camel experiments')
parfor it=1:100
    random(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Random: Starting Hart4 experiments')
parfor it=1:100
    random(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Random: Starting Volcano experiments')
parfor it=1:100
    random(@volcano_struct, @volcano_config, it, '../../../data')
end

else

disp('Random: Starting Branin_mod experiments')
for it=1:100
    random(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Random: Starting Double_camel experiments')
for it=1:100
    random(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Random: Starting Hart4 experiments')
for it=1:100
    random(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Random: Starting Volcano experiments')
for it=1:100
    random(@volcano_struct, @volcano_config, it, '../../../data')
end

end

delete(gcp('nocreate'))

