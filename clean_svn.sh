#!/bin/bash

DEPOT_DIR="./"
DRY_RUN=0

# file patterns to exclude (one pattern per line !)
EXCLUDE="tags
hvsyn
asic.*rpt"

#No constraints on file's date by default
OLDER_THAN=""

while [ $# -gt 0 ] ; do
  case $1 in 
    -repo)
      DEPOT_DIR=$2
      shift;;
    -o)
      OLDER_THAN=$2
      shift;;
    -n)
    echo Dry run, will not remove anything
    DRY_RUN=1;;
    -e)
    EXCLUDE="$EXCLUDE
$2"
    shift;;
    -h|*)
      echo "Remove big files in a repository which are not versioned"
      echo "usage : $0 [options]"
      echo "  -repo <path> : specify repository path"
      echo "  -n           : dry run, do not erase anything"
      echo "  -e           : adds a pattern to exclude"
      echo "  -o           : specify the minimum number of day the file was last modified"
      exit 1
  esac
  shift
done

cd $DEPOT_DIR

# check we are in a database
svn info &> /dev/null
if [ $? -ne 0 ]; then
  echo $DEPOT_DIR is not a svn database
  exit 1
fi

# No Dry Run fail safe
if [ $DRY_RUN -eq 0 ]; then
  echo "Warning : Will remove a lot of file. Are you sure ? (Ctrl-C to exit, enter to continue)"
  read
fi

# File separator is carriage return, otherwise the script fails on files containing spaces
# (but who are the morons who still do it anyway ?)
IFS='
'

if [ -n "$OLDER_THAN" ]; then
  OPTIONS="-mtime +$OLDER_THAN"
fi

find_cmd="find . -name ".svn" -prune -o -size +3M -print $OPTIONS"
echo $find_cmd
# get list of files bigger than 3M (excluding .svn directory)
list=`eval $find_cmd`
size=0

for e in $EXCLUDE; do
  echo "exclude [$e]"
done
for i in $list; do

  # check if file is not a versionned file
  svn ls "$i" &> /dev/null
  if [ $? -ne 0 ]; then

    # check if we want to exclude the file
    exclude=0
    for e in $EXCLUDE; do
      echo $i | grep "$e" > /dev/null
      if [ $? -eq 0 ]; then
        exclude=1
        echo "preserve file $i (match with $e)"
      fi
    done

    # remove file
    if [ $exclude -eq 0 ]; then
      # retrieve file size and update total
      size_i=`ls -l "$i" | awk '{print $5}'`
      size=$(($size + $size_i))
      if [ $DRY_RUN -eq 0 ]; then
        rm "$i"
      else
        echo "rm $i"
      fi
    fi
  fi
done

# report
if [ $DRY_RUN -eq 0 ]; then
  echo removed $(($size/(1024*1024)))MB
else
  echo Would have removed $(($size/(1024*1024)))MB
fi
