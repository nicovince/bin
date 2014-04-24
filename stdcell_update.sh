#!/bin/bash

DIR=$1
VERILOGS=`find $1 -name "*.v"`
for i in $VERILOGS; do
  f=`basename $i`
  target=`find $PWD -name $f`
  if [ ! -f $target ]; then
    echo target $target does not exists
    exit 1
  fi
  echo file : $i
  echo target : $target
  cp -v $i $target
done
