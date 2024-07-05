## Locate "Gramacy Lab" directory
SCRIPT=$(readlink -f "$0")
GL=$(dirname "$SCRIPT")

## Check if target directory exists
if [ -d "${GL}/repo" ]; then
    echo "Directory ${GL}/repo already exists!"
    exit 1
fi

## Clone git repository
git clone https://bitbucket.org/gramacylab/nasa.git ${GL}/repo

## Visit repo
WHERE_I_WAS=`pwd`
cd ${GL}/repo

## Checkout the revision used for the experiments in the paper
## (was the most recent commit at that time)
git checkout -b qsi-paper-experiments 27dfc3df54fafcca40008790d68b0b3876316e40

## Apply patch
git am ${GL}/ecl.patch

## Create python virtual environment at root of the repository
cd ${GL}/../..
virtualenv env_ECL

## Install requirements
source env_ECL/bin/activate
pip install -r ${GL}/requirements.txt
deactivate

## The end
cd ${WHERE_I_WAS}
