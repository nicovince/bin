#!/bin/bash 

properties=`find . -name envConfig.lte | xargs /home/nvincent/bin/getSceProperties.py`
#echo $properties
ASIC=$1

regexp=""
first=1
rm_props=""
for p in $properties; do
  count=`find $ASIC -type f -regex ".*v\|.*vhd" | xargs grep "$p" | wc -l`
  #echo $p : $count
  if [ $count -eq 0 ]; then
    echo "$p not found"
    rm_props="$rm_props $p"
    if [ $first -eq 1 ]; then
      first=0
      regexp="$p"
    else
      regexp="$regexp\|$p"
    fi
      
  fi
done

echo $regexp
envConfig_files=`find . -name envConfig.lte`

find . -name envConfig.lte -exec grep $regexp $envConfig -H {} \;
