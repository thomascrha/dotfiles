#!/bin/bash

# check if sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

set -xe

install -m 755 set-power-profile /usr/local/bin
install -m 644 etc_udev_rules.d/60-onbattery.rules /etc/udev/rules.d
install -m 644 etc_udev_rules.d/61-onacpower.rules /etc/udev/rules.d
install -m 644 etc_udev_rules.d/62-lowbattery.rules /etc/udev/rules.d

