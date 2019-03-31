#!/bin/bash

ARCHIVE=$HOME/Documents/backups/taskd.tar.gz
TMP_ARCHIVE=$(sudo -u Debian-taskd mktemp)
cd /var/lib/
sudo -u Debian-taskd tar czf ${TMP_ARCHIVE} taskd
sudo chown ${USER}:${USER} ${TMP_ARCHIVE}
mv ${TMP_ARCHIVE} ${ARCHIVE}

