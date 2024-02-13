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

disp('QSI-SUR: Starting Branin_mod experiments')
parfor it=1:100
    QSI_SUR(@branin_mod_struct, @branin_mod_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Hart4 experiments')
parfor it=1:100
    QSI_SUR(@hart4_struct, @hart4_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Double_camel experiments')
parfor it=1:100
    QSI_SUR(@double_camel_struct, @double_camel_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Volcano experiments')
parfor it=1:100
    QSI_SUR(@volcano_struct, @volcano_config, it, 0, '../../../data')
end


else

disp('QSI-SUR: Starting Branin_mod experiments')
for it=1:100
    QSI_SUR(@branin_mod_struct, @branin_mod_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Double_camel experiments')
for it=1:100
    QSI_SUR(@double_camel_struct, @double_camel_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Hart4 experiments')
for it=1:100
    QSI_SUR(@hart4_struct, @hart4_config, it, 0, '../../../data')
end

disp('QSI-SUR: Starting Volcano experiments')
for it=1:100
    QSI_SUR(@volcano_struct, @volcano_config, it, 0, '../../../data')
end

end

delete(gcp('nocreate'))

