#!/bin/bash -e
DELIV_FOLDER=$1

folder=`basename $DELIV_FOLDER`
archive="palladium_${folder}.tar.gz"
delivery=${DELIV_FOLDER}/${archive}
echo tar czf $delivery QTDB PDB dbFiles cellList
