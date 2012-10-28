#!/bin/bash
# movie_sub.sh
# Description : 
# This scripts launch gmplayer to read the movie given in argument, it tries
# to locate a subtitle matching the filename of the movie or approaching
# The first argument of this script should be the filename of the movie
# The second if given is a unique part of the subtitle directory name 
#(ie 'vf' or 'vo' for 'sub_vf/' and 'sub_vo/' could be 'vf_sub', 'vo_sub')
strtok()
{
  str=$@
  str=`echo $str | tr "._-" "   " | sed -e 's/\[.*\]//g'`
  echo $str
}

strcmp()
{
  str1=$1
  str2=$2
  nb_hit=0
  for tok in $str2; do
    hit=`echo $str1 | grep -c -i $tok`
    nb_hit=$(($nb_hit + $hit))
  done
  echo $nb_hit
}

VID_PLAYER="gmplayer"

NB_ARGS=$#

if [ ${NB_ARGS} -ge 1 ]; then
  FILENAME=$1
else
  FILENAME=`kdialog --title "Choisir fichier vidéo" --getopenfilename .`
fi

SHORTNAME=`basename "${FILENAME}"`
DIRNAME=`dirname "${FILENAME}"`
PREFIX_NAME=${SHORTNAME%.*}
TOKEN_PREFIX=`strtok "$PREFIX_NAME"`

PB_DIR="/home/nicolas/Documents/Videos/Prison_Break"
#cd "$PB_DIR"
#sed -r 's/\([^0-9]*\)\([0-9]*\)[^0-9]*/$2 $1/'`
#grep -o -E "[sS]*[0-9]*[eE]*[0-9]{1,}"
NUMBER=`echo ${SHORTNAME} | grep -o -i -E "s*[0-9]*[eExX]*[0-9]{1,}" | head -n 1`
SEASON=`echo ${NUMBER} | sed 's/[eExX][0-9]*//'`
EPISODE=`echo ${NUMBER} | sed 's/[0-9]*[eExX]*//'`
kdialog --msgbox "number $NUMBER"
kdialog --msgbox "season $SEASON"
kdialog --msgbox "episode $EPISODE"
REGEX="${SEASON}[eExX]*${EPISODE}"

if [ ${NB_ARGS} -eq 2 ]; then
  if [ -d *$2* ]; then
    subdir=`ls -1d *$2* | head -n 1`
    SUBFILE=`find $subdir -iregex .*"$REGEX".*srt | head -n 1`
  else
    SUBFILE=`find . -maxdepth 2 -iregex .*"$REGEX".*srt | head -n 1`
  fi
else # The subtitle is not in a directory
  BLANK=""
  if [ "$REGEX" = "$BLANK" ]; then # we could not find a number in the filename
    # We are probably looking for a single movie, not a serie
    # We try a subfile which match the video filename (w/o extention avi, mpg...)
    SUBFILE=`find . -maxdepth 1 -iregex .*"$PREFIX_NAME".*srt | head -n 1`
  else # Look for a subfile containing the number in current and first subdir
    SUBFILE=`find . -maxdepth 2 -iregex .*"$REGEX".*srt | head -n 1`
  fi
fi

if [ ! -f "$SUBFILE" ]; then
  max_hit=0
  for i in *.srt; do
    token_sub=`strtok "$i"`
    hit_for_file=`strcmp "$token_sub" "$TOKEN_PREFIX"`
    if [ $max_hit -lt $hit_for_file ]; then # We have a better match
      SUBFILE=$i
      max_hit=$hit_for_file 
    fi
  done
  # We should ask here if the SUBFILE is correct
  kdialog --yesnocancel "Sous titre à utiliser : $SUBFILE"
  retour=$?
  case $retour in 
    0);;
    1)SUBFILE=`kdialog --title "Choisir sous-titres" --getopenfilename .`;;
    *)exit 1;;
  esac
fi

if [ -f "$SUBFILE" ]; then
  echo $VID_PLAYER "${FILENAME}" -sub "$SUBFILE"
  $VID_PLAYER "${FILENAME}" -sub "$SUBFILE"
else
  echo $VID_PLAYER "${FILENAME}"
  $VID_PLAYER "${FILENAME}"
fi
