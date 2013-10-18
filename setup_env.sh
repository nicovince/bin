#!/bin/bash
# vim: set et sw=2:
# NOTE : konsole should be launched with "konsole --script" in order to get the sendSession function available
SIM_DIR=`pwd`
SUFFIX=""
CLEARHIST=0
while [ $# -gt 0 ] ; do
  case $1 in 
    -sim)
      SIM_DIR=$2
      shift;;
    -suffix)
      SUFFIX=$2
      shift;;
    -clear)
      CLEARHIST=1
      ;;
    -h|*)
      echo "usage : $0 -sim <path> -suffix <suffix> -clear"
      exit 1
  esac
  shift
done

# Open a new tab and set it's name
open_tab()
{
  local l_name=$1
  local l_session=`dcop $kid konsole newSession`
  dcop $kid $l_session renameSession "$l_name"
  echo $l_session
}

open_tab_cmd()
{
  local l_name=$1
  local l_cmd=$2
  local l_session=`open_tab "$l_name"`
  sleep 1
  dcop $kid $l_session sendSession "$l_cmd"
}

session_cmd()
{
  local l_session=$1
  local l_cmd=$2
  dcop $kid $l_session sendSession "$l_cmd"
}

kid=`echo $KONSOLE_DCOP | sed 's/DCOPRef(\(.*\),.*/\1/'`
this_session=`echo $KONSOLE_DCOP_SESSION | sed 's/.*,\(.*\))/\1/'`
dcop $kid $this_session renameSession "envC"
swenv_id=`open_tab "swenv"`
dcop $kid konsole activateSession $this_session

GITDIR="~/work/ENV/git"
ENVC_DIR="$GITDIR/envC/"
SWENV_DIR="$GITDIR/swenv/"
session_cmd $this_session  "cd $ENVC_DIR"
session_cmd $swenv_id      "cd $SWENV_DIR"

