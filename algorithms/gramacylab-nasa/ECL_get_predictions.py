import numpy as np
from sklearn.gaussian_process import GaussianProcessRegressor as GPR
from sklearn.gaussian_process.kernels import RBF
import pandas as pd
import time

import os
import sys
fileDir = os.path.dirname(os.path.abspath(__file__))
sourcePath = os.path.join(fileDir, 'repo/entropy/code/')
sys.path.append(sourcePath)
sourcePath = os.path.join(fileDir, '../../testcases/python')
sys.path.append(sourcePath)

from eclGP import EntropyContourLocatorGP
from extra_utils import reML

import warnings
warnings.filterwarnings("ignore")

name = sys.argv[1]
design_file = sys.argv[2]
xs_file = sys.argv[3]
output_mu = sys.argv[4]
output_std = sys.argv[5]

design = pd.read_csv(design_file, header=None)
design = np.array(design)
xs = np.array(pd.read_csv(xs_file, header=None))
xs = np.array(xs)


def ecl_get_prediction(name, design, xs):

	MC_REPS = 100

	if name == "branin_mod":
		from branin_mod import branin_mod_ecl
		f = branin_mod_ecl()
		threshold = 7.5
		dim = 2
		bounds = ((0, 10), (0, 15))
		n_init = 20
		axT = 1
		n_select = 30

	if name == "double_camel":
		from double_camel import double_camel_ecl
		f = double_camel_ecl()
		threshold = 1.2
		dim = 4
		bounds = ((-2, 2), (-2, 2), (-1, 1), (-1, 1))
		n_init = 40
		axT = 5
		n_select = 300

	if name == "hart4":
		from hart4 import hart4_ecl
		f = hart4_ecl()
		threshold = 1.1
		dim = 4
		bounds = ((0, 1), (0, 1), (0, 1), (0, 1))
		n_init = 40
		n_select = 100

	if name == "volcano":
		from volcano_case import volcano_ecl
		f = volcano_ecl()
		threshold = 0.015
		dim = 7
		bounds = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
		n_init = 70
		n_select = 150	



	y = f.predict(design)
	GP = reML(design, y)
	return GP.predict(xs, return_std = True)


y_pred = np.transpose(ecl_get_prediction(name, design, xs))
pred_mu = y_pred[:,0]
pred_std = y_pred[:,1]
file_mu= open(output_mu, 'bw')
file_std= open(output_std, 'bw')
pred_mu.tofile(file_mu)
pred_std.tofile(file_std)

