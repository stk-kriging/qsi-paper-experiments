import numpy as np
import os
import sys

class hart4_ecl:
	def __init__(self):
		self.alpha = np.array([1.0, 1.2, 3.0, 3.2]);

		self.A = np.array([[10, 3, 17, 3.5, 1.7, 8],
		[0.05, 10, 17, 0.1, 8, 14],
		[3, 3.5, 1.7, 10, 17, 8],
		[17, 8, 0.05, 10, 0.1, 14]])

		self.P = 10**(-4) * np.array([[1312, 1696, 5569, 124, 8283, 5886],
		[2329, 4135, 8307, 3736, 1004, 9991],
		[2348, 1451, 3522, 2883, 3047, 6650],
		[4047, 8828, 8732, 5743, 1091, 381]])

	def predict(self, X):
		X0 = np.copy(X)
		outer = 0
		
		for ii in range(4):
			inner = 0;
			for jj in range(4):
				xj = X0[:,jj]
				Aij = self.A[ii, jj]
				Pij = self.P[ii, jj]
				inner = inner + Aij*np.power(xj-Pij, 2)
			
			new = self.alpha[ii] * np.exp(-inner)
			outer = outer + new
		y = -(1.1 - outer) / 0.839
		return y
