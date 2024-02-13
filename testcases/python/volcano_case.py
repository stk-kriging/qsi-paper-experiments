# Copyright Notice
#
# Copyright (C) 2024 CentraleSupelec
#
# Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 

import numpy as np
import os
import sys

fileDir = os.path.dirname(os.path.abspath(__file__))
sourcePath = os.path.join(fileDir, '../volcano-case')
sys.path.append(sourcePath)

from volcano import volcano

class volcano_ecl:
	def __init__(self):
		pass

	def predict(self, X):
		X0 = np.copy(X)
		y = volcano(X0)
		return y
