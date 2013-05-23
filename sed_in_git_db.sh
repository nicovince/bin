#!/bin/bash

SEARCH_PATTERN=$1
REPLACE_PATTERN=$2

FILES=`git grep -l "\<$1\>"`

for f in $FILES; do
  sed -i "s/\<${SEARCH_PATTERN}\>/${REPLACE_PATTERN}/g" $f
done
