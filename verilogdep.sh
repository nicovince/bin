#!/bin/bash

SOURCE=$1
TARGET=$2

get_deps() {
  src=$1
  deps=`grep '\`include' $src | sed '/\/\//d' | sed 's/.*\`include\s*"\(.*\)".*/\1/' | sort | uniq`
  echo $deps
}

SRC_DEPS=`get_deps $SOURCE`

# loop through dependencies files add them to DEPS and retrieve dependencies for them
for d in $SRC_DEPS; do

  # check if dependencies are not already added in DEPS
  cnt=`echo $DEPS | grep -c $d`
  if [ $cnt -eq 0 ]; then
    DEPS="$DEPS $d"
  fi

  if [ -f $d ]; then
    dep=`get_deps $d`
    # check if dependencies are not already added in DEPS
    for dd in $dep; do
      cnt=`echo $DEPS | grep -c $dd`

      #
      if [ $cnt -eq 0 ]; then
        DEPS="$DEPS $dd"
      fi
    done
  fi
done



echo -n "$TARGET : $SOURCE "
for d in $DEPS; do
  echo -n "\\
  $d "
done
echo
