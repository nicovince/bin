#!/bin/bash


# Number of episode for the season in the current folder
NB_EPISODES=$1
# Retrieve season number from directory
SEASON=`basename $PWD | grep -o "[0-9]*"`

# Loop over episodes
for e in `seq 1 $NB_EPISODES`; do
  # Build regex for video and subtitles
  ep=`printf "%02d" $e`
  REGEX=".*${SEASON}.*${ep}.*\(avi\|mp4\)"
  SUBREGEX=".*${SEASON}.*${ep}.*srt"

  #echo vid regex : $REGEX
  #echo sub regex : $SUBREGEX
  # Search video and sub
  VIDFILE=`find . -regex "${REGEX}" | head -n 1`
  SUBFILE=`find . -regex .*${SUBREGEX} | head -n 1`

  # Test if we found both video and sub
  if [ -f "$SUBFILE" -a -f "$VIDFILE" ]; then
    # rename sub to match video
    mv -v "$SUBFILE" "${VIDFILE%.mp4}.srt"
  else
    echo video or sub does not exists for episode $ep
  fi
done
