#!/bin/bash

print_help()
{
  echo "Usage : $0 option"
  echo "Valid options are : "
  echo "  drink : to get latest data from buffalo bartender"
  echo "  serve : to send latest local data to buffalo bartender"
}

send_data()
{
  direction=$1
  folder_local=$2
  folder_remote=$3

  echo $direction
  if [ $direction = "poor" ]; then
    echo rsync -avz --exclude *~ --progress ${folder_local} admin@buffalo:${folder_remote}
  elif [ $direction = "serve" ]; then
    echo rsync -avz --exclude *~ --progress admin@buffalo:${folder_remote} ${folder_local}
  else
    echo "invalid option $direction"
    exit 1;
  fi
}


if [ -z $1 ]; then
  print_help
  exit
fi

direction=$1
folders="$HOME/Documents/fichiers $HOME/Documents/misc"
lounge=/mnt/disk1/share/cocktails
misc=( $HOME/Documents/fichiers/misc $lounge/misc )

send_data $direction ${misc[0]} ${misc[1]}
#for i in $folders; do
#  echo rsync -avz --exclude *~ --progress $i admin@buffalo:$lounge
#done



