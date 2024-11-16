#!/bin/bash

# get all service files in the current directory
for service in *.service; do
    # get the service name
    service_name=$(basename $service .service)
    # check if the service is running
    service_status=$(systemctl --user is-active $service_name)
    echo "Service $service_name is $service_status"
    # mathc against active or activating
    # if [[ $service_status != "active" || $service_status != "activating" ]]; then
        # restart the service
        # echo "Restarting $service_name"
        # systemctl --user restart $service_name &
    # fi
    # systemctl --user enable $service_name
    # systemctl --user restart $service_name &
done
