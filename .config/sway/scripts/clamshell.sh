#!/bin/sh
## This script is used to enable/disable the laptop screen
## when the lid is closed/opened. It uses swaymsg to communicate
## with the sway IPC.
## Requires: sway, swaymsg

LAPTOP_OUTPUT="eDP-1"
LID_STATE_FILE="/proc/acpi/button/lid/LID/state"

read -r LS < "$LID_STATE_FILE"

case "$LS" in
*open)   swaymsg output "$LAPTOP_OUTPUT" enable ;;
*closed) swaymsg output "$LAPTOP_OUTPUT" disable ;;
*)       echo "Could not get lid state" >&2 ; exit 1 ;;
esac
