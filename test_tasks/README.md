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
- AWS_PRIVATE_KEY_PATH - path to private key pem
- AWS_SECURITY_GROUP - name of AWS security group to use

KVM.KE task 
=========

You will NOT be able to run this task from either a virtualbox VM or an AWS instance. It might work with a hypervizor that supports nested virtualization.

Use a physical ubuntu machine, make sure libvirt is installed.

Default Ubuntu 12.04 has outdated libvirt/kvm/wemu tools, that Vagrant will likely have trouble with.

Here's some [preliminary setup might need to do]:

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


Ubuntu 12.04 might not have a 'default' storage pool defined:

```
virsh pool-define-as --name default --type dir --target /var/lib/libvirt/images
virsh pool-autostart default
virsh pool-build default
virsh pool-start default

```

Make sure NFS is installed ...

```
sudo apt-get install nfs-kernel-server nfs-common portmap
```

Now kick off the task:

```
zerg rush kvm
```

You might be asked to enter your sudo password to mount the NFS share. [There are numerous guides online for setting up passwordless sudo for NFS].

[preliminary setup might need to do]:http://marenkay.com/linux/ubuntu-lts-1204-qemu-vagrant.rem
[There are numerous guides online for setting up passwordless sudo for NFS]:https://www.google.com/search?q=nfs+without+password&oq=nfs+without+password&aqs=chrome..69i57j69i60j69i61.3840j0j4&sourceid=chrome&espv=210&es_sm=91&ie=UTF-8#q=vagrant+nfs+without+password


