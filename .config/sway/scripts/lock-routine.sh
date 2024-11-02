#!/bin/bash

running_apps=$(pgrep -fc "swaylock-effects")
if [ "$running_apps" = 0 ]; then
    LT="$lock_timeout" ST="$screen_timeout" LT=${LT:-300} ST=${ST:-1}
    swayidle -w \
        timeout $LT 'swaylock-effects -f' \
        timeout $((LT + ST)) 'swaymsg "output * power off"' \
                      resume 'swaymsg "output * power on"'  \
        timeout $ST 'pgrep -xu "$USER" -f swaylock-effects >/dev/null && swaymsg "output * power off"' \
             resume 'pgrep -xu "$USER" -f swaylock-effects >/dev/null && swaymsg "output * power on"'  \
        before-sleep 'swaylock-effects -f' \
        lock 'swaylock-effects -f' \
        unlock 'pkill -xu "$USER" -SIGUSR1 -f swaylock-effects'
fi

