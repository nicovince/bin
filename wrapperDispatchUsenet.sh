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
BON_TEMPS="/home/admin/dev/Bon_Temps"
CONFIG_FILE="${BON_TEMPS}/test/config.xml"
JESSICA="${BON_TEMPS}/src/jessica.py --logFile BonTempsJessica.log --config $CONFIG_FILE"
echo "$JESSICA --type $typeOpt \
                   --archiveName $archiveNameOpt \
                   --destDir $destDirOpt \
                   --elapsedTime $elapsedTimeOpt \
                   --parMessage $parMessageOpt" >> ~/dbgWrapper.log
$JESSICA --type $typeOpt \
                   --archiveName "$archiveNameOpt" \
                   --destDir "$destDirOpt" \
                   --elapsedTime "$elapsedTimeOpt" \
                   --parMessage "$parMessageOpt"
