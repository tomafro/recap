require 'spec_helper'

describe 'setting environment variables' do
  let(:server) { Server.instance }
  let(:project) { Project.new(type: 'ruby', server: server) }

  # it 'setting an environment variable' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'env:set SECRET=very-secure'
  #   app_env['SECRET'].should eql('very-secure')
  # end

  # it 'unsetting an environment variable' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'env:set SECRET=very-secure'
  #   project.run_cap 'env:set SECRET='
  #   app_env['SECRET'].should be_nil
  # end

  # it 'setting a variable based on an existing variable' do
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'env:set SUPER_PATH=\$PATH'
  #   app_env['SUPER_PATH'].should eql(app_env['PATH'])
  # end

  # it 'setting default environment variable values' do
  #   project.add_to_capfile "set_default_env 'DEFAULT_VARIABLE', 'default-value'"
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'env:set'
  #   app_env['DEFAULT_VARIABLE'].should eql('default-value')

  #   project.run_cap 'env:set DEFAULT_VARIABLE=different'
  #   app_env['DEFAULT_VARIABLE'].should eql('different')

  #   project.run_cap 'env:set DEFAULT_VARIABLE='
  #   app_env['DEFAULT_VARIABLE'].should eql('default-value')
  # end

  # it 'resetting the environment' do
  #   project.add_to_capfile "set_default_env 'DEFAULT_VARIABLE', 'default-value'"
  #   project.run_cap 'bootstrap'
  #   project.run_cap 'env:set DEFAULT_VARIABLE=non-default-value'
  #   project.run_cap 'env:set ANOTHER_VARIABLE=another-value'
  #   project.run_cap 'env:reset'

  #   app_env['DEFAULT_VARIABLE'].should eql('default-value')
  #   app_env['ANOTHER_VARIABLE'].should be_nil
  # end

  private

  def app_env
    env = server.run("sudo su - #{project.name} -c env")
    env.split.inject({}) do |result, var|
      key, value = *var.split("=")
      result[key] = value
      result
    end
  end
end
