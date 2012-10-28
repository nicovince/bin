#!/bin/bash
# define the BUFFALOWAKEUP used among buffalo scripts
. $HOME/.buffalorc
# remove it to stop cron from sending wakeonlan commands
rm -f $BUFFALOWAKEUP
