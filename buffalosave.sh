#!/bin/bash
rsync --size-only -avz /media/data/Musique/    admin@buffalo:/mnt/disk1/share/musique
#rsync --size-only -avz $HOME/Documents/images/ admin@buffalo:/mnt/disk1/share/documents/images
#rsync -avz             $HOME/Documents/misc    admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/jobs2   admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/umass   admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/CV      admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/ACSI    admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/LaTeX   admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/src     admin@buffalo:/mnt/disk1/share/documents/
#rsync -avz             $HOME/Documents/Scouts  admin@buffalo:/mnt/disk1/share/documents/
