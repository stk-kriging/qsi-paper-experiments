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

disp('Misclassification: Starting Branin_mod experiments')
parfor it=1:100
    misclassification(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Misclassification: Starting Double_camel experiments')
parfor it=1:100
    misclassification(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Misclassification: Starting Hart4 experiments')
parfor it=1:100
    misclassification(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Misclassification: Starting Volcano experiments')
parfor it=1:100
    misclassification(@volcano_struct, @volcano_config, it, '../../../data')
end


else

disp('Misclassification: Starting Branin_mod experiments')
for it=1:100
    misclassification(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Misclassification: Starting Double_camel experiments')
for it=1:100
    misclassification(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Misclassification: Starting Hart4 experiments')
for it=1:100
    misclassification(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Misclassification: Starting Volcano experiments')
for it=1:100
    misclassification(@volcano_struct, @volcano_config, it, '../../../data')
end

end

delete(gcp('nocreate'))

