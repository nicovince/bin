#!/bin/bash
grep "sleep mode, not idle mode" *
file=`grep "sleep mode, not idle mode" * -l`
if [ $? -eq 0 ]; then
  echo "sed '/sleep mode, not idle mode/d' -i $file"
fi
