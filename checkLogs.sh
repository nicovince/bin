#!/bin/bash

start_hash=$1
end_hash=$2

for h in `git log ${start_hash}..${end_hash} --pretty=format:"%H"`; do
  message=`git log -1 ${h} --pretty=format:"%s %b"`

  /delivery/lib/latest5-2/scripts/checkLogKeyword.py "git" "${message}" #> /dev/null 2>&1
  status=$?
  if [ ${status} -ne 0 ]; then
    echo "${h} : ${message}"
  fi
done
