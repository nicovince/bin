#!/bin/bash
file="$@"

convert -rotate 180 $file $file.tmp
mv $file.tmp $file
