require 'spec_helper'

describe 'bundling gems' do
  let(:server) { Server.instance }
  let(:project) { Project.new(type: 'ruby', server: server) }

  before :each do
    FileUtils.rm_rf "test-vm/share/gems"
    FileUtils.rm_rf "test-vm/share/projects"
  end

  # it 'deploying a ruby project with a Gemfile' do
  #   project.add_example_gem('example-gem', '1.0')
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'deploy:setup'
  #   project.run_cap 'deploy'
  #   deployed_gem_version(project, 'example-gem').should eql('1.0')
  # end

  # it 'updating a project Gemfile' do
  #   project.add_example_gem('example-gem', '1.0')
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'deploy:setup'
  #   project.run_cap 'deploy'
  #   project.add_example_gem('example-gem', '1.1')
  #   project.run_cap 'deploy'
  #   deployed_gem_version(project, 'example-gem').should eql('1.1')
  # end

  def deployed_gem_version(project, gem)
    server.run("cd #{project.deployment_path} && ruby bin/#{gem} --version").strip
  end
end
