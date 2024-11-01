#!/bin/bash

if pgrep -x "wlsunset"
then
    systemctl --user stop wlsunset
    rm /tmp/wlsunset.state
    ICON=""
else
    systemctl --user start wlsunset
    rm /tmp/wlsunset.state
    ICON=""
fi

echo "{\"text\":\"${ICON}\", \"tooltip\":\"$(cat /tmp/wlsunset.log | grep -e 'calculated sun trajectory' | tail -1 | awk '{sub(/calculated sun trajectory: /, ""); print}')\"}" > /tmp/wlsunset.state

