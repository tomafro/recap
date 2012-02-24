Feature: Deploying and rolling back deployments

  Scenario: Deploying for the first time

    Given a new project and a bootstrapped server
    When I run "cap deploy:setup deploy"
    Then the project should be deployed

  Scenario: Deploying after changes

    Given a deployed project
    When I commit changes to the project
    And I run "cap deploy"
    Then the latest version of the project should be deployed

  Scenario: Rolling back to the previous version

    Given a deployed project
    When I commit and deploy changes to the project
    And I run "cap deploy:rollback"
    Then the previous project version should be deployed