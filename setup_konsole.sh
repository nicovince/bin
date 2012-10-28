#!/bin/bash
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

kid=`echo $KONSOLE_DCOP | sed 's/DCOPRef(\(.*\),.*/\1/'`
this_session=$KONSOLE_DCOP_SESSION


#open_tab_cmd "frc" "echo frc"
#open_tab_cmd "frc-sim" "echo frc-simulation konsole"
frc_id=`open_tab "frc"`
frc_sim_id=`open_tab "frc-sim"`

sleep 1
dcop $kid $frc_id sendSession "echo frc"
dcop $kid $frc_sim_id sendSession "echo simulation for frc"
