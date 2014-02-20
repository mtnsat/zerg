zergrush_vagrant GemPlugin
===

Tasks
--------------
- type - Type of task payload. 'shell', 'chef_client' or 'chef_solo'
    - shell task parameters: 
        - [shell provisioner]
    - chef_client and chef_solo task parameters map directly to Vagrant provisioner docs, **EXCEPT the node_name parameter**:
        - [chef_solo provisioner]
        - [chef_client provisioner]
        - [chef common options]

[chef_solo provisioner]:http://docs.vagrantup.com/v2/provisioning/chef_solo.html
[chef_client provisioner]:https://docs.vagrantup.com/v2/provisioning/chef_client.html
[chef common options]:http://docs.vagrantup.com/v2/provisioning/chef_common.html
[shell provisioner]:http://docs.vagrantup.com/v2/provisioning/shell.html