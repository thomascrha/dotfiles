#!/bin/bash
rm /tmp/wlsunset.state

if pgrep -x "wlsunset"
then
    systemctl --user stop wlsunset
    ICON=""
else
    systemctl --user start wlsunset
    ICON=""
fi

echo "{\"text\":\"${ICON}\", \"tooltip\":\"$(cat /tmp/wlsunset.log | grep -e 'calculated sun trajectory' | tail -1 | awk '{sub(/calculated sun trajectory: /, ""); print}')\"}" > /tmp/wlsunset.state

