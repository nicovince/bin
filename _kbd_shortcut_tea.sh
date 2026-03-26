#!/bin/bash
# Setup shortkey in
# System Settings > Shortcuts > Custom Shortcuts > Edit > New > Global Shortcut > Command/URL
# Trigger Tab: select the key on which the shortcut must be mapped
# Action Tab: enter the path to this script
notify-send -t 2000 "Tea will be ready in a while" -i kteatime
echo "notify-send -t 2000 \"Tea is ready\" -u critical -i kteatime" | at now +6 minutes
