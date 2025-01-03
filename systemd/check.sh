#!/bin/bash

# get all service files in the current directory
for service in *.service; do
    # get the service name
    service_name=$(basename $service .service)
    # check if the service is running
    service_status=$(systemctl --user is-active $service_name)
    echo "Service $service_name is $service_status"
done
