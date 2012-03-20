Feature: Setting and unsetting environment config variables

  Scenario: Setting an environment variable

    Given a new project and a bootstrapped server
    When I run "cap env:set SECRET=very-secure"
    Then the variable "SECRET" should be set to "very-secure"

  @wip
  Scenario: Setting an environment variable based on an existing variable

    Given a new project and a bootstrapped server
    When I run "cap env:set SUPER_PATH=\$PATH"
    Then the variable "SUPER_PATH" should be set to the application's PATH

  Scenario: Unsetting a variable

    Given a new project and a bootstrapped server
    And the variable "SECRET" is set to "very-secure"
    When I run "cap env:set SECRET="
    Then the variable "SECRET" should have no value