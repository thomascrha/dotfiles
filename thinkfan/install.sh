#!/bin/bash
set -xe 

# check if the script is run as root 
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $HOSTNAME-thinkfan.yaml ]]; then
    echo "Error: $HOSTNAME-thinkfan.yaml not found"
    exit 1
fi

cp $HOSTNAME-thinkfan.yaml /etc/thinkfan.conf
systemctl enable --now thinkfan.service
