#!/bin/bash

SCREEN_NAME="mcj"
SERVER_TAB_NAME="server"
NB=`screen -ls | grep -c mcj`
# Does an existing screen session exist
if [ $NB -eq 0 ]; then
  # No, let's create one in detached mode
  echo "Creating Screen session to host minecraft server"
  screen -d -m -S $SCREEN_NAME -c ~/configrc/cosmopolitan.mcj.screenrc
fi

# Is minecraft server already running
MC_RUNNING=`ps aux | grep minecraft_server | grep -c java`
if [ $MC_RUNNING -ne 1 ]; then
  # No, let's create a new one
  echo screen -S $SCREEN_NAME -p $SERVER_TAB_NAME -X stuff "mcj$(printf \\r)"
else
  echo "Minecraft server already running"
fi
