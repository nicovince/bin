#!/bin/bash
#type        : post processing result, either 'SUCCESS' or 'ERROR'
#archiveName : name of the archive, e.g. 'Usenet_Post5'
#destDir     : where the archive ended up, e.g. '/ext2/usenet/Usenet_Post5'
#elapsedTime : a pretty string showing how long post processing took, e.g.
#             '10m 37s'
#parMessage  : optional post processing message. e.g. '(No Pars)'

typeOpt=$1
archiveNameOpt=$2
destDirOpt=$3
elapsedTimeOpt=$4
parMessageOpt=$5

echo "dispatch_usenet.py --type $typeOpt \
                   --archiveName $archiveNameOpt \
                   --destDir $destDirOpt \
                   --elapsedTime $elapsedTimeOpt \
                   --parMessage $parMessageOpt" >> ~/dbgWrapper.log
dispatch_usenet.py --type $typeOpt \
                   --archiveName $archiveNameOpt \
                   --destDir $destDirOpt \
                   --elapsedTime $elapsedTimeOpt \
                   --parMessage $parMessageOpt
