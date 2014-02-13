Feature: Hive
    When I init, verify list and import hive configs
    As a CLI
    I want to see success

    Scenario: Initializing hive
        When I run `zerg init`
            Then the following files should exist:
                | .hive/helloworld.ke | .hive/helloaws.ke | 
            Then the file ".hive/helloworld.ke" should contain:
                """
                {
                    "instances": 3,
                    "tasks": [
                        {
                            "type": "shell",
                            "inline": "echo \"ZERG RUSH!\""
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
                        "basebox": "http://files.vagrantup.com/precise32.box",
                        "private_network": true
                    }
                }
                """

            Then the file ".hive/helloaws.ke" should contain:
                """
                {
                    "instances": 3,
                    "tasks": [
                        {
                            "type": "shell",
                            "inline": "echo \"ZERG RUSH PRIME!\""
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
                                "aws.security_groups = [ \"#{ENV['AWS_SECURITY_GROUP']}\" ]",
                                "override.ssh.username = 'ubuntu'",
                                "override.ssh.private_key_path = \"#{ENV['AWS_PRIVATE_KEY_PATH']}\""
                            ]
                        },
                        "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                        "private_network": false
                    }
                }
                """
            And the exit status should be 0

    @no-clobber
    Scenario: Verifying hive
        When I run `zerg hive verify`
        Then the output should contain: 
            """
            SUCCESS!
            """
        And the exit status should be 0

        When I run `zerg hive list`
        Then the output should contain: 
            """
            2 tasks in current hive:
            [
                [0] "helloaws",
                [1] "helloworld"
            ]
            """
        And the exit status should be 0

    @no-clobber
    Scenario: Importing a hive task
        Given a file named "arubatask.ke" with:
            """
            {
                "instances": 1,
                "tasks": [
                    {
                        "type": "shell",
                        "inline": "echo \"ARRRRRRRUUUUUBAAAAAAAA!\""
                    }        
                ],
                "vm": {
                    "driver": {
                        "drivertype": "vagrant",
                        "providertype": "aws",
                        "provider_options": [
                            "aws.instance_type = 't1.micro'"
                        ]
                    },
                    "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                    "private_network": false
                }
            }
            """
        
        When I run `zerg hive import arubatask.ke`
        Then the output should contain:
            """
            SUCCESS!
            """
        And the exit status should be 0

        When I run `zerg hive import arubatask.ke`
        Then the output should contain:
            """
            ERROR: 'arubatask.ke' already exists in hive!
            """
        And the exit status should be 1

        When I run `zerg hive import arubatask.ke --force`
        Then the output should contain:
            """
            SUCCESS!
            """
        And the exit status should be 0

    @no-clobber
    Scenario: Listing hive tasks
        When I run `zerg hive list`
        Then the output should contain: 
            """
            3 tasks in current hive:
            [
                [0] "arubatask",
                [1] "helloaws",
                [2] "helloworld"
            ]
            """
        And the exit status should be 0

    Scenario: Overriding hive location
        Given a directory named "overriden/hive/dir"
        Given I set the environment variables to:
            | variable           | value                |
            | HIVE_CWD           | ./overriden/hive/dir |
        When I run `zerg init`
        Then the following files should exist:
            | overriden/hive/dir/.hive/helloworld.ke | overriden/hive/dir/.hive/helloaws.ke | 
        Then the file "overriden/hive/dir/.hive/helloworld.ke" should contain:
            """
            {
                "instances": 3,
                "tasks": [
                    {
                        "type": "shell",
                        "inline": "echo \"ZERG RUSH!\""
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
                    "basebox": "http://files.vagrantup.com/precise32.box",
                    "private_network": true
                }
            }
            """

        Then the file "overriden/hive/dir/.hive/helloaws.ke" should contain:
            """
            {
                "instances": 3,
                "tasks": [
                    {
                        "type": "shell",
                        "inline": "echo \"ZERG RUSH PRIME!\""
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
                            "aws.security_groups = [ \"#{ENV['AWS_SECURITY_GROUP']}\" ]",
                            "override.ssh.username = 'ubuntu'",
                            "override.ssh.private_key_path = \"#{ENV['AWS_PRIVATE_KEY_PATH']}\""
                        ]
                    },
                    "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                    "private_network": false
                }
            }
            """
        And the exit status should be 0