#!/bin/bash

if [ "$1" = "-h" ]; then
  echo "$0 <Nb_Episodes>"
  echo "Season number extract from directory"
  exit 0
fi
# Number of episode for the season in the current folder
NB_EPISODES=$1
# Retrieve season number from directory
SEASON=`basename $PWD | grep -o "[0-9]*" | sed 's/^0*//'`
#SEASON=`basename $PWD | grep -o "[0-9]*"`

# Loop over episodes
for e in `seq 1 $NB_EPISODES`; do
  # Build regex for video and subtitles
  ep=`printf "%02d" $e`
  REGEX=".*${SEASON}.?.?${ep}.*\(avi\|mp4\|mkv\)"
  SUBREGEX=".*0?${SEASON}.?.?${ep}.*srt"
  echo $REGEX - $SUBREGEX

  #echo vid regex : $REGEX
  #echo sub regex : $SUBREGEX
  # Search video and sub
  VIDFILE=`find . -regex "${REGEX}" | head -n 1`
  SUBFILE=`find . -regex .*${SUBREGEX} | head -n 1`

  # Test if we found both video and sub
  if [ -f "$SUBFILE" -a -f "$VIDFILE" ]; then
    # rename sub to match video
    EXT=${VIDFILE##*.}
    mv -v "$SUBFILE" "${VIDFILE%.${EXT}}.srt"
  else
    echo video or sub does not exists for episode $ep
  fi
done
