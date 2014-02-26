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
                    "num_instances": 3,
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
                                        "inline": "cd /zerg/hosthome; touch helloworld.result; ping -c 3 192.168.50.1; echo \"ZERG RUSH FIRST!\""
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
                                "networks": [
                                    {
                                        "type": "private_network"
                                    },
                                    {
                                        "type": "public_network",
                                        "bridge": "en1: Wi-Fi (AirPort)"
                                    }         
                                ]

                            },
                            {
                                "basebox": "http://files.vagrantup.com/precise32.box",
                                "keepalive": false,
                                "tasks": [
                                    {
                                        "type": "shell",
                                        "inline": "echo \"ZERG RUSH OTHERS!\""
                                    }        
                                ]
                            }
                        ]
                    }
                }
                """

            Then the file ".hive/helloaws.ke" should contain:
                """
                {
                    "num_instances": 3,
                    "vm": {
                        "driver": {
                            "drivertype": "vagrant",
                            "driveroptions": [
                                {
                                    "providertype": "aws",
                                    "provider_options" : {
                                        "instance_type": "t1.micro",
                                        "access_key_id": "#{ENV['AWS_ACCESS_KEY_ID']}",
                                        "secret_access_key": "#{ENV['AWS_SECRET_ACCESS_KEY']}",
                                        "keypair_name": "#{ENV['AWS_KEY_PAIR']}",
                                        "ami": "ami-3fec7956",
                                        "region": "us-east-1",
                                        "security_groups": [ "#{ENV['AWS_SECURITY_GROUP']}" ]
                                    }
                                }
                            ]
                        },
                        "private_ip_range": "192.168.50.0/24",
                        "instances": [
                            {
                                "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                                "keepalive": false,
                                "tasks": [
                                    {
                                        "type": "shell",
                                        "inline": "echo \"ZERG RUSH PRIME!\""
                                    }        
                                ],
                                "ssh": {
                                    "username": "ubuntu",
                                    "private_key_path": "#{ENV['AWS_PRIVATE_KEY_PATH']}"      
                                }
                            }
                        ]
                    }
                }
                """
            And the exit status should be 0

    @announce
    Scenario: Verifying hive
        When I run `zerg init`
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
                "num_instances": 1,
                "vm": {
                    "driver": {
                        "drivertype": "vagrant",
                        "driveroptions": [
                            {
                                "providertype": "aws",
                                "provider_options" : {
                                    "instance_type": "t1.micro"
                                }
                            }
                        ]
                    },
                    "instances": [
                        {
                            "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                            "keepalive": false,
                            "tasks": [
                                {
                                    "type": "shell",
                                    "inline": "echo \"ARRRRRUUUUUUUUUUUBAAAAA!\""
                                }        
                            ]
                        }
                    ]
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
                "num_instances": 3,
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
                                    "inline": "cd /zerg/hosthome; touch helloworld.result; ping -c 3 192.168.50.1; echo \"ZERG RUSH FIRST!\""
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
                            "networks": [
                                {
                                    "type": "private_network"
                                },
                                {
                                    "type": "public_network",
                                    "bridge": "en1: Wi-Fi (AirPort)"
                                }         
                            ]

                        },
                        {
                            "basebox": "http://files.vagrantup.com/precise32.box",
                            "keepalive": false,
                            "tasks": [
                                {
                                    "type": "shell",
                                    "inline": "echo \"ZERG RUSH OTHERS!\""
                                }        
                            ]
                        }
                    ]
                }
            }
            """

        Then the file "overriden/hive/dir/.hive/helloaws.ke" should contain:
            """
            {
                "num_instances": 3,
                "vm": {
                    "driver": {
                        "drivertype": "vagrant",
                        "driveroptions": [
                            {
                                "providertype": "aws",
                                "provider_options" : {
                                    "instance_type": "t1.micro",
                                    "access_key_id": "#{ENV['AWS_ACCESS_KEY_ID']}",
                                    "secret_access_key": "#{ENV['AWS_SECRET_ACCESS_KEY']}",
                                    "keypair_name": "#{ENV['AWS_KEY_PAIR']}",
                                    "ami": "ami-3fec7956",
                                    "region": "us-east-1",
                                    "security_groups": [ "#{ENV['AWS_SECURITY_GROUP']}" ]
                                }
                            }
                        ]
                    },
                    "private_ip_range": "192.168.50.0/24",
                    "instances": [
                        {
                            "basebox": "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box",
                            "keepalive": false,
                            "tasks": [
                                {
                                    "type": "shell",
                                    "inline": "echo \"ZERG RUSH PRIME!\""
                                }        
                            ],
                            "ssh": {
                                "username": "ubuntu",
                                "private_key_path": "#{ENV['AWS_PRIVATE_KEY_PATH']}"      
                            }
                        }
                    ]
                }
            }
            """
        And the exit status should be 0