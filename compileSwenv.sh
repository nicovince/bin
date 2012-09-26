#!/bin/bash
# swenv Compilation

compile_64=0
while [ $# -gt 0 ] ; do
  case $1 in
    -lib)
      lib=$2
      shift;;
    -64)
      compile_64=1
      ;;
  esac
  shift
done
error=0

#if [ "$VERTOOLS" != "" ]
#then
#  export VERTOOLS="default"
#fi
#export RELTOOLS="latest"
#if [ -e /delivery/tools_env/$RELTOOLS/source_tools.sh ]
#then
#  source /delivery/tools_env/$RELTOOLS/source_tools.sh
#fi
#
#source /delivery/tools_env/$RELTOOLS/source_tools.sh gcc64_ccss2009_ius92
#echo $VERTOOLS


if [ -n "$lib" ]; then
  ./scripts/compileSwenv VERLIB $lib VCS LTE && ./scripts/compileLabo VERLIB $lib clean VCS LTE && ./scripts/compileLabo VERLIB $lib VCS LTE
  error=$?
  if [ $error -eq 0 ]; then
    ./scripts/compileSwenv VERLIB $lib LTE && ./scripts/compileLabo VERLIB $lib LTE
  error=$?
  fi

  # compile in 64 bit
  if [ $error -eq 0 ] && [ $compile_64 -eq 1 ]; then
    ./scripts/compileSwenv VERLIB $lib LTE 64
    error=$?
  fi

else
  kdialog --error "swenv : No lib specified" &> /dev/null
  exit 1
fi

DATE=`date "+%d/%m -%H:%M"`
if [ $error -eq 1 ]; then
  kdialog --error "$DATE swenv : compilation error" &> /dev/null
else
  kdialog --msgbox "$DATE swenv : compilation done" &> /dev/null
fi
