#!/bin/bash
# Ban ip who repeatedely try to connect and fail
# used when iptables is not available to do the job. (buffalo linkstation)

# expected pattern in /var/log/messages
#May  9 00:00:08 CUBALIBRE sshd[31151]: Failed password for root from 137.236.230.35 port 41416 ssh2
#May  8 04:32:52 CUBALIBRE sshd[25624]: Failed password for invalid user user from 198.71.54.97 port 53032 ssh2

LOG_FILE=/var/log/messages
# retrieve list of ip present in /var/log/messages
ip_list=`cat $LOG_FILE | grep "Failed password" | grep "\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}" -o | sort | uniq`
for ip in $ip_list; do
  # if number of occurence is too big, ban them
  nb_occurences=`cat $LOG_FILE | grep "Failed password" | grep $ip -c`
  if [ $nb_occurences -ge 10 ]; then
    banned=`ip route list | grep "prohibit $ip" -c`
    if [ $banned -eq 0 ]; then
      ip route add prohibit $ip/32
    fi
  fi
done

