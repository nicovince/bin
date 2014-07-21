#!/bin/bash

SHA=$1
SHAS=`git log --format="%H" origin/private/nvincent/main..private/nvincent/main`
for s in $SHAS; do
  message=`git log --format="%s %b" $s -n 1`
  echo "check $s"
  /delivery/lib/latest5-2/scripts/checkLogKeyword.py "git" "${message}"
done
