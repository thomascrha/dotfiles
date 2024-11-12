#!/bin/bash

running_apps=$(pgrep -fc "swaylock")
if [ $running_apps = 0 ]; then
    LT="$lock_timeout" ST="$screen_timeout" LT=${LT:-300} ST=${ST:-300}
    swayidle -w \
        timeout $LT 'swaylock -f' \
        timeout $((LT + ST)) 'swaymsg "output * power off"' \
                      resume 'swaymsg "output * power on"'  \
        timeout $ST 'pgrep -xu "$USER" -f swaylock >/dev/null && swaymsg "output * power off"' \
             resume 'pgrep -xu "$USER" -f swaylock >/dev/null && swaymsg "output * power on"'  \
        before-sleep 'swaylock -f' \
        lock 'swaylock -f' \
        unlock 'pkill -xu "$USER" -SIGUSR1 -f swaylock'
fi

