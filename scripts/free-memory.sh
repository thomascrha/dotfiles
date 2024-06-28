#!/bin/bash

# script to free up memory
# run as root
if [ $(id -u) -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo "Memory status before cleanup"
free -m

echo 3 > /proc/sys/vm/drop_caches
swapoff -a
swapon -a

echo "Memory status after cleanup"
free -m
