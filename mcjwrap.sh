#!/bin/bash

date
NB=`screen -ls | grep -c mcj`
# Does an existing screen session exist
if [ $NB -eq 1 ]; then
  screen -RD mcj
else
  screen -S mcj -c ~/configrc/cosmopolitan.mcj.screenrc
fi

date

