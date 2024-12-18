#!/bin/bash

SOV_SOCK=/run/user/1000/sov.sock
# bindsym --no-repeat $mod+1 workspace number 1; exec "echo 1 > $SOV_SOCK"
# bindsym --release $mod+1 exec "echo 0 > $SOV_SOCK"

REPEATS=10

systemctl --user status sov.service
for i in $(seq 1 $REPEATS); do
    echo 1 > $SOV_SOCK
    echo 0 > $SOV_SOCK
    sleep 0.1
done
systemctl --user status sov.service
# systemctl --user restart sov.service
