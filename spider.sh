#!/bin/bash
#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
#for i in $(qstat -f | grep -v "\-NA" | grep "all.q" | awk '{ print $1 }' | cut -d"@" -f2 | cut -d"." -f1) ; do echo $i ; qrsh -l hostname=$i.fr.sequans.com -N "test-$i" uname -a; which talisker ; done 
## Using ssh
for i in $(qstat -f | grep -v "\-NA" | grep ".q" | awk '{ print $1 }' | cut -d"@" -f2 | cut -d"." -f1) ; do echo $i ; ssh -X -2 -C -Y $i "hostname ; ls /cad"; echo ===========; done 

## Using grid engine
#for i in $(qstat -f | grep -v "\-NA" | grep ".q" | awk '{ print $1 }' | cut -d"@" -f2 | cut -d"." -f1) ; do echo $i ; qrsh -l hostname=$i.fr.sequans.com -N "test-$i" uname -a ; done
#for i in $(qstat -f | grep -v "\-NA" | grep ".q" | awk '{ print $1 }' | cut -d"@" -f2 | cut -d"." -f1) ; do echo $i ; qrsh -l hostname=$i.fr.sequans.com -N "test-$i" ls /cad ; done
