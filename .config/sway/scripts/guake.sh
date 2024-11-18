#!/bin/bash
## This script is used to show/hide the dropdown terminal
## in sway window manager. It uses swaymsg to communicate
## with the sway IPC.
## Requires: sway, swaymsg, jq, wezterm, bc

DEFAULT_HEIGHT=70
if [[ ! -f /tmp/guake_size ]]; then
    echo $DEFAULT_HEIGHT > /tmp/guake_size
fi

GAPS_AND_BORDERS=50
MAX_HEIGHT=$(echo "($(swaymsg -t get_outputs | jq '.[] | select(.focused == true) | .rect | .height') - $GAPS_AND_BORDERS)" | bc)

echo "MAX_HEIGHT: $MAX_HEIGHT"

HEIGHT=$(swaymsg -t get_tree | jq -r '.. | select(.app_id? == "dropdown-terminal") | .window_rect | "\(.height)"' || $(cat /tmp/guake_size))

CURRENT_HEIGHT_PPT=$(echo "($HEIGHT * 100 + $MAX_HEIGHT - 1) / $MAX_HEIGHT" | bc)

HEIGHT_PPT=$(cat /tmp/guake_size)
echo "HEIGHT_PPT: $HEIGHT_PPT"

if [[ $HEIGHT_PPT -lt 20 ]]; then
# get the old height
if [[ -f /tmp/guake_size ]]; then
    # WIDTH_PPT=$(cat /tmp/guake_size | cut -d' ' -f1)
    HEIGHT_PPT=$(cat /tmp/guake_size)
else
    
# do some validation
if [[ $HEIGHT_PPT -lt 5 ]]; then
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $HEIGHT_PPT -gt 100 ]]; then
    HEIGHT_PPT=100
fi

if [[ ! -z $CURRENT_HEIGHT_PPT ]]; then
    echo $CURRENT_HEIGHT_PPT > /tmp/guake_size
fi

echo "$CURRENT_WIDTH_PPT $CURRENT_HEIGHT_PPT" > /tmp/guake_size

/usr/bin/swaymsg '[app_id="dropdown-terminal"] scratchpad show'

# wezterm is not running inside the dropdown-terminal scratchpad
if [[ $(echo $?) -ne 0 ]]; then
    WEZTERM_GUAKE=on /usr/bin/wezterm start --class dropdown-terminal & 
    sleep 0.4
fi

/usr/bin/swaymsg "[app_id=\"dropdown-terminal\"] resize set 100ppt ${HEIGHT_PPT}ppt, move position 0 0"

