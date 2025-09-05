#!/bin/bash
## This script is used to show/hide the waybar

# check if waybar is running
if pgrep -x "waybar" > /dev/null
then
    echo "Running"
    pkill waybar
else
    echo "Stopped"
    waybar &
fi
