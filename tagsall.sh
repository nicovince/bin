#!/bin/bash
source $HOME/bin/utils.sh

for i in $REPO_LIST; do
  if [ -d $i ]; then
    echo "tagging $i..."
    hwctags.sh -repo $i
  else
    echo "$i does not exists anymore"
  fi
done
