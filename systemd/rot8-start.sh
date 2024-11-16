#!/bin/bash

# Unlocked default state
TOOLTIP="Screen unlocked"
ICON="🔓"

echo "{\"text\":\"${ICON}\", \"tooltip\":\"${TOOLTIP}\"}" > /tmp/rot8.state

/usr/bin/rot8 --hooks 'systemctl --user restart lisgd.service'
