## Locate "Gramacy Lab" directory
SCRIPT=$(readlink -f "$0")
G=$(dirname "$SCRIPT")

## Apply patch
cd ${G}/repo && git am ${G}/ecl.patch
