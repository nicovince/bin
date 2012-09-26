#!/bin/bash

file=$1

filename=`basename $file`

modulename=${filename%.v}

grep $filename /home/nvincent/work/SQN3110/srcv/tops/wimax_top/wimax_srcv/ss/tops/ss_mac_platform_fpga/file_list_parsed > /dev/null
if [ $? -ne 0 ]; then
  #find . -regex ".*v\|.*vhd" | grep -v "./simv" | xargs grep -n -E "\<$modulename\>" > /dev/null
  #ret=${PIPESTATUS[2]}
  #if [ $ret -ne 0 ]; then
  #  echo "// NV : This module does not seem to be instanciated in wimax_srcv"
  #fi
  echo $file
fi



