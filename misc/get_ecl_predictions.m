% Get the ECL predictions inside matlab.


function Y = get_ecl_predictions(name, design)

design = double(design);
%grid = double(grid);
here = fileparts (mfilename ('fullpath'));
python_script = fullfile (here, '../algorithms/gramacylab-nasa', 'ECL_get_predictions.py');


iodir_base = fullfile (tempdir (), 'ecl_pred');
if ~ exist (iodir_base, 'dir')
    mkdir (iodir_base);
end
if ~ exist (iodir_base, 'dir')
    error ('This should never happen...');
end

iodir = tempname (iodir_base);
cleanUp = onCleanup(@()rmdir(iodir, 's')); 

if exist (iodir, 'dir')
    error ('This should never happen...');
end
mkdir (iodir);
if ~ exist (iodir, 'dir')
    error ('This should never happen...');
end

design_csv = fullfile (iodir, 'design.csv');
grid_csv = fullfile (fileparts(mfilename('fullpath')), '../data/grid/grid_'+name'+'.csv');
output_mu = fullfile (iodir, 'output_mu.bin');
output_std = fullfile (iodir, 'output_std.bin');

csvwrite (design_csv, design);
%csvwrite(grid_csv, grid);


env_ECL = fullfile(here, '../env_ECL/bin/activate');
cmd1 = sprintf('source %s', env_ECL);
cmd2 = sprintf ('python3 %s %s %s %s %s %s', python_script, name, design_csv, grid_csv, output_mu, output_std);

[status, output] = system (sprintf('%s; %s', cmd1, cmd2), '-echo');

if status ~= 0
    fprintf ('\n!!!!!!!!!!!!!!!!!!!!\n');
    disp (output);
    fprintf ('!!!!!!!!!!!!!!!!!!!!\n\n');
    error ('Python failure');
end

[status, output] = system (sprintf('deactivate'));

if status ~= 0
    fprintf ('\n!!!!!!!!!!!!!!!!!!!!\n');
    disp (output);
    fprintf ('!!!!!!!!!!!!!!!!!!!!\n\n');
    fprintf ('Command line was: cmd=''%s''\n\n', cmd);
    error ('virtualenv deactivation failure');
end

fid = fopen (output_mu);
Y_mu = fread (fid, 'double');
fclose (fid);  %#ok<CSVRD>
fid = fopen (output_std);
Y_std = fread (fid, 'double');
fclose (fid);  %#ok<CSVRD>
%size(Y_mu)
Y = [Y_mu, Y_std];

end