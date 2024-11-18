#!/bin/bash
## This script is used to show/hide the dropdown terminal
## in sway window manager. It uses swaymsg to communicate
## with the sway IPC.
## Requires: sway, swaymsg, jq, wezterm, bc


DEFAULT_HEIGHT=70
GAPS_AND_BORDERS=50
MAX_HEIGHT=$(echo "($(swaymsg -t get_outputs | jq '.[] | select(.focused == true) | .rect | .height') - $GAPS_AND_BORDERS)" | bc)

echo "MAX_HEIGHT: $MAX_HEIGHT"

HEIGHT=$(swaymsg -t get_tree | jq -r '.. | select(.app_id? == "dropdown-terminal") | .window_rect | "\(.height)"')

CURRENT_HEIGHT_PPT=$(echo "($HEIGHT * 100 + $MAX_HEIGHT - 1) / $MAX_HEIGHT" | bc)

if [[ -f /tmp/guake_size ]]; then
    # WIDTH_PPT=$(cat /tmp/guake_size | cut -d' ' -f1)
    HEIGHT_PPT=$(cat /tmp/guake_size)
else
    # WIDTH_PPT=100
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $HEIGHT_PPT -lt 20 ]]; then
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $HEIGHT_PPT -gt 100 ]]; then
    HEIGHT_PPT=100
fi

echo $CURRENT_HEIGHT_PPT > /tmp/guake_size

/usr/bin/swaymsg '[app_id="dropdown-terminal"] scratchpad show' || \
    WEZTERM_GUAKE=on /usr/bin/wezterm start --class dropdown-terminal

/usr/bin/swaymsg "[app_id=\"dropdown-terminal\"] resize set 100ppt ${HEIGHT_PPT}ppt, move position 0 0"

