#!/bin/bash
# define the BUFFALOWAKEUP used among buffalo scripts
. $HOME/.buffalorc
# create the file so cron job will send wol commands
touch $BUFFALOWAKEUP
$HOME/bin/buffalocron.sh
