#!/bin/bash
FILE=$1
BOOKLET="booklet_${FILE}"
#https://bugs.kde.org/show_bug.cgi?id=179468
#pdftops -level3 $FILE - | psbook | psnup -2 -pa4 | ps2pdf - ${BOOKLET}
# 
pdftops -level3 $FILE - | psbook | psnup -2 -pa4 | ps2pdf - ${BOOKLET}
