import numpy as np
from sklearn.gaussian_process import GaussianProcessRegressor as GPR
from sklearn.gaussian_process.kernels import RBF
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


def ecl_experiments_launcher(name, nb_runs):

	MC_REPS = nb_runs;

	if name == "branin_mod":
		from branin_mod import branin_mod_ecl
		f = branin_mod_ecl()
		threshold = 7.5
		dim = 2
		bounds = ((0, 10), (0, 15))
		n_init = 20
		n_cand = 4000
		n_select = 30

	if name == "double_camel":
		from double_camel import double_camel_ecl
		f = double_camel_ecl()
		threshold = 1.2
		dim = 4
		bounds = ((-2, 2), (-2, 2), (-1, 1), (-1, 1))
		n_init = 40
		n_cand = 4000
		n_select = 300

	if name == "hart4":
		from hart4 import hart4_ecl
		f = hart4_ecl()
		threshold = 1.1
		dim = 4
		bounds = ((0, 1), (0, 1), (0, 1), (0, 1))
		n_init = 40
		n_cand = 4000
		n_select = 100

	if name == "volcano":
		from volcano_case import volcano_ecl
		f = volcano_ecl()
		threshold = 0.015
		dim = 7
		bounds = ((0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1), (0, 1))
		n_init = 70
		n_cand = 4000
		n_select = 150	



	def limit_state_function(y):
		return y-threshold



	ecl_designs = np.zeros((n_init+n_select, (dim+1)*MC_REPS))


	for i in range(MC_REPS):

		X0 = np.loadtxt("../../data/doe_init/doe_init_"+name+"_" + str(i + 1) +"_init.csv", delimiter=',')
		Y0 = f.predict(X0)
		## Adaptive design with ECL

		init_gp = reML(X0, Y0)

		eclgp = EntropyContourLocatorGP(init_gp, limit_state_function)
	
		eclgp.fit(n_select, f, bounds, 1, n_cand)

		ecl_designs[:,((dim+1)*i):((dim+1)*(i+1))] = \
		np.hstack((eclgp.X_, eclgp.y_.reshape((-1,1))))


		np.savetxt("../../data/results/design/doe_ecl_"+name+"_"+str(i+1)+".csv", 
			ecl_designs[:,((dim+1)*i):((dim+1)*(i+1))-1], delimiter = ",")
