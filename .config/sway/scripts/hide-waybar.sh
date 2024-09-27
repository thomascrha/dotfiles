#!/bin/bash

# check if waybar is running 
if pgrep -x "waybar" > /dev/null
then
    echo "Running"
    pkill waybar 
else
    echo "Stopped"
    waybar & 
fi
