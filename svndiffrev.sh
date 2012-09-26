#!/bin/bash

while [ $# -gt 0 ] ; do
  case $1 in 
    -r)
      REV=$2
      shift;;
    -h)
      echo "Usage : svndiffrev.sh -r <revnumber> files"
      exit 1;;
    *)
      FILES="$FILES $1"
  esac
  shift
done

# retrieve the svn repository
URL=`svn info | grep URL | sed 's/URL: //'`
echo URL : $URL
SVN_REPOSITORY=`echo $URL | sed 's/.*svn\.sequans\.com\///' | sed 's/\/.*//'`
echo repo : $SVN_REPOSITORY
SVN_PATH=`echo $URL | sed "s/.*$SVN_REPOSITORY//"`
echo path : $SVN_PATH

REV_M1=$(($REV - 1))
cmd="svn log -r $REV_M1:$REV $FILES"
echo $cmd
eval $cmd
cmd="svn diff -r $REV_M1:$REV $FILES"
echo $cmd
eval $cmd

URL="http://svn.sequans.com/comp.php?repname=$SVN_REPOSITORY&path=/&compare[]=$SVN_PATH/@$REV_M1&compare[]=$SVN_PATH/@$REV"
echo $URL
