#!/bin/bash

IFS='
'

gen_m3u()
{
  ls *mp3 *ogg > `basename $PWD`.m3u
}

FOLDER_LIST=`ls -d */`

for i in $FOLDER_LIST; do
  cd $i
  pwd
  m3u_file=`find . -maxdepth 1 -iname "*m3u"`
  if [ -z $m3u_file ]; then
    mp3_files=`ls *mp3 *ogg`
    if [ -n "$mp3_files" ]; then
      gen_m3u
    fi
  fi
  cd ../
done
