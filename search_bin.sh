#!/bin/bash
# Search hexadecimal pattern in binary file
# xxd split the binary file in group of 4 bytes, with 16 bytes per line
# Usage :
# search_bin.sh <pattern> <binary file>
pattern=$1
file=$2
xxd -c 16 -g 4 $file | grep -i $pattern
