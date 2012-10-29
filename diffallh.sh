#!/bin/bash
for i in *.h; do
  f1=$i
  f2=$i.new
  headerdiff.sh $f1 $f2
  echo --------------------
done
