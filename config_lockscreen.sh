#!/bin/bash

CONFIG_FILE=$HOME/.config/kscreenlockerrc

enabled=""
case "$1" in
  'on')  enabled='true'  ;;
  'off') enabled='false' ;;
esac
if [ -z "${enabled}" -o "$#" -ne 1 ]; then
  echo "Usage: $0 { on | off }"
  exit 1
fi
#sed -ni "/Autolock=.*/!{s/\[Daemon]/[Daemon]\nAutolock=${enabled}/;p}" ~/.config/kscreenlockerrc
awk -i inplace 'function p(){set=1;print "[Daemon]\nAutolock='${enabled}'"}
/\[Daemon]/{p();next}
/Autolock.*/{next}
{print}
ENDFILE{if(!set){print "";p()}}' $CONFIG_FILE
qdbus org.freedesktop.ScreenSaver /ScreenSaver configure
