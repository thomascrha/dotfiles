#!/bin/bash
## This script is used to show/hide the waybar

# check if waybar is running via systemctl
if systemctl --user is-active --quiet waybar; then
    # If waybar is running, stop it
    systemctl --user stop waybar
else
    # If waybar is not running, start it
    systemctl --user start waybar
fi
