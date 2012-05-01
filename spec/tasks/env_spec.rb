require 'spec_helper'

describe Recap::Tasks::Env do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.env
  end

  before do
    Recap::Tasks::Env.load_into(config)
  end

  describe 'Settings' do
    describe '#environment_file' do
      it 'defaults to /home/ + application_user + /.env' do
        config.set :application_user, 'marigold'
        config.environment_file.should eql('/home/marigold/.env')
      end
    end
  end

  describe 'Tasks' do
    describe 'env' do
      pending 'Tests not written'
    end

    describe 'env:set' do
      pending 'Tests not written'
    end

    describe 'env:edit' do
      before do
        config.set :environment_file, 'path/to/.env'
        namespace.stubs(:deployed_file_exists?).with(config.environment_file).returns(true)
        namespace.stubs(:capture).with("cat #{config.environment_file}").returns('')
      end

      it 'merges the edited environment with the default one' do
        config.set_default_env 'A', 'b'
        namespace.stubs(:edit_file).returns('X=Y')
        namespace.expects(:put_as_app).with(Recap::Support::Environment.from_string("A=b\nX=Y").to_s, config.environment_file)
        config.find_and_execute_task('env:edit')
      end

      it 'uploads the new environment' do
        namespace.stubs(:edit_file).returns('X=Y')
        namespace.expects(:put_as_app).with(Recap::Support::Environment.from_string('X=Y').to_s, config.environment_file)
        config.find_and_execute_task('env:edit')
      end

      it 'removes the environment if it is empty' do
        namespace.stubs(:edit_file).returns('')
        namespace.expects(:as_app).with("rm -f #{config.environment_file}", '~')
        config.find_and_execute_task('env:edit')
      end
    end
  end
end