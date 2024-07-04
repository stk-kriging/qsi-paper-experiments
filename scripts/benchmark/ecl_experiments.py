# Copyright Notice
#
# Copyright (C) 2024 CentraleSupelec
#
# Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr> 


import os
import sys

fileDir = os.path.dirname(os.path.abspath(__file__))
sourcePath = os.path.join(fileDir, '../../algorithms/gramacylab-nasa')
sys.path.append(sourcePath)

from ecl_experiments_launcher import *

case = "branin_mod";
nb_runs = 100;

print("Starting ECL experiments (%s) " %(case))
ecl_experiments_launcher(case, nb_runs)

