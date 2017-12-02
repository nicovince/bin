#!/bin/bash

DEST=/home/pi/Documents/botanic
FILE_SUFFIX=tomatoes_`date +%F-%R`
FILENAME_ORIG=$DEST/${FILE_SUFFIX}.jpg
FILENAME_CROPPED=$DEST/${FILE_SUFFIX}_cropped.jpg

DST_LINK=/var/www/html/latest.png
DST_LINK_ORIG=/var/www/html/latest_orig.png

fswebcam --no-banner -r 1280x720 --skip 3 $FILENAME_ORIG
#convert $FILENAME_ORIG -crop 650x553+263+0 $FILENAME_CROPPED

rm -f $DST_LINK
rm -f $DST_LINK_ORIG
#ln -s $FILENAME_CROPPED $DST_LINK
ln -s $FILENAME_ORIG $DST_LINK_ORIG

