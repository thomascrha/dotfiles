#!/bin/bash
## This script is used to show/hide the dropdown terminal
## in sway window manager. It uses swaymsg to communicate
## with the sway IPC.
## Requires: sway, swaymsg, jq, wezterm, bc

DEFAULT_HEIGHT=70
MAX_HEIGHT=${GUAKE_MAX_HEIGHT:-972}
MAX_WIDTH=${GUAKE_MAX_WIDTH:-1802}

HEIGHT=$(swaymsg -t get_tree | jq -r '.. | select(.app_id? == "dropdown-terminal") | .window_rect | "\(.height)"')

# CURRENT_WIDTH_PPT=$((100 * $WIDTH / $MAX_WIDTH))
CURRENT_HEIGHT_PPT=$(echo "($HEIGHT * 100 + $MAX_HEIGHT - 1) / $MAX_HEIGHT" | bc)
echo $CURRENT_HEIGHT_PPT

if [[ -f /tmp/guake_size ]]; then
    # WIDTH_PPT=$(cat /tmp/guake_size | cut -d' ' -f1)
    HEIGHT_PPT=$(cat /tmp/guake_size | cut -d' ' -f2)
else
    # WIDTH_PPT=100
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $CURRENT_HEIGHT_PPT -lt 20 ]]; then
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $CURRENT_HEIGHT_PPT -gt 100 ]]; then
    HEIGHT_PPT=100
fi

# write the current values to a file
echo "$CURRENT_WIDTH_PPT $CURRENT_HEIGHT_PPT" > /tmp/guake_size

/usr/bin/swaymsg '[app_id="dropdown-terminal"] scratchpad show' || \
    WEZTERM_GUAKE=on /usr/bin/wezterm start --class dropdown-terminal

/usr/bin/swaymsg "[app_id=\"dropdown-terminal\"] resize set 100ppt ${HEIGHT_PPT}ppt, move position 0 0"

