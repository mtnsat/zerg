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

Task [schema]:

```
{
  "type": "object",
  "id": "com.mtnsat.zerg.json.ke",
  "properties": {
    "instances": {
      "type": "integer",
      "id": "com.mtnsat.zerg.json.ke.instances",
      "minimum": 0
    },
    "ram_per_vm": {
      "type": "integer",
      "id": "com.mtnsat.zerg.json.ke.ram_per_vm",
      "minimum": 256
    },
    "tasks": {
      "type": "array",
      "id": "com.mtnsat.zerg.json.ke.tasks",
      "minItems": 1,
      "items": {
        "properties": {
          "type": {
            "type": "string",
            "pattern": "^(shell|inline|chef_client|chef_solo)$",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.type"
          },
          "payload": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.payload"
          },
          "parameters": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.parameters"
          },
          "environment": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.environment"
          },
          "recipe_url": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.recipe_url"
          },
          "client_key_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.client_key_path"
          },
          "validation_client_name": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.validation_client_name"
          },
          "arguments": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.arguments"
          },
          "chef_server_url": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.chef_server_url"
          },
          "validation_key_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.validation_key_path"
          },
          "encrypted_data_bag_secret_key_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.encrypted_data_bag_secret_key_path"
          },
          "binary_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.binary_path"
          },
          "custom_config_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.custom_config_path"
          },
          "formatter": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.formatter"
          },
          "http_proxy": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.http_proxy"
          },
          "http_proxy_user": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.http_proxy_user"
          },
          "http_proxy_pass": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.http_proxy_pass"
          },
          "no_proxy": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.no_proxy"
          },
          "https_proxy": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.https_proxy"
          },
          "https_proxy_user": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.https_proxy_user"
          },
          "https_proxy_pass": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.https_proxy_pass"
          },
          "log_level": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.log_level"
          },
          "provisioning_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.provisioning_path"
          },
          "file_cache_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.file_cache_path"
          },
          "file_backup_path": {
            "type": "string",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.file_backup_path"
          },
          "verbose_logging": {
            "type": "boolean",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.verbose_logging"
          },
          "delete_node": {
            "type": "boolean",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.delete_node"
          },
          "delete_client": {
            "type": "boolean",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.delete_client"
          },
          "nfs": {
            "type": "boolean",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.nfs"
          },
          "attempts": {
            "type": "integer",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.attempts"
          },
          "json": {
            "type": "object",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.json"
          },
          "cookbooks_path": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.cookbooks_path",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          },
          "roles_path": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.roles_path",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          },
          "data_bags_path": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.data_bags_path",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          },
          "environments_path": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.environments_path",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          },
          "recipes": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.recipes",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          },
          "roles": {
            "type": "array",
            "id": "com.mtnsat.zerg.json.ke.tasks.item.roles",
            "minItems": 1,
            "items": [
              {
                "type": "string"
              }
            ]
          }
        },
        "required": [
            "type"
        ],
        "additionalProperties": false
      }
    },
    "vm": {
      "type": "object",
      "id": "com.mtnsat.zerg.json.ke.vm",
      "properties": {
        "driver": {
          "type": "object",
          "id": "com.mtnsat.zerg.json.ke.vm.driver",
          "properties": {
            "drivertype": {
              "type": "string",
              "id": "com.mtnsat.zerg.json.ke.vm.driver.drivertype",
              "pattern": "^(vagrant)$"
            },
            "providertype": {
              "type": "string",
              "id": "com.mtnsat.zerg.json.ke.vm.driver.providertype",
              "pattern": "^(virtualbox|aws)$"
            },
            "provider_options": {
              "type": "array",
              "id": "com.mtnsat.zerg.json.ke.vm.driver.provider_options"
            }
          },
          "required": [
              "drivertype",
              "providertype",
              "provider_options"
          ],
          "additionalProperties": false
        },
        "private_network": {
          "type": "boolean",
          "id": "com.mtnsat.zerg.json.ke.vm.private_network"
        },
        "basebox": {
          "type": "string",
          "id": "com.mtnsat.zerg.json.ke.vm.basebox"
        },
        "bridge_description": {
          "type": "string",
          "id": "com.mtnsat.zerg.json.ke.vm.bridge_description"
        }
      },
      "required": [
          "driver",
          "private_network",
          "basebox"
      ],
      "additionalProperties": false
    }
  },
  "required": [
      "instances",
      "tasks",
      "vm"
  ],
  "additionalProperties": false
}
```

- instances - number of virtual machines that'll be started
- tasks - array of tasks
    - type - Type of task payload. 'inline', 'script', 'chef_client' or 'chef_solo'
    - inline and script task parameters: 
        - payload - Payload value. Either a line of bash, or path to a file
        - parameters - Paremeters to a script file. Not applicable to 'inline'
    - chef_client and chef_solo task parameters map directly to Vagrant provisioner docs, **EXCEPT the node_name parameter**:
        - [chef_solo provisioner]
        - [chef_client provisioner]
        - [chef common options]
        - recipes - array of strings, each string being a name of a cookbook
        - roles - array of strings, each string being a name of a role
- vm - description of all VM instances.
    - driver - properties of a hypervisor 'driver'. Currenlty only [Vagrant] is supported
        - drivertype - Type of the 'driver' Only 'vagrant' is currently supported.
        - providertype - Hypervisor provider. 'virtualbox' or 'aws'
        - provider_options - Virtualbox or Aws options. Array of strings - each one is a vagrantfile string documented at [Vagrant docs] and [vagrant-aws docs] respectively.
        - basebox - Path to the vagrant base box. File path or URL
        - private_network - setup a host-only network between host and VM. True or false. Only valid for 'virtualbox' providertype.
        - bridge_description - specifies which host adapter to bridge. Should be a full description string of the host NIC, as seen by VirtualBox. Only valid for 'virtualbox' providertype.

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
[vagrant-aws docs]:https://github.com/mitchellh/vagrant-aws
[Packer]:http://www.packer.io
[Chef Solo]:http://docs.opscode.com/chef_solo.html
[Ruby]:https://www.ruby-lang.org
[schema]:http://json-schema.org
[chef_solo provisioner]:http://docs.vagrantup.com/v2/provisioning/chef_solo.html
[chef_client provisioner]:https://docs.vagrantup.com/v2/provisioning/chef_client.html
[chef common options]:http://docs.vagrantup.com/v2/provisioning/chef_common.html