#!/bin/bash

DEFAULT_HEIGHT=70
MAX_HEIGHT=${GUAKE_MAX_HEIGHT:-970}
MAX_WIDTH=${GUAKE_MAX_WIDTH:-1800}
# get the current size of the dropdown terminal window
# WIDTH=$(swaymsg -t get_tree | jq -r '.. | select(.app_id? == "dropdown-terminal") | .window_rect | "\(.width)"')
HEIGHT=$(swaymsg -t get_tree | jq -r '.. | select(.app_id? == "dropdown-terminal") | .window_rect | "\(.height)"')

# CURRENT_WIDTH_PPT=$((100 * $WIDTH / $MAX_WIDTH))
CURRENT_HEIGHT_PPT=$((100 * $HEIGHT / $MAX_HEIGHT))

# fetch the old values of the dropdown terminal window - if don't exist use the values given by the window as
# sway aplys some default values to the window

if [[ -f /tmp/guake_size ]]; then
    # WIDTH_PPT=$(cat /tmp/guake_size | cut -d' ' -f1)
    HEIGHT_PPT=$(cat /tmp/guake_size | cut -d' ' -f2)
else
    # WIDTH_PPT=100
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

if [[ $CURRENT_HEIGHT_PPT -lt 10 ]]; then
    HEIGHT_PPT=$DEFAULT_HEIGHT
fi

# write the current values to a file
echo "$CURRENT_WIDTH_PPT $CURRENT_HEIGHT_PPT" > /tmp/guake_size

/usr/bin/swaymsg '[app_id="dropdown-terminal"] scratchpad show' || \
    WEZTERM_GUAKE=on /usr/bin/wezterm start --class dropdown-terminal

/usr/bin/swaymsg "[app_id=\"dropdown-terminal\"] resize set 100ppt ${HEIGHT_PPT}ppt, move position 0 0"



#
# show existing or start new dropdown terminal
# bindsym Ctrl+Grave exec swaymsg '[app_id="$ddterm-id"] scratchpad show' \
  # || $ddterm && swaymsg '[app_id="$ddterm-id"] $ddterm-resize'
# swaymsg '[app_id="dropdown-terminal"]'
# set $ddterm-id dropdown-terminal
# set $ddterm WEZTERM_GUAKE=on $terminal start --class $ddterm-id
# set $ddterm-resize resize set 100ppt 100ppt, move position 0 0
#
# # resize/move new dropdown terminal windows
# for_window [app_id="$ddterm-id"] {
#   floating enable
#   $ddterm-resize
#   move to scratchpad
#   scratchpad show
# }

