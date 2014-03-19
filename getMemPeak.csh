#!/usr/bin/env bash
pid=$1
cmd="$(ps -p $1 -o comm=)"

echo "getMemPeak - now monitoring PID $pid for command $cmd"
echo
echo "type enter to exit before end of process"
echo

while ps $pid >/dev/null
do
    sample="$(ps -o vsz= ${pid})"
    let peak='sample > peak ? sample : peak'
    read -t 30 && break
    echo -n "."
done 
echo "Peak: $peak" 
