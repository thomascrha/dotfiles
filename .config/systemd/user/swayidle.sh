#!/bin/sh
swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'niri msg action power-off-monitors' resume 'niri msg action power-on-monitors' \
    timeout 1800 'systemctl suspend' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'

