#!/bin/bash
set -xe 

# check if the script is run as root 
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $HOSTNAME-thinkfan.conf ]]; then
    echo "Error: $HOSTNAME-thinkfan.conf not found"
    exit 1
fi

cp $HOSTNAME-thinkfan.conf /etc/thinkfan.conf
systemctl enable --now thinkfan.service
