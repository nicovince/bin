#!/bin/bash

#args['type']        = sys.argv[1]
#args['archiveName'] = sys.argv[2]
#args['destDir']     = sys.argv[3]
#args['elapsedTime'] = sys.argv[4]
#args['parMessage']  = sys.argv[5]

typeOpt=$1
archiveNameOpt=$2
destDirOpt=$3
elapstedTimeOpt=$4
parMessageOpt=$5

dispatch_usenet.py --type $typeOpt \
                   --archiveName $archiveNameOpt \
                   --destDir $destDirOpt \
                   --elapsedTime $elapsedTimeOpt \
                   --parMessage $parMessageOpt
