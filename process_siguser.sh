#!/bin/bash
for i in `cat sigusrdump.out | awk '{print $3}' | sed '1d'`; do
  #echo $i
  res=`c++filt $i`
done
