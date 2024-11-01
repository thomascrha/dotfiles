#!/bin/bash
if pgrep -x "wlsunset"
then
    ICON=""
else
    ICON=""
fi

echo {\"icon\":\"${ICON}\"}

