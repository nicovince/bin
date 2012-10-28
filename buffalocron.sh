#!/bin/bash
# define the BUFFALOWAKEUP used among buffalo scripts
. $HOME/.buffalorc
# if the following file exists sends a wakeonlan command to buffalo device to
# keep it alive
if [ -f $BUFFALOWAKEUP ]; then
  wakeonlan 00:1D:73:A4:4D:4C
fi
