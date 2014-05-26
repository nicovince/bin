#!/bin/bash

SHA=$1
message=`git log --format="%s %b" $SHA -n 1`
/delivery/lib/latest5-2/scripts/checkLogKeyword.py "git" "${message}"
