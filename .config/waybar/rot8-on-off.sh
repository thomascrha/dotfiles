#!/bin/bash

if pgrep -x "rot8" 2>&1 > /dev/null
then
    if [[ $1 == click ]]; then
        systemctl --user stop rot8 2>&1 > /dev/null
        TOOLTIP="Screen locked"
        ICON="🔒"
    else
        TOOLTIP="Screen unlocked"
        ICON="🔓"
    fi
else
    if [[ $1 == click ]]; then
        systemctl --user start rot8 2>&1 > /dev/null
        TOOLTIP="Screen unlocked"
        ICON="🔓"
    else
        TOOLTIP="Screen locked"
        ICON="🔒"
    fi
fi

echo "{\"text\":\"${ICON}\", \"tooltip\":\"${TOOLTIP}\"}"

