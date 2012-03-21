Feature: Setting and unsetting environment config variables

  Scenario: Setting an environment variable

    Given a new project and a bootstrapped server
    When I run "cap env:set SECRET=very-secure"
    Then the variable "SECRET" should be set to "very-secure"

  Scenario: Setting an environment variable based on an existing variable

    Given a new project and a bootstrapped server
    When I run "cap env:set SUPER_PATH=\$PATH"
    Then the variable "SUPER_PATH" should be set to the application's PATH

  Scenario: Setting default environment variable values

    Given a new project and a bootstrapped server
    When I add a default environment variable "PASSWORD" with the value "sup3r-s3cr3t" to the project
    And I run "cap env:set"
    Then the variable "PASSWORD" should be set to "sup3r-s3cr3t"

    When I run "cap env:set PASSWORD=anoth3r-passw0rd"
    Then the variable "PASSWORD" should be set to "anoth3r-passw0rd"

    When I run "cap env:set PASSWORD="
    Then the variable "PASSWORD" should be set back to "sup3r-s3cr3t"

  Scenario: Resetting back to default values

    Given a new project and a bootstrapped server
    And I add a default environment variable "PASSWORD" with the value "sup3r-s3cr3t" to the project

    When I run "cap env:set SECRET=something PASSWORD=anoth3r-passw0rd"
    Then the variable "SECRET" should be set to "something"
    And the variable "PASSWORD" should be set to "anoth3r-passw0rd"

    When I run "cap env:reset"
    Then the variable "PASSWORD" should be set back to "sup3r-s3cr3t"
    And the variable "SECRET" should have no value

  Scenario: Unsetting a variable

    Given a new project and a bootstrapped server
    And the variable "SECRET" is set to "very-secure"
    When I run "cap env:set SECRET="
    Then the variable "SECRET" should have no value