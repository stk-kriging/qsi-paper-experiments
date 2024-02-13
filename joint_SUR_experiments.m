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
[clust, clustClean] = get_cluster(); 
parpool(clust, POOL)
pctRunOnAll run startup.m
pctRunOnAll warning ('off','all');

disp('Joint-SUR: Starting Branin_mod experiments')
parfor it=1:100
    joint_SUR(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Joint-SUR: Starting Double_camel experiments')
parfor it=1:100
    joint_SUR(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Joint-SUR: Starting Hart4 experiments')
parfor it=1:100
    joint_SUR(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Joint-SUR: Starting Volcano experiments')
parfor it=1:100
    joint_SUR(@volcano_struct, @volcano_config, it, '../../../data')
end

else

disp('Joint-SUR: Starting Branin_mod experiments')
for it=1:100
    joint_SUR(@branin_mod_struct, @branin_mod_config, it, '../../../data')
end

disp('Joint-SUR: Starting Double_camel experiments')
for it=1:100
    joint_SUR(@double_camel_struct, @double_camel_config, it, '../../../data')
end

disp('Joint-SUR: Starting Hart4 experiments')
for it=1:100
    joint_SUR(@hart4_struct, @hart4_config, it, '../../../data')
end

disp('Joint-SUR: Starting Volcano experiments')
for it=1:100
    joint_SUR(@volcano_struct, @volcano_config, it, '../../../data')
end

end

delete(gcp('nocreate'))

