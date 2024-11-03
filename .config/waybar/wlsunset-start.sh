#!/bin/bash

echo "{\"text\":\"\", \"tooltip\":\"$(cat /tmp/wlsunset.log | grep -e 'calculated sun trajectory' | tail -1 | awk '{sub(/calculated sun trajectory: /, ""); print}')\"}" > /tmp/wlsunset.state
/usr/bin/wlsunset -l -33.7 -L 150.3
