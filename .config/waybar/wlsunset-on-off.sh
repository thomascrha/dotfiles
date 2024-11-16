#!/bin/bash

if pgrep -x "wlsunset" 2>&1 > /dev/null
then
    if [[ $1 == click ]]; then
        systemctl --user stop wlsunset
        ICON="" # off  
    else
        ICON="" # on
    fi
else
    if [[ $1 == click ]]; then
        systemctl --user start wlsunset
        ICON="" # on
    else
        ICON="" # off  
    fi
fi

echo "{\"text\":\"${ICON}\", \"tooltip\":\"$(cat /tmp/wlsunset.log | grep -e 'calculated sun trajectory' | tail -1 | awk '{sub(/calculated sun trajectory: /, ""); print}')\"}" 
