#!/bin/bash

MESSAGE=""
NOBOX=0

while [ $# -gt 0 ] ; do
  case $1 in 
    -pid)
      PID=$2
      shift;;
    -nobox)
      NOBOX=1
      ;;
    -msg)
      MESSAGE=$2
      shift;;
    -h|*)
      echo "usage : $0 -pid <pid> -msg \"Message to display\""
      echo "-nobox : Do not display message in a kdialog box"
      exit 1
      ;;
  esac
  shift
done

if [ -z "$MESSAGE" ]; then
  MESSAGE="$PID has finished"
fi


USERNAME=`whoami`
PID_EXISTS=`ps aux | grep -E "$USERNAME +\<$PID\>" | grep -v grep | wc -l`

if [ $PID_EXISTS -eq 0 ]; then
  echo "$PID does not exists (or has already finished)"
  exit 1
fi

while [ $PID_EXISTS -eq 1 ]; do
  sleep 1m
  PID_EXISTS=`ps aux | grep -E "$USERNAME +\<$PID\>" | grep -v grep | wc -l`
done


DATE=`date "+%d/%m -%H:%M"`
if [ $NOBOX -eq 0 ]; then
  kdialog --msgbox "$MESSAGE"
fi
