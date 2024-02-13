# Copyright Notice
#
# Copyright (C) 2024 CentraleSupelec
#
# Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 

import numpy as np
import os
import sys

fileDir = os.path.dirname(os.path.abspath(__file__))
sourcePath = os.path.join(fileDir, '../../algorithms/gramacylab-nasa/repo/entropy/code/')
sys.path.append(sourcePath)

from eclGP import BraninHooModel

class branin_mod_ecl:
	def __init__(self):
		pass

	def predict(self, X):
		X0 = np.copy(X)
		branin_ecl = BraninHooModel()
		y = branin_ecl.predict(X0)/12 + 3*np.sin(np.float_power(X0[:,0], 1.25)) + np.sin(np.float_power(X0[:,1], 1.25))
		return y
