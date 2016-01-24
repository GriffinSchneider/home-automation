#!/bin/bash
source $(dirname $0)/aliases.sh

allon
sleep 2

if [[ $(($RANDOM % 2)) = 0 ]]
then
    brightlax
else
    deepsea
fi
