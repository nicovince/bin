#!/bin/bash

#args['type']        = sys.argv[1]
#args['archiveName'] = sys.argv[2]
#args['destDir']     = sys.argv[3]
#args['elapsedTime'] = sys.argv[4]
#args['parMessage']  = sys.argv[5]

type=$1
archiveName=$2
destDir=$3
elapstedTime=$4
parMessage=$5

dispatch_usenet.py $type $archiveName $destDir $elapsedTime $parMessage
