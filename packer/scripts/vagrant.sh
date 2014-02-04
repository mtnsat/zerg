#!/bin/bash
set -e

mkdir /home/vagrant/.ssh

# add vagrant default public key
wget --no-check-certificate \
    'https://github.com/mitchellh/vagrant/raw/master/keys/vagrant.pub' \
    -O /home/vagrant/.ssh/authorized_keys

# move the nomadix proxy tunneling key uploaded by packer template into place
mv /tmp/proxy_rsa /home/vagrant/.ssh

# adjust permissions.
chown -R vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh