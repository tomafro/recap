Before do
  FileUtils.rm_rf 'test-vm/share/projects'
  FileUtils.rm_rf 'test-vm/share/gems'
  `bundle exec vagrant sandbox on` unless ENV['SKIP_ROLLBACK']
end

After do
  `bundle exec vagrant sandbox rollback` unless ENV['SKIP_ROLLBACK']
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