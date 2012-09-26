#!/bin/sed -f
# remove trailing comments
/\w\s*\/\//s#\s*//.*##
# realign comments left
s#^\(\s*\)\(//.*\)#\1\1\2#
# port map
s/^\(\s*\).*\<\(\w\+\)\>\s*,.*/\1\1.\2(\2),/
