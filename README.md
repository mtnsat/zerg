Zerg
=========

Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once. 

  - Intended for use on a linux host
  - YMMV on OSX, however it is recommended you use the provided dev VM
  - JSON config files
  - Supports vagrant virtualbox and vagrant-aws providers
  - planned support for more hypervisor orchestration tools and providers
  - [Ruby] 1.9 required

Version
----

0.0.1

Tech
-----------

Zerg uses a number of open source projects to work properly:

* [Packer] - tool for building identical machine images from single source file
* [Vagrant] - tool for building complete development environments
* [Chef Solo] - Open source utility for using Opscode Chef cookbooks without access to a server

Develop (OSX)
--------------
Install [Vagrant]. Then:

```sh
git clone git@github.com:MTNSatelliteComm/zerg.git zerg
cd zerg/dev_env
vagrant up --provision
vagrant ssh
cd /zerg
```

Use
--------------

```sh
cd zerg
rake install
```

cd to a folder where you would like to use zerg from and:

```sh
zerg init
zerg rush <task name>
```

'zerg init' command initializes two example tasks - helloworld and helloaws. Try them with:

```sh
zerg rush helloworld
```

Note that prior to trying the helloaws task you will need to set some environment variables:

- AWS_ACCESS_KEY_ID - AWS key id
- AWS_SECRET_ACCESS_KEY - AWS secret key
- AWS_PRIVATE_KEY_PATH - AWS key pair name
- AWS_PRIVATE_KEY_PATH - path to the private key .pem

You will then be bale to run the task with:

```sh
zerg rush helloaws
```

Tasks
--------------
Zerg task files are json files that are loaded by zerg, validated, and then transformed into a Vagrantfile. Vagrant is then launched against that generated vagrantfile.

Example task

```
{
    "instances": 3,
    "tasks": [
        {
            "type": "script",
            "payload": "~/somescript.sh",
            "parameters": "-f -n trololololo"
        }        
    ],
    "vm": {
        "driver": {
            "drivertype": "vagrant",
            "providertype": "virtualbox",
            "provider_options": [
                "virtualbox.gui = false",
                "virtualbox.memory = 256",
                "# adjust for DNS weirdness in ubuntu 12.04",
                "virtualbox.customize ['modifyvm', :id,  '--natdnsproxy1', 'off']",
                "virtualbox.customize ['modifyvm', :id,  '--natdnshostresolver1', 'off']",
                "# set virtio type on the NIC driver. Better performance for large traffic bursts",
                "virtualbox.customize ['modifyvm', :id,  '--nictype1', 'virtio']",
                "virtualbox.customize ['modifyvm', :id,  '--nictype2', 'virtio']",
                "virtualbox.customize ['modifyvm', :id,  '--nictype3', 'virtio']"
            ]
        },
        "basebox": "http://files.vagrantup.com/precise64.box",
        "private_network": true,
        "bridge_description": "Eth1.5"
    }
}
```

- instances - number of virtual machines that'll be started
- tasks - array of tasks
    - type - Type of task payload. 'inline' or 'script'
    - payload - Payload value. Either a line of bash, or path to a file
    - parameters - Paremeters to a script file. Not applicable to 'inline'
- vm - description of all VM instances.
    - driver - properties of a hypervisor 'driver'. Currenlty only [Vagrant] is supported
        - drivertype - Type of the 'driver' Only 'vagrant' is currently supported.
        - providertype - Hypervisor provider. 'virtualbox' or 'aws'
        - provider_options - Virtualbox or Aws options. Array of strings - each one is a vagrantfile string documented at [Vagrant docs] and [vagrant-aws docs] respectively.
        - basebox - Path to the vagrant base box. File path or URL
        - private_network - setup a host-only network between host and VM. True or false. Only valid for 'virtualbox' providertype.
        - bridge_description - specifies which host adapter to bridge. Should be a full description string of the host NIC, as seen by VirtualBox. Only valid for 'virtualbox' providertype.


Other commands
--------------
CLI help is available from the gem:

```
zerg help
```

Environment variables
--------------
By default Zerg will look for '.hive' in the current directory. You can override this location by setting an enviroment variable:

```
export HIVE_CWD=/path/to/wherever/you/want
```

Tests
--------------

```
cd zerg
bundle exec cucumber features/
```

[Vagrant]:http://wwww.vagrantup.com
[Vagrant docs]:http://docs.vagrantup.com/v2/virtualbox/configuration.html
[vagrant-aws docs]:https://github.com/mitchellh/vagrant-aws
[Packer]:http://www.packer.io
[Chef Solo]:http://docs.opscode.com/chef_solo.html
[Ruby]:https://www.ruby-lang.org