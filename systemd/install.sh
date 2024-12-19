#!/bin/bash

# loop through all the .service files (and if it exists there -start.sh file) in the current directory
echo "Installing services"
for file in *.service; do
    # get the name of the service
    service_name=$(basename $file .service)
    echo "Installing $service_name"
    # copy the service file to /lib/systemd/user
    sudo install -m 644 $file /usr/lib/systemd/user/
    # if there is a -start.sh file, copy it to /usr/local/bin and set executable permission
    if [ -f $service_name-start.sh ]; then
        echo "Installing $service_name-start.sh"
        sudo install -m 755 $service_name-start.sh /usr/lib/systemd/user/
    fi
    echo "Reloading systemd daemon"
    # reload the systemd daemon
    systemctl --user daemon-reload
    echo "Enabling and starting $service_name"
    # enable the service
    systemctl --user enable --now $service_name
    # echo "Starting $service_name"
    # start the service
    # systemctl --user start $service_name
done

echo "Installing timers"
for file in *.timer; do
    timer_name=$(basename $file .timer)
    echo "Installing $timer_name"
    sudo install -m 644 $file /usr/lib/systemd/user/
    echo "Reloading systemd daemon"
    systemctl --user daemon-reload
    echo "Enabling and starting $timer_name"
    systemctl --user enable --now $timer_name
    # echo "Starting $timer_name"
    # systemctl --user start $timer_name
done
