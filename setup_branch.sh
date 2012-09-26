#!/bin/bash
# vim: set et sw=2:
# NOTE : konsole should be launched with "konsole --script" in order to get the sendSession function available

DEPOT_DIR=`pwd`
SUFFIX=""
while [ $# -gt 0 ] ; do
  case $1 in 
    -repo)
      DEPOT_DIR=$2
      shift;;
    -suffix)
      SUFFIX=$2
      shift;;
    -h|*)
      echo "usage : $0 -repo <path> -suffix <suffix>"
      exit 1
  esac
  shift
done

cd $DEPOT_DIR
# check we are in a database
svn info &> /dev/null
if [ $? -ne 0 ]; then
  echo $DEPOT_DIR is not a svn database
  exit 1
fi


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
# Open tabs
svn_id=`open_tab "svn$SUFFIX"`
vim_id=`open_tab "vim$SUFFIX"`
sim_id=`open_tab "sim$SUFFIX"`
confregs_id=`open_tab "config_regs$SUFFIX"`
scapa_id=`open_tab "scapa$SUFFIX"`

sleep 2

# Send command to tabs
session_cmd $svn_id       "cd $DEPOT_DIR" 
session_cmd $vim_id       "cd $DEPOT_DIR" 
session_cmd $confregs_id  "cd $DEPOT_DIR/srcv/common/config_regs" 
session_cmd $scapa_id     "cd $DEPOT_DIR/simv"
session_cmd $sim_id       "cd $DEPOT_DIR/simv" 
session_cmd $this_session "cd $DEPOT_DIR" 
dcop $kid $this_session renameSession "foo"
dcop $kid konsole activateSession $this_session
dcop $kid konsole moveSessionRight
dcop $kid konsole moveSessionRight
dcop $kid konsole moveSessionRight
dcop $kid konsole moveSessionRight
