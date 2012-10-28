#!/bin/bash
VIDEO="$@"
OUT_VIDEO=${VIDEO/wmv/avi}
OUT_VIDEO=${OUT_VIDEO/ /_}
VIDEO=${VIDEO/ /\\ }
echo mencoder $VIDEO -ofps 23.976 -ovc lavc -oac copy -o $OUT_VIDEO
