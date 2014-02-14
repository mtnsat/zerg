Zerg
=========

Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once. 

  - Tested on Ubuntu 12.04
  - YMMV on OSX, however it is recommended you use the provided dev VM
  - JSON config files
  - Supports vagrant virtualbox, vagrant-aws and vagrant-libvirt providers
  - planned support for more hypervisor orchestration tools and providers
  - [Ruby] 1.9 required

Attributions
-----------

Zerg uses a number of open source projects to work properly:

* [Vagrant]
* [Chef Solo]
* [AwesomePrint gem]
* [JSON Schema gem]
* [Thor gem]
* [Highline gem]


Develop (OSX)
--------------
Install [Vagrant]. Then:

```sh
git clone git@github.com:MTNSatelliteComm/zerg.git zerg
cd zerg/dev_env
vagrant plugin install vagrant-berkshelf
vagrant plugin install vagrant-omnibus
vagrant up --provision
vagrant ssh
cd /zerg
```

See if Virtualbox is functioning normally:
```
VBoxManage --version

```

Use
--------------

From Rubygems:

```
gem install zergrush
```

From source:

```
cd zerg
rake install
```

cd to a folder where you would like to use zerg from and:

```
zerg init
zerg rush <task name>
```

'zerg init' command initializes two example tasks - helloworld and helloaws. Try them with:

```
zerg rush helloworld
```

Note that prior to trying the helloaws task you will need to set some environment variables:

- AWS_ACCESS_KEY_ID - AWS key id
- AWS_SECRET_ACCESS_KEY - AWS secret key
- AWS_KEY_PAIR - AWS key pair name
- AWS_PRIVATE_KEY_PATH - path to the private key .pem
- AWS_SECURITY_GROUP - name of an AWS security group to use

You will then be bale to run the task with:

```
zerg rush helloaws
```

Tasks
--------------
Zerg task files are json files that are loaded by zerg, validated, and then transformed into a Vagrantfile. Vagrant is then launched against that generated vagrantfile.

[Task JSON schema](zerg/data/ke.schema)

- instances - number of virtual machines that'll be started
- synced_folders - array of folders to sync 
    - host_path - path to folder on the host
    - guest_path - path to folder on the guest that host_path will map to
    - options - array of options corresponding to [Vagrant sync folder options]
- tasks - array of tasks
    - type - Type of task payload. 'shell', 'chef_client' or 'chef_solo'
    - shell task parameters: 
        - [shell provisioner]
    - chef_client and chef_solo task parameters map directly to Vagrant provisioner docs, **EXCEPT the node_name parameter**:
        - [chef_solo provisioner]
        - [chef_client provisioner]
        - [chef common options]
- vm - description of all VM instances.
    - driver - properties of a hypervisor 'driver'. Currenlty only [Vagrant] is supported
        - drivertype - Type of the 'driver' Only 'vagrant' is currently supported.
        - providertype - Hypervisor provider. 'virtualbox', 'aws', 'libvirt'
        - provider_options - provider options. Array of strings - each one is a vagrantfile string documented at [Vagrant docs], [vagrant-aws docs] and [vagrant-libvirt docs].
    - basebox - Path to the vagrant base box. File path or URL
    - private_network - setup a host-only network between host and VM. True or false. Only valid for 'virtualbox' and 'libvirt' providertype.
    - bridge_description - specifies which host adapter to bridge. Should be a full description string of the host NIC, as seen by VirtualBox. Only valid for 'virtualbox' and 'libvirt' providertype.
    - keepalive - if se to tru, VMs will be left running after all tasks are finished. 'zerg halt <task>' to stop.

Example task
--------------

Below example task uses all four types of provisioners on an AWS instance:

```
{
    "instances": 5,
    "tasks": [
        {
            "type": "inline",
            "payload": "echo \"ZERG RUSH PRIME!\""
        },
        {
            "type": "shell",
            "payload": "/bin/echo",
            "parameters": "hello bin echo"
        },
        {
            "type": "chef_client",
            "chef_server_url": "http://mychefserver.com:4000/",
            "validation_key_path": "validation.pem",
            "environment": "default",
            "client_key_path": "client.pem",
            "node_name": "trollolo",
            "validation_client_name": "ladadadadeeeee",
            "delete_node": true,
            "delete_client": true,
            "recipes": ["ark", "rvm", "packer"],
            "roles": ["tester", "web", "seanet"]
        },
        {
            "type": "chef_client",
            "cookbooks_path": ["~/cookbooks", "~/Downloads/cookbooks"],
            "data_bags_path": ["~/databags", "~/Downloads/databags"],
            "environments_path": ["~/environs", "~/Downloads/environs"],
            "roles_path": ["~/roles", "~/Downloads/roles"],
            "encrypted_data_bag_secret_key_path": "encrypted_data_bag_secret_key_path.pem",
            "environment": "default",
            "nfs": false,
            "recipe_url": "http://www.cookbooks.com/cookbooks.zip",
            "json": {
                "apache": {
                    "listen_address": "0.0.0.0"
                }
            },
            "recipes": ["ark", "rvm", "packer"],
            "roles": ["tester", "web", "seanet"]
        }                    
    ],
    "vm": {
        "driver": {
            "drivertype": "vagrant",
            "providertype": "aws",
            "provider_options": [
                "aws.instance_type = 't1.micro'",
                "aws.access_key_id = \"#{ENV['AWS_ACCESS_KEY_ID']}\"",
                "aws.secret_access_key = \"#{ENV['AWS_SECRET_ACCESS_KEY']}\"",
                "aws.keypair_name = \"#{ENV['AWS_KEY_PAIR']}\"",
                "aws.ami = 'ami-3fec7956'",
                "aws.region = 'us-east-1'",
                "aws.security_groups = [ 'vagrant' ]",
                "override.ssh.username = 'ubuntu'",
                "override.ssh.private_key_path = \"#{ENV['AWS_PRIVATE_KEY_PATH']}\""
            ]
        },
        "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
        "private_network": false
    }
}
```

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

Known issues
--------------

__Vagrant inside vagrant__

Running 64bit virtualbox VMs inside dev_env VM will most likely fail:

https://forums.virtualbox.org/viewtopic.php?f=1&t=20589&start=15

https://github.com/mitchellh/vagrant/issues/572

You should still be able to run 32bit virtualbox boxes inside another VM though.

__Security__

JSON config files allow for snippets of ruby code to be passed through (#{ENV['BLAH']})

Not a problem locally, but would be **BAD** for a REST API


[Vagrant]:http://wwww.vagrantup.com
[Vagrant docs]:http://docs.vagrantup.com/v2/virtualbox/configuration.html
[Vagrant sync folder options]:http://docs.vagrantup.com/v2/synced-folders/basic_usage.html
[vagrant-aws docs]:https://github.com/mitchellh/vagrant-aws
[vagrant-libvirt docs]:https://github.com/pradels/vagrant-libvirt
[Chef Solo]:http://docs.opscode.com/chef_solo.html
[Ruby]:https://www.ruby-lang.org
[schema]:http://json-schema.org
[chef_solo provisioner]:http://docs.vagrantup.com/v2/provisioning/chef_solo.html
[chef_client provisioner]:https://docs.vagrantup.com/v2/provisioning/chef_client.html
[chef common options]:http://docs.vagrantup.com/v2/provisioning/chef_common.html
[shell provisioner]:http://docs.vagrantup.com/v2/provisioning/shell.html
[AwesomePrint gem]:https://github.com/michaeldv/awesome_print
[JSON Schema gem]:https://github.com/hoxworth/json-schema
[Thor gem]:https://github.com/erikhuda/thor
[Highline gem]:https://github.com/JEG2/highline