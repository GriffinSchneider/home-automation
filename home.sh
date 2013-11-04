source $(dirname $0)/common.sh

if [[ $(($RANDOM % 2)) = 0 ]]
then
    relax
else
    deepsea
fi
