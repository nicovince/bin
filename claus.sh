#!/bin/bash
# Functions for creating sessions with dbus in kde4

# Needs konsole to be launched with --nofork

. $HOME/bin/elves.sh


# format : tabname, hostname, command
konsole_env=(
     "cubalibre.vim" "cubalibre" "cd dev"
     "cubalibre.dev" "cubalibre" "cd dev"
     "cubalibre.screen" "cubalibre" "screen -RD"
     "mojito"    ""          ""
)

setup_konsole_env 1
