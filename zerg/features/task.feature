Feature: Tasks
    When I clean a task
    As a CLI
    I want to see success 
      
    @no-clobber
    Scenario: Cleaning a task
        When I run `zerg init`
        When I run `zerg clean helloworld`
        Then the output should contain:
        """
        SUCCESS!
        """
        And the exit status should be 0

    Scenario: Cleaning a task that does not exist
        When I run `zerg init`
        When I run `zerg clean HRRGRHBGRGHLURGH`
        Then the output should contain:
        """
        ERROR: Task HRRGRHBGRGHLURGH not found in current hive!
        """
        And the exit status should be 1

    Scenario: Cleaning a task without hive
        When I run `zerg clean helloaws`
        Then the output should contain:
        """
        ERROR:
        """
        And the exit status should be 1

    Scenario: Running a task
        When I run `zerg init`
        When I run `zerg rush helloworld`
        Then the output should contain:
        """
        SUCCESS!
        """
        And the exit status should be 0

    Scenario: Halting a task with keepalive
        Given a file named "arubatask.ke" with:
        """
        {
            "instances": 1,
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
                        "virtualbox.memory = 256"
                    ]
                },
                "keepalive": true,
                "basebox": "http://files.vagrantup.com/precise32.box",
                "private_network": false
            }
        }
        """
        
        When I run `zerg init`
        When I run `zerg hive import arubatask.ke`
        When I run `zerg rush arubatask`
        Then the output should contain:
        """
        Will leave instances running.
        SUCCESS!
        """
        And the exit status should be 0

        When I run `zerg halt arubatask`
        Then the output should contain:
        """
        [zergling_0] Attempting graceful shutdown of VM...
        SUCCESS!
        """
        And the exit status should be 0

