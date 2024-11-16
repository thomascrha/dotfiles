#!/bin/bash

# loop through all the .service files (and if it exists there -start.sh file) in the current directory
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
    echo "Enabling $service_name"
    # enable the service
    systemctl --user enable $service_name
    echo "Starting $service_name"
    # start the service
    systemctl --user start $service_name
done
