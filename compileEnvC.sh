#!/bin/bash
# envC compilation

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

if [ "$VERTOOLS" != "" ]
then
  export VERTOOLS="default"
fi
export RELTOOLS="latest"
if [ -e /delivery/tools_env/$RELTOOLS/source_tools.sh ]
then
  source /delivery/tools_env/$RELTOOLS/source_tools.sh
fi

source /delivery/tools_env/$RELTOOLS/source_tools.sh gcc64_ccss2009_ius92_bash
echo $VERTOOLS

if [ -n "$lib" ]; then
  ./scripts/compileEnvC VERLIB $lib VCS LTE
  error=$?
  if [ $error -eq 0 ]; then
    ./scripts/compileEnvC VERLIB $lib LTE
    error=$?
  fi
  if [ $error -eq 0 ] && [ $compile_64 -eq 1 ]; then
    ./scripts/compileEnvC VERLIB $lib LTE 64
    error=$?
  fi
else
  echo "No lib specified"
fi

DATE=`date "+%d/%m -%H:%M"`
if [ $error -eq 1 ]; then
  kdialog --error "$DATE envC : compilation error" &> /dev/null
else
  kdialog --msgbox "$DATE envC : compilation done" &> /dev/null
fi
