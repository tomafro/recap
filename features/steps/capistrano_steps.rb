Before do
  `bundle exec vagrant sandbox on` unless ENV['SKIP_ROLLBACK']
end

After do
  `bundle exec vagrant sandbox rollback` unless ENV['SKIP_ROLLBACK']
end

Given /^a new project and a bootstrapped server$/ do
  project.run_cap 'bootstrap'
end

Given /^a deployed project$/ do
  project.run_cap 'bootstrap'
  project.run_cap 'deploy:setup deploy'
end

When /^I run "cap ([^"]*)"$/ do |command|
  project.run_cap command
end

When /^I commit changes to the project$/ do
  project.commit_changes
end

When /^I commit and deploy changes to the project$/ do
  project.commit_changes
  project.run_cap 'deploy'
end

Then /^the project should be deployed$/ do
  project.deployed_version.should eql(project.latest_version)
end

Then /^the latest version of the project should be deployed$/ do
  project.deployed_version.should eql(project.latest_version)
end

Then /^the previous project version should be deployed$/ do
  project.deployed_version.should eql(project.previous_version)
end