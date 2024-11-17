#!/bin/bash
set -xe

sudo install -m 755 set-power-profile /usr/local/bin
sudo install -m 644 etc_udev_rules.d/60-onbattery.rules /etc/udev/rules.d
sudo install -m 644 etc_udev_rules.d/61-onacpower.rules /etc/udev/rules.d
sudo install -m 644 etc_udev_rules.d/62-lowbattery.rules /etc/udev/rules.d

