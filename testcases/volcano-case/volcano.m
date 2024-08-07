% SYNTAX: J = volcano (XS)


function J = volcano (xs)

if isa (xs, 'stk_dataframe')
    rownames = xs.rownames;
else
    rownames = {};
end

xs = double (xs);
[n, d] = size (xs);

assert ((d == 7) && (isequal (size (xs), [n 7])));

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

input_csv = fullfile (iodir, 'volcano_temp_input.csv');
output_csv = fullfile (iodir, 'volcano_temp_output.csv');

csvwrite (input_csv, xs);  %#ok<CSVWT> 

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

J = csvread (output_csv, 1, 0);  %#ok<CSVRD> 
J = stk_dataframe (J, {'J'}, rownames);
assert (isequal (size (J), [n, 1]));

delete (input_csv);
delete (output_csv);
%rmdir (iodir);

end % function
