#!/bin/bash
## This script is used to start a program if it is not running

set -xe

APP=$1
APP_COMMAND=$2

# Check if a program is running, if not, start it
if ps aux | grep $APP | grep -v grep | grep -v exec_non_running; then
    echo "$APP is running"
else
    echo "$APP is not running"
    exec $APP_COMMAND
fi
