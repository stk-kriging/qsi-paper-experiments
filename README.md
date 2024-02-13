# qsi-paper-experiments

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

## Experiments reproduction

All the results used or displayed in the article and its supplementary materials (sequential/initial designs, estimated covariance parameters, graphs...) are saved in the folder `data/`.

Several scripts denoted `ALGO_experiments`, with `ALGO` a competitor strategy, allow to reproduce the experiments of the paper. It can be done using parallelisation by setting, in each script, the variable `POOL` to the desired number of parallel workers.

The scripts whose name contain `results_computation` allows to extract the proportion of misclassified points for the differents experiments, with also the same parallelisation option.

## About ECL (Cole et al. 2023)

In order to launch the ECL experiments, it is necessary to apply a patch the initial repository. This can be done automatically by executing the script `APPLY_ECL_PATCH.sh`.

Or more generally, on unix-based OS, by executing the following commands
```
cd algorithms/gramacylab-nasa/repo
git apply ../ecl.patch .
``` 

All the package requirements for ECL can be found in `ecl_requirements.txt`.

