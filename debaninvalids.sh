#!/bin/bash
# deban ip which have been banned by baninvalids.sh and which no longer appear in current /var/log/messages
ip_list=`ip route list | grep "prohibit" | grep "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" -o | sort | uniq`

LOG_FILE=/var/log/messages
for ip in $ip_list; do
  nb_occurences=`cat $LOG_FILE | grep "Failed password" | grep $ip -c`
  if [ $nb_occurences -lt 5 ]; then
    ip route delete $ip
  fi
done
