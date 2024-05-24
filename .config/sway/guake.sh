#!/bin/bash

# check is wezterm is running
if [[ ! $(ps aux | grep terminal_scratchpad | grep -v grep) ]]; then
    echo "Starting wezterm"
    WEZTERM_GUAKE=on wezterm start --class terminal_scratchpad
fi
# run sway scratchpad toggle
swaymsg [app_id="terminal_scratchpad"] scratchpad show
