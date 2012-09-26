#!/bin/bash
SVN_EXCLUDE="--exclude=\"\.svn\""
TILDE_EXCLUDE="--exclude=\"~\""
#SIMU_EXCLUDE="--exclude=\"simv\""
SYNTH_EXCLUDE="--exclude=\"synth\""
TAGS_EXCLUDE="--exclude=\"tags\""
CC_OPTIONS="--langmap=C++:.cc"
EXCLUDES="$SVN_EXCLUDE $TILDE_EXCLUDE $SIMU_EXCLUDE $SYNTH_EXCLUDE $TAGS_EXCLUDE "

DEPOT_DIR=~/work/SQN3110/
if [ ! -d "$DEPOT_DIR" ]; then
  echo DEPOT_DIR should be defined
  exit
fi 

cd $DEPOT_DIR

cmd="ctags-svn --links=no --recurse $EXCLUDES --languages=C++ -f swtags $CC_OPTIONS"
echo $cmd
eval $cmd

