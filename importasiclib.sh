#!/bin/bash


# parse args
while [ $# -gt 0 ] ; do
  case $1 in 
    -path)
      ASICLIBPATH=$2
      shift;;
    -dest)
      DEST=$2
      shift;;
    -h|*)
      echo "usage : $0 -path /path/to/asiclib/ -dest /destination/path"
      exit 1
      ;;
  esac
  shift
done

ASICLIB="asiclib"
ASICLIBPATH=${ASICLIBPATH:-./srcv/common/asiclib}
DEST=${DEST:-${HOME}/work/SQN3210_product}/${ASICLIB}

rm -Rf ${DEST}
mkdir -p ${DEST}

cp -r --parents ${ASICLIBPATH} ${DEST}
cd ${DEST}/${ASICLIBPATH}
chmod -x *
