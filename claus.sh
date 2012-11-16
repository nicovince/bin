#!/bin/bash
# Functions for creating sessions with dbus in kde4

# Needs konsole to be launched with --nofork
# for create_session and create_konsole we have to pass return value through global variables
# Doing var=`create_session` does not run the qdbus command correctly
# I have no idea why...


function create_session()
{
  local konsole_id=$1
  local session_id=`qdbus $konsole_id /Konsole newSession`
  SESSION_ID=$session_id
}

function create_konsole()
{
  local basename=$(date +"%H%M%N")
  local name=$basename"_konsoleX1_"
  local kstart_options=$1
  local konsole_options=$2
  kstart $kstart_options --windowclass Konsole konsole --nofork $konsole_options -T $name  2>/dev/null
  local konsole_id=org.kde.konsole-$(ps aux | grep konsole | grep -v grep | grep $name | awk '{print $2}')
  KONSOLE_ID=$konsole_id
}

function set_title()
{
  local konsole_id=$1
  local session_id=$2
  local title=$3
  # Overwrite tab default name when on localhost
  qdbus $konsole_id /Sessions/$session_id setTabTitleFormat 0 ""
  sleep 0.1
  # Overwrite tab default name when on remote
  qdbus $konsole_id /Sessions/$session_id setTabTitleFormat 1 ""
  sleep 0.1
  # title of the tab when on localhost
  qdbus $konsole_id /Sessions/$session_id setTitle 0 "$title"
  sleep 0.1
  # title of the tab when on remote
  qdbus $konsole_id /Sessions/$session_id setTitle 1 "$title"
  sleep 0.1
}

function send_command()
{
  local konsole_id=$1
  local session_id=$2
  local command=$3
  qdbus $konsole_id /Sessions/$session_id sendText "$command"
  sleep 0.1
  qdbus $konsole_id /Sessions/$session_id sendText $'\n'
}

#####################################################################
# Wait to make sure the session count equals $1.
function wait_for_session()
{
    local konsole_id=$1
    local count=$2
    local session_count=$(qdbus $konsole_id org.kde.konsole.Konsole.sessionCount 2>/dev/null)
    while [[ $session_count -ne $count ]]
    do
        sleep 0.1
        session_count=$(qdbus $konsole_id org.kde.konsole.Konsole.sessionCount)
    done
}

function setup_konsole_env()
{
  local desktop=$1
  #konsole_id=`create_konsole "--desktop $desktop"`
  create_konsole "--desktop $desktop"
  local konsole_id=$KONSOLE_ID
  local session_count=${#konsole_env[*]}
  local i=0
  while [[ $i -lt $session_count ]]
  do
    local tabname=${konsole_env[$i]}
    let i++
    local machine=${konsole_env[$i]}
    let i++
    local command=${konsole_env[$i]}
    let i++
    create_session $konsole_id
    local session_id=$SESSION_ID
    set_title $konsole_id $session_id $tabname
    if [ -n "$machine" ]; then
      send_command "$konsole_id" "$session_id" "ssh $machine"
    fi
    send_command "$konsole_id" "$session_id" "$command"
  done

}


# format : tabname, hostname, command
konsole_env=(
     "cubalibre" "cubalibre" "echo coucou cubalibre"
     "mojito"    ""          "ls"
)

setup_konsole_env 2
