# qsi-paper-experiments

This repository contains data and scripts used for the numerical experiments of `https://arxiv.org/abs/2211.01008`.

## How to clone this repository

This repository contains [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

You can clone it and initialize the submodules in one step like this:
```
## Using ssh...
git clone --recurse-submodules git@github.com:stk-kriging/qsi-paper-experiments.git
## ...or using https
git clone --recurse-submodules https://github.com/stk-kriging/qsi-paper-experiments.git
```

If you have already cloned the repository, you can initialize the submodules using:
```
git submodule update --init
```

List of the submodules used by this project:
 * `algorithms/stk-contrib-qsi/stk-2.8.1`: STK toolbox, version 2.8.1.
 * `algorithms/stk-contrib-qsi/contrib-qsi`: Matlab code for the proposed algorithm (QSI-SUR) and some competitors.
 * `algorithms/gramacylab-nasa/repo`: Python code for the ECL algorithm of (Cole et al, 2023).

## Experiments and results reproduction

All the results used or displayed in the article and its supplementary materials (sequential/initial designs, estimated covariance parameters, graphs...) and the associated data are saved in the folder `data/`. The scripts located at the root of this project have the following utilities:

`DEMO_QSI.m` displays a demonstration of the QSI-SUR strategy on the synthetic function `f_1`, by generating a random initial design and displaying, every 3 steps, the points chosen by the sampling criterion.

Three scripts allow to reproduce (totally or partially) the experiments and the associated data:
- `matlab_experiments.m` constructs sequential designs using the QSI-SUR, Joint-SUR, Ranjan, max. misclassification and random satrategies.
- `ecl_experiments.m` constructs sequential designs using the ECL strategy.
- `results_computation.m` computes the stepwise proportion of misclassified points for all the competitor strategies `data/results`.

By default, these scripts produces results for 100 runs, without using parallel computing, for the synthethic test function `f_1`. The full reproduction of the experiments used in the paper can take a (very) long time, but this can be alleviate 
by reducing the number of runs, activating parallel computing, or modifying the configuration file of the considered test case (see next section). 

More details on the sub-functions involved in thoses scripts can be found in `algorithms/stk-contrib-qsi/contrib-qsi/README.md`.

The figures displayed in the article can be reproduce, using the data stored in `data/`, by launching the scripts:
- `Figure_i.m` (with i = 1, 3, 6, 7) for the corresponding figure.
- `Figures_convergence.m` for the figures 4, 5, 9 and the ones displayed in the supplementary material, for a given function (by default, `f_1`).

## Test functions
The test functions are named differently in the paper and in this project. The correspondance is as follows:
- `f_1` = `branin_mod`.
- `f_2` = `double_camel`.
- `f_3` = `hart4`.
- `Volcano` = `volcano`.

Each test `function` (and associated QSI problem) is composed and described by several files:
- `function.m` or `function.py`, the associated function either coded in matlab or python.
- `function_s_trnsf.m`, the inverse mapping associated to the probability distribution on the uncertain inputs.
- `function_struct.m`, describing the problem (threshold, critical region, input spaces...)
- `function_config.m`, a configuration file for the different matlab-implemented strategies (number of steps, size of the integration grid, number of candidates points...).

All the `function`-related files are located in `algorithms/stk-contrib-qsi/contrib-qsi/test_functions`, except for the base function of the Volcano case (`testcases/volcano`) and the python implementation
of the functions (`testcases/python`).

More details can be found in `algorithms/stk-contrib-qsi/contrib-qsi/README.md`.

## About ECL (Cole et al. 2023)

In order to launch the ECL-related experiments, it is necessary to apply the patch

    algorithms/gramacylab-nasa/ecl.patch
	
using `git am`, to the cloned repository located in

    algorithms/gramacylab-nasa/repo

This can be done automatically, on unix-like systems, using the script

    algorithms/gramacylab-nasa/apply-patch.sh

Package requirements for ECL can be found in

    algorithms/gramacylab-nasa/requirements.txt


## Acknowledgements

The authors are grateful to Valérie Cayol and Rodolphe Le Riche for sharing their R implementation of the Mogi model used for the Volcano test case.
This work has been funded by the French National Research Agency (ANR), in the context of the project SAMOURAI (ANR-20-CE46-0013).

