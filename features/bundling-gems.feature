Feature: Bundling gems in ruby projects

  Scenario: Deploying a project with a Gemfile

    Given a new ruby project and a bootstrapped server
    And a bundle requiring version "1.0" of "example-gem"
    When I run "cap deploy:setup deploy"
    Then the project should be deployed
    And the deployed project should include version "1.0" of "example-gem"

  Scenario: Updating a project bundle

    Given a new ruby project and a bootstrapped server
    And a bundle requiring version "1.0" of "example-gem"
    And I run "cap deploy:setup deploy"
    When I update the bundle to require version "1.1" of "example-gem"
    And I run "cap deploy"
    Then the deployed project should include version "1.1" of "example-gem"
