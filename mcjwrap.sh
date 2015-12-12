#!/bin/bash

SCREEN_NAME="mcj"
SERVER_TAB_NAME="server"
GAME=$1
# Default launch mcj
if [ "$GAME" = "" ];
then
  GAME="mcj"
fi

case $GAME in
  "mcj" )
    cmd="mcj"
    ;;
  "ragecraft" )
    cmd="cd ~/MinecraftServer/ragecraft_3; ./start.sh"
    ;;
  "creatif" )
    cmd="cd ~/MinecraftServer/Creatif; ./start.sh"
    ;;
  *)
    echo "unknown server"
    exit 1
esac
echo $cmd

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
  echo "Start Minecraft Server"
  screen -S $SCREEN_NAME -p $SERVER_TAB_NAME -X stuff "$cmd$(printf \\r)"
else
  echo "Minecraft server already running"
fi
screen -RD $SCREEN_NAME
