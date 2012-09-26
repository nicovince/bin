#!/bin/bash


DEPOT_DIR=`pwd`
while [ $# -gt 0 ] ; do
  case $1 in 
    -repo)
    DEPOT_DIR=$2
    shift;;
    -h|*)
    echo "usage : $0 -repo <path>"
    exit 1
  esac
  shift
done

SVN_EXCLUDE="--exclude=\"\.svn\""
TILDE_EXCLUDE="--exclude=\"~\""
#SIMU_EXCLUDE="--exclude=\"simv\""
SYNTH_EXCLUDE="--exclude=\"synth\""
TAGS_EXCLUDE="--exclude=\"tags\""
VERILOG_OPTION="--verilog-kinds=-np --langmap=verilog:.v.sv"
CPP_OPTION="--langmap=c++:.cc.cpp.h"
EXCLUDES="$SVN_EXCLUDE $TILDE_EXCLUDE $SIMU_EXCLUDE $SYNTH_EXCLUDE $TAGS_EXCLUDE "
SV_PARSER="--langdef=systemverilog"
SV_PARSER="$SV_PARSER --langmap=systemverilog:.sv.svh.svi"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*(virtual)?[ \t]*class[ \t]*([a-zA-Z_0-9]+)/\2/c,class/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*(virtual)?[ \t]*task[ \t]*.*[ \t]+([a-zA-Z_0-9]+)[\t]*[(;]/\2/t,task/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*(virtual)?[ \t]*function[ \t]*.*[ \t]+([a-zA-Z_0-9]+)[ \t]*[(;]/\2/f,function/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*module[ \t]*([a-zA-Z_0-9]+)/\1/m,module/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*program[ \t]*([a-zA-Z_0-9]+)/\1/p,program/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*interface[ \t]*([a-zA-Z_0-9]+)/\1/i,interface/"
SV_PARSER="$SV_PARSER --regex-systemverilog=/^[ \t]*typedef[ \t]+.*[ \t]+([a-zA-Z_0-9]+)[ \t]*;/\1/e,typedef/"
SV_PARSER="$SV_PARSER --systemverilog-kinds=+ctfmpie"

if [ ! -d "$DEPOT_DIR" ]; then
  echo DEPOT_DIR should be defined
  exit
fi 

cd $DEPOT_DIR

cmd="ctags-svn --links=no --recurse $EXCLUDES --languages=vhdl,verilog,c++ $VERILOG_OPTION $CPP_OPTION"
echo $cmd
eval $cmd

