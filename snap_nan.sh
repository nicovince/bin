#!/bin/bash

DEST=/var/www/html/protect/
FILE_SUFFIX=nan
FILENAME_ORIG=$DEST/${FILE_SUFFIX}.png

fswebcam -r 1280x720 --skip 3 $FILENAME_ORIG

