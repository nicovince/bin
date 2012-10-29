#!/bin/bash

SIM_DIR=`pwd`
SCE=$1
SIM=`basename $SIM_DIR`

cmd="scapa --projName=SQN3210 --bddHistoricScenario=\"[$SIM] $SCE\""
echo $cmd

if [ ! -d $SCE ]; then
  echo "$SCE is not a valid scenario directory"
  exit 1
fi


eval $cmd
