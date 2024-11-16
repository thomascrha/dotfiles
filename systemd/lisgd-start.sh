#!/bin/bash

TOUCHSCREEN=/dev/input/event5

lisgd -d $TOUCHSCREEN \
    -g "2,DRUL,*,*,R,pactl set-sink-volume @DEFAULT_SINK@ +10%" \
    -g "2,URDL,*,*,R,pactl set-sink-volume @DEFAULT_SINK@ -10%" \
    -g "3,LR,*,*,R,swaymsg layout tabbed" \
    -g "3,RL,*,*,R,swaymsg layout stacking" \
    -g "3,UD,*,*,R,swaymsg layout toggle split" \
    -g "3,DU,*,*,R,nwggrid" \
    -g "4,LR,*,*,R,swaymsg workspace next" \
    -g "4,RL,*,*,R,swaymsg workspace prev" \
    -g "4,DU,*,*,R,pactl set-sink-volume @DEFAULT_SINK@ 0%" \
    -g "4,UD,*,*,R,swaymsg kill"
