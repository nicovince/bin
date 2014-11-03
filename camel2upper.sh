#!/bin/bash

sed -e 's/\([A-Z]\)/_\U\1/g' -e 's/^_//' -e 's/\([a-z]\)/\U\1/g' <<< "$*"
