Feature: Hive
  In order to verify or load hive configs
  As a CLI
  I want to always return nothing for now

  Scenario: Loading hive
    When I run `zerg hive load`
    Then the output should contain "nothing"

  Scenario: Verifying hive
    When I run `zerg hive verify`
    Then the output should contain "nothing"