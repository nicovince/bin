#!/bin/bash
# Search indefinitely for a pattern in 'ps aux' output, and show the matching result and exit
pattern="$1"
myself=$(basename "$0")
while true; do 
    result=$(ps aux | grep "$pattern" | grep -v grep | grep -v "$myself")
    if [ -n "$result" ]; then
        echo "$result"
        exit 0
    fi
    sleep 0.4
done
