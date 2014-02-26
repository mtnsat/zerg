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

You will then be able to run the task with:

```
zerg rush helloaws
```

Tasks
--------------
Zerg task files are json files that are loaded by zerg, validated, and then transformed into a Vagrantfile. Vagrant is then launched against that generated vagrantfile.

[Task JSON schema](zerg/data/ke.schema)

- num_instances - number of virtual machines that'll be started
- synced_folders - array of folders to sync 
    - host_path - path to folder on the host
    - guest_path - path to folder on the guest that host_path will map to
    - options - array of options corresponding to [Vagrant sync folder options]
- tasks - array of tasks. Task definitions vary by driver type. For example: [Vagrant driver schema](zerg_plugins/zergrush_vagrant/resources/tasks_schema.template)
    - [Tasks array details](zerg_plugins/zergrush_vagrant)
- vm - description of all VM instances.
    - private_ip_range - IP address range in [CIDR notation](http://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) used for all private ip addresses, unless said address is explicitly specified by another option. First host ip in range is always the host machine. 
    - driver - properties of a hypervisor 'driver'. Currently only [Vagrant] is supported
        - drivertype - Type of the 'driver' Only 'vagrant' is currently supported.
        - driveroptions - options for the driver, defined by [driver plugin](zerg_plugins/zergrush_vagrant)  
    - instances - array of detailed descriptions of each/some of the vm instances. Last definition in the array is applied to the rest of remaining instances. For example: if num_instances is 3 and there are 2 items in instances array, then first VM will correspond to the first item, and the other two VMs will correspond to the second. 
        - basebox - basebox file location or URL
        - keepalive - keep this instance around after all tasks are finished
        - tasks - array of tasks to run. Task properties are defined by [driver plugin](zerg_plugins/zergrush_vagrant)
        - synced_folders - array of synchronized folders
            - host_path - path on host
            - guest_path - corresponding path on guest
            - additional - addtional properties defined by [driver plugin](zerg_plugins/zergrush_vagrant) 
        - forwarded_ports - array of port forwarding descriptions
            - guest_port port on guest to be forwarded
            - host_port - port on host to be forwarded to
            - additional - addtional properties defined by [driver plugin](zerg_plugins/zergrush_vagrant) 
        - networks - array of networks to be setup - NAT/bridging/etc. Network options are defined by [driver plugin](zerg_plugins/zergrush_vagrant)
        - ssh - SSH options 
            - username - ssh username
            - host - ssh host, normally autodetected 
            - port - host ssh port
            - guest_port - guest ssh port
            - private_key_path - path to the private key file
            - forward_agent - do SSH agent forwarding
            - additional - addtional properties defined by [driver plugin](zerg_plugins/zergrush_vagrant) 

Example task
--------------

Below example task that:
- will start 5 virtual machines using vagrant
- first machine will be backed by VirtualBox
- other machines will be backed by AWS
- first machine will run some shell commands and will have a private network and a public network, bridged over host's AirPort adapter. It will also stay up after all other tasks are doen running
- second machine will have git installed on it with chef client
- all other machines will run 'starter' cookbook through chef solo

```
{
    "num_instances": 5,
    "vm": {
        "driver": {
            "drivertype": "vagrant",
            "driveroptions": [
                {
                    "providertype": "virtualbox",
                    "provider_options" : {
                        "gui": false,
                        "memory": 256
                    }
                },
                {
                    "providertype": "aws",
                    "provider_options" : {
                        "instance_type": "t1.micro",
                        "access_key_id": "YOUR_AWS_ACCESS_KEY_ID",
                        "secret_access_key": "YOUR_AWS_SECRET",
                        "keypair_name": "AWS_KEYPAIR_NAME",
                        "ami": "ami-3fec7956",
                        "region": "us-east-1",
                        "security_groups": [ "your_security_group" ]
                    }
                }
            ]
        },
        "private_ip_range": "192.168.50.0/24",
        "instances": [
            {
                "basebox": "http://files.vagrantup.com/precise32.box",
                "keepalive": true,
                "tasks": [
                    {
                        "type": "shell",
                        "inline": "ping -c 3 192.168.50.1; echo \"ZERG RUSH FIRST!\""
                    }        
                ],
                "networks": [
                    {
                        "type": "private_network"
                    },
                    {
                        "type": "public_network",
                        "bridge": "en1: Wi-Fi (AirPort)"
                    }         
                ],
                "synced_folders": [
                    {
                        "host_path": "~",
                        "guest_path": "/zerg/hosthome"
                    }        
                ],
                "forwarded_ports": [
                    {
                        "guest_port": 8080,
                        "host_port": 80
                    }        
                ],
            },
            {
                "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                "keepalive": false,
                "tasks": [
                    {
                        "type": "chef_client",
                        "chef_server_url": "CHEF_URL",
                        "validation_key_path": "CHEF_VALIDATION_KEYPATH",
                        "client_key_path": "CHEF_CLIENT_KEYPATH",
                        "validation_client_name": "CHEF_VALIDATION_CLIENT_NAME",
                        "delete_node": true,
                        "delete_client": true,
                        "run_list": ["recipe[git]"]
                    }        
                ],
                "ssh": {
                    "username": "ubuntu",
                    "private_key_path": "PATH_TO_YOUR_PK"      
                }
            },
            {
                "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                "keepalive": false,
                "tasks": [
                    {
                        "type": "chef_solo",
                        "cookbooks_path": ["~/cookbooks"],
                        "run_list": ["recipe[starter]"]
                    }        
                ],
                "ssh": {
                    "username": "ubuntu",
                    "private_key_path": "PATH_TO_YOUR_PK"      
                }
            }
        ]
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

Plugins
--------------

Zerg plugins are ruby gems. Each plugin gem must have an 'init.rb' file lib/__gem_name__/init.rb

required in the init.rb file:

```
require 'zerg'

class Vagrant < ZergGemPlugin::Plugin "/driver"
    def rush hive_location, task_name, task_hash, debug
        # 'zerg rush <task>' functionality.   
    end

    def clean hive_location, task_name, task_hash, debug
        # 'zerg clean <task>' functionality.
    end

    def halt hive_location, task_name, task_hash, debug
        # 'zerg halt <task>' functionality 
    end

    def task_schema
        # return a chunk of JSON schema for defining task item in tasks array
    end

    def option_schema
        # return a chunk of JSON schema for defining driver options
    end

    def folder_schema
        # return a chunk of JSON schema for defining driver-specific sync_folder options
    end

    def port_schema
        # return a chunk of JSON schema for defining driver-specific port forwarding options
    end

    def ssh_schema
        # return a chunk of JSON schema for defining driver-specific ssh options
    end
end
```

also, in the gem's gemspec file the following metadata must be present:

```
Gem::Specification.new do |s|
  s.name        = "your_plugin"
 
 ...

  # metadata that marks this as a zergrush plugin
  s.metadata = { "zergrushplugin" => "driver" }
end
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
[AwesomePrint gem]:https://github.com/michaeldv/awesome_print
[JSON Schema gem]:https://github.com/hoxworth/json-schema
[Thor gem]:https://github.com/erikhuda/thor
[Highline gem]:https://github.com/JEG2/highline