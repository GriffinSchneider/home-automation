#!/bin/bash
source $(dirname $0)/aliases.sh

if [[ $(($RANDOM % 2)) = 0 ]]
then
    relax
else
    deepsea
fi
