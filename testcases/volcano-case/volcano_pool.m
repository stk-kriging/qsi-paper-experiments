% Copyright Notice
%
% Copyright (C) 2024 CentraleSupelec
%
%    Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 
%             Julien Bect <julien.bect@centralesupelec.fr>


function z = volcano_pool(x, nb_cpu)
    
    if nargin < 2
        nb_cpu = 25;
    end
    x = double(x);
    assert (size(x,2)==7);
    n = size(x,1);

    limit_n = fix(n/nb_cpu);

    n_int = fix(n/limit_n);
    batch = [0];

    if n_int >= 1
    batch = [batch, (1: n_int)*limit_n];
    end

    if mod(n, limit_n) ~= 0
        batch = [batch, batch(size(batch,2)) + mod(n,limit_n)];
    end
    
    here = fileparts (mfilename ('fullpath'));
    R_script = fullfile (here, 'volcano_cmd.R');
    simulator = fullfile (here, 'volcano.R');

    iodir_base = fullfile (tempdir (), 'volcano');
    if ~ exist (iodir_base, 'dir')
        mkdir (iodir_base);
    end
    if ~ exist (iodir_base, 'dir')
        error ('This should never happen...');
    end

    iodir = tempname (iodir_base);
    cleanUp = onCleanup(@()rmdir(iodir, 's')); %delete /tmp/volcano/temp_dir if error/interrupt

    if exist (iodir, 'dir')
        error ('This should never happen...');
    end
    mkdir (iodir);
    if ~ exist (iodir, 'dir')
        error ('This should never happen...');
    end


    delete(gcp('nocreate'))
    parpool(nb_cpu)
    pctRunOnAll run(which('stk_init.m'))
    pctRunOnAll warning ('off','all')

    parfor it = 1:size(batch,2)-1
    x_batch = x(batch(it)+1:batch(it+1),:);
    
    input_csv = fullfile (iodir, "volcano_temp_input_"+int2str(it)+".csv");
    output_csv = fullfile (iodir, "volcano_temp_output_"+int2str(it)+".csv");

    csvwrite (input_csv,x_batch); 
    
    cmd = sprintf ('Rscript --verbose %s %s %s %s', ...
    R_script, simulator, input_csv, output_csv);

    [status, output] = system (cmd);

    if status ~= 0
        fprintf ('\n!!!!!!!!!!!!!!!!!!!!\n');
        disp (output);
        fprintf ('!!!!!!!!!!!!!!!!!!!!\n\n');
        fprintf ('Command line was: cmd=''%s''\n\n', cmd);
        error ('Rscript failure');
    end
    

    delete (input_csv);

end

delete(gcp('nocreate'))

z = [];

for it = 1:size(batch,2)-1
    output_csv = fullfile (iodir, "volcano_temp_output_"+int2str(it)+".csv");
    z_batch = csvread (output_csv, 1, 0);
    z = [z; z_batch];
    delete(output_csv);
end


end