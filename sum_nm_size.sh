#!/bin/bash
# Adds size given by nm output : nm -C --size-sort -n file.elf > nm.out
file=$1
comput=`cat $file | awk '{print $1}' | sed 's/^0*//' | tr '[:lower:]' '[:upper:]'| sed ':a;N;$!ba;s/\n/ + /g'`
#echo $comput
echo "obase=10; ibase=16; $comput" | bc -l
