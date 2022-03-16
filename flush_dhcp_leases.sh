#!/bin/bash

cat /var/lib/NetworkManager/dnsmasq-eno1.leases | cut -d ' ' -f"3 2" | awk '{print $2 " " $1}' | while read line; do
    ip=$(echo "${line}" | cut -d' ' -f 1)
    mac=$(echo "${line}" | cut -d' ' -f 2)
    dhcp_release eno1 $ip $mac "*"
done
