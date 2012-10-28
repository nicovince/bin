#!/bin/sh
konsole=$(dcopstart konsole-script)

echo "Started konsole $konsole..."
session=$(dcop $konsole konsole newSession)
echo "Created session $session..."
dcop $konsole $session renameSession Music
echo "renamed $session to Music..."
dcop $konsole $session sendSession "cd ~/Documents
"
