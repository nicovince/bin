#!/bin/bash
[ $# -eq 2 ] && arg=$1 || arg="" 
eval file="\$$#" 
sed 's/a/aA/g;s/__/aB/g;s/b/bA/g;s/#/bB/g' "$file" | 
          gcc -P -E $arg - | 
          sed 's/bB/#/g;s/bA/b/g;s/aB/__/g;s/aA/a/g'

