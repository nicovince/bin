#!/bin/bash

# takes as argument a torrent file and sends it to the watch folder of the buffalo
# rtorrent should be started on the buffalo

scp "$1" admin@buffalo:/mnt/disk1/share/torrents/watch
