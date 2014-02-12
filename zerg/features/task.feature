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
