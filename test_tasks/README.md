Zerg test tasks
=========

Import tasks:

```
zerg hive import chef_client.ke
zerg hive import chef_solo.ke
zerg hive import kvm.ke
```

Setup environment variables:

- ZERG_TEST_CHEF_SERVER - url of chef server
- ZERG_TEST_CHEF_VALIDATOR - path to validator key file
- ZERG_TEST_COOKBOOKS_PATH - path to zerg test_cookbooks directory
- ZERG_TEST_CHEF_CLIENTKEY - path to client key .pem
- ZERG_TEST_CHEF_CLIENTNAME - validator name (i.e. 'chef-validator')
- AWS_ACCESS_KEY_ID - AWS key id
- AWS_SECRET_ACCESS_KEY - AWS secret key
- AWS_KEY_PAIR - AWS key pair name
- AWS_PRIVATE_KEY_PATH - AWS key pair name

KVM.KE task 
=========

You will likely not be able to run this task from either a virtualbox VM or an AWS instance.

Use a physical ubuntu sled, make sure libvirt is installed.

Default Ubuntu 12.04 has an outdated libvirt/kvm/wemu tools, that Vagrant will likely have trouble with.

Here's some [preliminary setup you'll likely have to do]:

```
sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:miurahr/vagrant && sudo apt-get update
sudo apt-get install -y bridge-utils libvirt-bin python-vm-builder qemu-kvm qemu-system
```

Install pre-requisites for vagrant-libvirt


```
sudo apt-get install libxslt-dev libxml2-dev libvirt-dev
```

Setup a KVM-compatible box:

```
vagrant plugin install vagrant-mutate
vagrant mutate http://files.vagrantup.com/precise64.box libvirt
```

Ubuntu 12.04 won't have a defualt storage pool defined (sigh):

```
mkdir ~/kvm_images
virsh pool-define-as --name default --type dir --target /home/ubuntu/
virsh pool-autostart default
virsh pool-build default
virsh pool-start default

```

[preliminary setup you'll likely have to do]:http://marenkay.com/linux/ubuntu-lts-1204-qemu-vagrant.rem


