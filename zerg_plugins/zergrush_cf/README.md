Vagrant driver for Zerg
===

Dependencies
--------------

- [vagrant-aws](https://github.com/mitchellh/vagrant-aws)
- [vagrant-libvirt](https://github.com/pradels/vagrant-libvirt)
- [vagrant-omnibus](https://github.com/schisamo/vagrant-omnibus)
- [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf)

Additional properties defined
--------------

######[Synchronized folders](resources/folder_schema.template)

Defined by [Vagrant synced folders](http://docs.vagrantup.com/v2/synced-folders/)

Example use:
```
...
"create": true,
"mount_options": ["rw", "vers=3", "tcp"]
...
```

######[Networks](resources/networks_schema.template)

Defined by [Vagrant networking](http://docs.vagrantup.com/v2/networking/index.html)

Example use:
```
...
"type": "public_network",
"bridge": "en1: Wi-Fi (AirPort)"
...
```

######[Driver options](resources/option_schema.template)

- providertype - One of the supported Vagrant providers. Currenlty supported providers are: virtualbox, libvirt, aws
- provider_options - hash of provider specific options. 
- raw_options - if some of the provider options do not map to a hash format - you can specify them as an array of strings. Each string should start with '[provider].'

Example use:
```
...
"driver": {
    "drivertype": "vagrant",
    "driveroptions": [
        {
            "providertype": "aws",
            "provider_options" : {
                "instance_type": "t1.micro",
                "access_key_id": "blah blah blah",
                "secret_access_key": "yadda yadda",
                "keypair_name": "HURGHBURGHLGHRL",
                "ami": "ami-3fec7956",
                "region": "us-east-1"
            }
        },
        {
            "providertype": "virtualbox",
            "provider_options" : {
                "gui": false,
                "memory": 256
            },
            "raw_options": [
                "virtualbox.customize [\"modifyvm\", :id,  \"--natdnsproxy1\", \"off\"]",
                "virtualbox.customize [\"modifyvm\", :id,  \"--natdnshostresolver1\", \"off\"]"
            ]
        }
    ]
}
...
```

######[Forwarded ports](resources/ports_schema.template)

Defined by [Vagrant forwarded ports](http://docs.vagrantup.com/v2/networking/forwarded_ports.html)

Example use:
```
...
"guest_port": 8080,
"host_port": 80,
"protocol": "tcp"
...
```

######[SSH](resources/ssh_schema.template)

Defined by [Vagrant SSH](http://docs.vagrantup.com/v2/vagrantfile/ssh_settings.html)

Example use:
```
...
"username": "ubuntu",
"private_key_path": "PATH_TO_YOUR_PK",
"shell": "bash -l"
...
```

######[Tasks](resources/tasks_schema.template)

Describes what tasks a VM should run at provisioning step

- type - Type of task payload. 'shell', 'chef_client' or 'chef_solo'
    - shell task parameters are defined by [Vagrant shell provisioner](http://docs.vagrantup.com/v2/provisioning/shell.html)
    - chef_client and chef_solo task parameters map directly to Vagrant provisioner docs, **EXCEPT the node_name parameter**:
        - [chef_solo provisioner](http://docs.vagrantup.com/v2/provisioning/chef_solo.html)
        - [chef_client provisioner](https://docs.vagrantup.com/v2/provisioning/chef_client.html)
        - [chef common options](http://docs.vagrantup.com/v2/provisioning/chef_common.html)