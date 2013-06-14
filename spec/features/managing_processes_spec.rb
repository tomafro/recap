# Feature: Managing processes with foreman

#   Scenario: Running an application process
#     Given a new ruby project and a bootstrapped server
#     And the project has an application process defined in a Procfile
#     When I run "cap deploy:setup deploy"
#     Then the project should own the running application process

#   Scenario: Running processes can read environment variables
#     Given a new ruby project and a bootstrapped server
#     And the project has an application process defined in a Procfile
#     And the variable "MONSTER" is set to "tricorn"
#     When I run "cap deploy:setup deploy"
#     And I wait for the server to start
#     Then the variable "MONSTER" should be set to "tricorn"
#     Then the running application process should know that "MONSTER" is set to "tricorn"

require 'spec_helper'

describe 'managing processes' do
  let(:server) { Server.instance }
  let(:project) { Project.new(type: 'ruby', server: server) }

  before :each do
    puts server.run('which bundle')
    puts server.run('which ruby')
    puts server.run('which gem')
    puts server.run('ruby --version')
    puts server.run('gem --version')


    project.add_example_gem('example-gem', '1.0')
    project.add_gem('foreman', '0.63.0')

    project.repository.write_and_commit 'Procfile', %{
server: ./bin/example-gem --server
    }

    project.run_cap 'bootstrap'

    puts "hello"
    puts `sudo su - #{project.name} -c which ruby`
    puts `sudo su - #{project.name} -c which gem`
    puts `sudo su - #{project.name} -c which bundle`


    puts '>>>>>>>>>>>>'
    puts server.run('/usr/bin/ruby --version')

    puts server.run("sudo su - #{project.name} -c env")

    project.run_cap 'deploy:setup'
  end

  it 'declaring and running an application process' do
    project.run_cap 'deploy'

    processes_owned_by_project.include?("./bin/example-gem --server").should be_true
  end

  # it 'processes have access to environment variables' do
  #   project.run_cap 'env:set MONSTER=gargoyle'
  #   project.run_cap 'deploy'

  #   process_environment['MONSTER'].should eql('gargoyle')
  # end

  def processes_owned_by_project
    server.run("ps -U #{project.name} u")
  end

  def process_environment
    env = server.run("curl 'localhost:3500/env'")
    env.split.inject({}) do |result, var|
      key, value = *var.split("=")
      result[key] = value
      result
    end
  end

  after :each do
    server.run "sudo stop #{project.name}"
    server.run "rm -rf /etc/init/#{project.name}*"
  end
end

