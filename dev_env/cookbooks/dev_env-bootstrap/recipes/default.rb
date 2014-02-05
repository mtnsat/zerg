#
# Cookbook Name:: zerg_dev_env
# Recipe:: default
#
# Copyright 2014, MTN Satellite Communications
#

# Fixes VBox kernel bug shown at https://gist.github.com/andres-rojas/55f7ae9df00f4ebd0010 
apt_package 'linux-headers-3.2.0-23-generic'
