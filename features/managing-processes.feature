Feature: Managing processes with foreman

  Scenario: Running an application process
    Given a new ruby project and a bootstrapped server
    And the project has an application process defined in a Procfile
    When I run "cap deploy:setup deploy"
    Then the project should own the running application process

  Scenario: Running processes can read environment variables
    Given a new ruby project and a bootstrapped server
    And the project has an application process defined in a Procfile
    And the variable "MONSTER" is set to "tricorn"
    When I run "cap deploy:setup deploy"
    And I wait for the server to start
    Then the variable "MONSTER" should be set to "tricorn"
    Then the running application process should know that "MONSTER" is set to "tricorn"