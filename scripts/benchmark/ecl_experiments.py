# Copyright Notice
#
# Copyright (C) 2024 CentraleSupelec
#
# Authors: Romain Ait Abdelmalek-Lomenech <romain.ait@centralesupelec.fr>
#          Julien Bect <julien.bect@centralesupelec.fr>

import os
import sys

fileDir = os.path.dirname(os.path.abspath(__file__))
sourcePath = os.path.join(fileDir, '../../algorithms/gramacylab-nasa')
sys.path.append(sourcePath)

from ecl_experiments_launcher import ecl_experiments_launcher

case = "branin_mod";
nb_runs = 100;

print(""                                )
print("*** Starting ECL experiments ***")
print(" | test case: %s" % (case)       )
print(" |   nb runs: %d" % (nb_runs)    )
                                        #
ecl_experiments_launcher(case, nb_runs) #
                                        #
print(""                                )
print("*** End of ECL experiments ***"  )
print(""                                )
