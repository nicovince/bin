#!/bin/bash
# Functions for creating sessions with dbus in kde4, works also with gnome


. $HOME/bin/elves.sh


# format : tabname, hostname, command
konsole_env=(
     "svn.ice" "" "cd /home/nvincent/work/PI/src/iceberg/nvincent"
     "svn.tnc" "" "cd /home/nvincent/work/PI/src/titanic/nvincent"
     "pi.docs" "" "cd /home/nvincent/work/PI/docs/pi-docs/trunk/lte/pi-bb/"
     "vim.tnc" "" "cd /home/nvincent/work/PI/src/titanic/nvincent"
     "vim.ice" "" "cd /home/nvincent/work/PI/src/iceberg/nvincent"
     "run.ice" "" "cd /home/nvincent/work/PI/src/iceberg/nvincent"
     "server.nrt" "" "cd /home/nvincent/work/PI/src/iceberg/nvincent"
     "client.nrt" "" "cd /home/nvincent/work/PI/src/iceberg/nvincent"
     "build.titanic" "" "cd /home/nvincent/work/PI/src/titanic/nvincent"
     "uart.palla" "" "echo telnet pallagear 2001"
     "log.palla" "" "echo telnet 192.168.224.69 7734"
)

setup_konsole_env 2
