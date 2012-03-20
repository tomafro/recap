Before do
  FileUtils.rm_rf 'test-vm/share/projects'
  FileUtils.rm_rf 'test-vm/share/gems'
  `bundle exec vagrant sandbox on` unless ENV['SKIP_ROLLBACK']
end

After do
  `bundle exec vagrant sandbox rollback` unless ENV['SKIP_ROLLBACK']
  if project
    project.run_on_server "sudo stop #{project.name} || true"
    project.run_on_server "sudo rm -rf /etc/init/#{project.name}* || true"
  end
end

Given /^a new (ruby )?project and a bootstrapped server$/ do |project_type|
  type = (project_type || 'static').strip
  start_project server: server, capfile: { recap_require: "recap/#{type}" }
  project.run_cap 'bootstrap'
end

Given /^a deployed project$/ do
  start_project server: server
  project.run_cap 'bootstrap'
  project.run_cap 'deploy:setup deploy'
end

Given /^a bundle requiring version "([^"]*)" of "([^"]*)"$/ do |version, gem|
  project.add_gem_to_bundle(gem, version)
end

Given /^the variable "([^"]*)" is set to "([^"]*)"$/ do |name, value|
  project.run_cap "env:set #{name}=#{value}"
end

Given /^the project has an application process defined in a Procfile$/ do
  @application_process = 'an-application-process'
  project.add_foreman_to_bundle
  project.add_gem_to_bundle @application_process, '1.0.0'
  project.add_command_to_procfile 'process', "bin/#{@application_process} --server"
end

When /^I update the bundle to require version "([^"]*)" of "([^"]*)"$/ do |version, gem|
  project.add_gem_to_bundle(gem, version)
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

When /^I wait for the server to start$/ do
  sleep(5)
end

When /^I add a default environment variable "([^"]*)" with the value "([^"]*)" to the project$/ do |name, value|
  project.add_default_env_value_to_capfile(name, value)
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

Then /^the deployed project should include version "([^"]*)" of "([^"]*)"$/ do |version, gem|
  project.run_on_server("bin/#{gem} --version").strip.should eql(version)
end

Then /^the variable "([^"]*)" should be set (?:back )?to "([^"]*)"$/ do |name, value|
  project.run_on_server("sudo su - #{project.name} -c 'env | grep #{name}'").strip.should eql("#{name}=#{value}")
end

Then /^the variable "([^"]*)" should be set to the application's PATH$/ do |name|
  path = project.run_on_server("echo $PATH").strip
  project.run_on_server("sudo su - #{project.name} -c 'env | grep #{name}'").strip.should eql("#{name}=#{path}")
end

Then /^the variable "([^"]*)" should have no value$/ do |name|
  project.run_on_server("sudo su - #{project.name} -c 'env'").include?("#{name}=").should be_false
end

Then /^the project should own the running application process$/ do
  project.run_on_server("ps -U #{project.name} u").include?(@application_process).should be_true
end

Then /^the running application process should know that "([^"]*)" is set to "([^"]*)"$/ do |name, value|
  project.run_on_server("/usr/bin/curl localhost:3500/env | grep #{name}").strip.should eql("#{name}=#{value}")
end