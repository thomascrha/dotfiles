#!/bin/bash
rm /tmp/rot8.state

if pgrep -x "rot8"
then
    systemctl --user stop rot8
    TOOLTIP="Screen locked"
    ICON="🔒"
else
    systemctl --user start rot8
    TOOLTIP="Screen unlocked"
    ICON="🔓"
fi

echo "{\"text\":\"${ICON}\", \"tooltip\":\"${TOOLTIP}\"}" > /tmp/rot8.state

