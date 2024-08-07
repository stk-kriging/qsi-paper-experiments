import os
import sys
import tempfile
import shutil
import atexit
import string
import numpy as np


def volcano(xs):
	
	fileDir = os.path.dirname(os.path.abspath(__file__))
	R_script = os.path.join(fileDir, 'volcano_cmd.R')
	simulator = os.path.join(fileDir, 'volcano.R')
	
	tempdir = tempfile.mkdtemp()
	#atexit.register(shutil.rmtree(tempdir))
	input_csv = os.path.join(tempdir, 'input.csv')
	output_csv = os.path.join(tempdir, 'output.csv')

	np.savetxt(input_csv, np.atleast_2d(xs), delimiter = ",")

	cmd = string.Template('Rscript --verbose $a $b $c $d').substitute(a=R_script, b=simulator, c=input_csv, d=output_csv)
	os.system(cmd)

	results = np.loadtxt(output_csv, delimiter=",", skiprows=1)
	shutil.rmtree(tempdir)

	return results
