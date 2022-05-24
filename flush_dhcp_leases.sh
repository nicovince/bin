#!/bin/bash

NET_IF=${1:-eno1}
DNSMASK_FILE="/var/lib/NetworkManager/dnsmasq-${NET_IF}.leases"

if [ ! -f ${DNSMASK_FILE} ]; then
    echo "${DNSMASK_FILE} does not exist, specify interface name."
    exit 1
fi
cat ${DNSMASK_FILE} | cut -d ' ' -f"3 2" | awk '{print $2 " " $1}' | while read line; do
    ip=$(echo "${line}" | cut -d' ' -f 1)
    mac=$(echo "${line}" | cut -d' ' -f 2)
    dhcp_release ${NET_IF} $ip $mac "*"
done
