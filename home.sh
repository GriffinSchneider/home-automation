#!/bin/bash
source $(dirname $0)/aliases.sh

allon
sleep 2

if [[ $(($RANDOM % 2)) = 0 ]]
then
    relax
    sleep 2
    bright
else
    deepsea
fi
