import numpy as np
import os
import sys

class double_camel_ecl:
	def __init__(self):
		pass

	def predict(self, X):
		X0 = np.copy(X)
	
		term1 = (4 - 2.1 * np.float_power(X0[:,0],2) + np.float_power(X0[:,0],4)/3)
		term1 = np.multiply(term1, np.float_power(X0[:,0],2))
		term2 = np.multiply(X0[:,0],X0[:,2])
		term3 = (-4+4*np.float_power(X0[:,2],2))
		term3 = np.multiply(term3, np.float_power(X0[:,2],2))
		y1 = term1 + term2 + term3

		term1 = (4 - 2.1 * np.float_power(X0[:,1],2) + np.float_power(X0[:,1],4)/3)
		term1 = np.multiply(term1, np.float_power(X0[:,1],2))
		term2 = np.multiply(X0[:,1],X0[:,3])
		term3 = (-4+4*np.float_power(X0[:,3],2))
		term3 = np.multiply(term3, np.float_power(X0[:,3],2))
		y2 = term1 + term2 + term3

		y = (y1 + y2)/2

		return y
