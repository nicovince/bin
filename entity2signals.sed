#!/bin/sed -f
s/\(^\s*\)\(\w\+\s*\):\s*\(\w\+\)\>/\1 signal \2 :/
