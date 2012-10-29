#!/bin/bash

# check we are in a database
svn info &> /dev/null
if [ $? -ne 0 ]; then
  echo `pwd` is not a svn database
  exit 1
fi


while [ $# -gt 0 ] ; do
  case $1 in 
    -h|--help)
      echo "Copy svn folder with only versioned files"
      echo "usage : $0 <src> <dest>"
      exit 1;;
    *)
      if [ -z "$SRC" ]; then
        SRC=$1
      else
        DEST=$1
      fi
      ;;
  esac
  shift
done

#####################
## MUTLIPLE CHECKS ##
#####################

# SRC specified ?
if [ -z $SRC ]; then
  echo "Source folder not specified"
  exit 1
fi

# DEST specified ?
if [ -z $DEST ]; then
  echo "Destination folder not specified"
  exit 1
fi

# SRC is a folder ?
if [ ! -d $SRC ]; then
  echo "Source must exists and must be a folder"
  exit 1
fi

# SRC is a revisioned folder ?
svn info $SRC &> /dev/null
if [ $? -ne 0 ]; then
  echo $SRC is not a revisioned folder
  exit 1
fi

# DEST already exists ?
if [ -e $DEST ]; then
  echo "destination ($DEST) already exists"
  exit 1
fi



IFS='
'
mkdir $DEST
for i in `svn ls $SRC`; do
  cp $SRC/$i $DEST
done


