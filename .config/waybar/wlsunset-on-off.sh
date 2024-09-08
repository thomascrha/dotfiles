#!/bin/bash

if pgrep -x "wlsunset" > /dev/null
then
    pkill wlsunset > /dev/null 2>&1
else
    wlsunset -l -33.7 -L 150.3 > /dev/null 2>&1 &
fi
