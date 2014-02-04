#!/bin/bash -eux

rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/ /var/lib/dhcp3/*
echo "pre-up sleep 2" >> /etc/network/interfaces
echo "post-up route del default dev eth0" >> /etc/network/interfaces
echo "pre-down route add default dev eth0" >> /etc/network/interfaces