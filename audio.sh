#!/bin/bash


if [ $# -lt 1 ]; then
  echo "missing interface"
  echo "$0 <hdmi|jack>"
  exit 1
fi
INTERFACE=$1
if [ $INTERFACE == "hdmi" ]; then
  INTERFACE_ID=2
elif [ $INTERFACE == "jack" ]; then
  INTERFACE_ID=1
else
  echo "wrong interface"
  echo "$0 <hdmi|jack>"
  exit 1
fi
  
echo amixer cset numid=3 $INTERFACE_ID
