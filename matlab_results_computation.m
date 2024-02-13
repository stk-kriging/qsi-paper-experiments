% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>




POOL = 0;

delete(gcp('nocreate'))

method = ["random", "misclassification", "Ranjan", "joint_m", "QSI_m"];

if POOL > 0

    delete(gcp('nocreate'))
    [clust, clustClean] = get_cluster(); %create temporary files to avoid bug wwhen using several pools.
    parpool(clust, POOL)
    pctRunOnAll run startup.m
    pctRunOnAll warning ('off','all');

    for j = 1:size(method,2)
        algo = method(j);

        disp(algo+': Starting Branin_mod results computation')
        parfor it=1:100
            extract_deviation(@branin_mod_struct, @branin_mod_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Double_camel results computation')
        parfor it=1:100
            extract_deviation(@double_camel_struct, @double_camel_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Hart4 results computation')
        parfor it=1:100
            extract_deviation(@hart4_struct, @hart4_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Volcano results computation')
        parfor it=1:100
            extract_deviation(@volcano_struct, @volcano_config, algo, it, '../../../../data')
        end
    end

else
    for j = 1:size(method,2)
        algo = method(j);

        disp(algo+': Starting Branin_mod results computation')
        for it=1:100
            extract_deviation(@branin_mod_struct, @branin_mod_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Double_camel results computation')
        for it=1:100
            extract_deviation(@double_camel_struct, @double_camel_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Hart4 results computation')
        for it=1:100
            extract_deviation(@hart4_struct, @hart4_config, algo, it, '../../../../data')
        end

        disp(algo+': Starting Volcano results computation')
        for it=1:100
            extract_deviation(@volcano_struct, @volcano_config, algo, it, '../../../../data')
        end
    end
end

delete(gcp('nocreate'))


