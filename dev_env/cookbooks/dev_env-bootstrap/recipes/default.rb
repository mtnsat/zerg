#
# Cookbook Name:: zerg_dev_env
# Recipe:: default
#
# Copyright 2014, MTN Satellite Communications
#

include_recipe 'kvm::default'
include_recipe 'kvm::host'
include_recipe 'kvm::host-tuning'
include_recipe 'libvirt'
