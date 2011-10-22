require 'spec_helper'

describe Recap::Deploy do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.deploy
  end

  before do
    Recap::Deploy.load_into(config)
  end

  it 'configures capistrano to use ssh key forwarding' do
    config.ssh_options[:forward_agent].should be_true
  end

  it 'configures capistrano to use a pty session when running commands' do
    config.default_run_options[:pty].should be_true
  end

  describe 'Settings' do
    describe '#application' do
      it 'exits if accessed before being set' do
        lambda do
          config.application
        end.should raise_error(SystemExit)
      end
    end

    describe '#repository' do
      it 'exits if accessed before being set' do
        lambda do
          config.repository
        end.should raise_error(SystemExit)
      end
    end

    describe '#application_user' do
      it 'defaults to the name of the application' do
        config.set :application, 'rabbitfoot'
        config.application_user.should eql('rabbitfoot')
      end
    end

    describe '#application_group' do
      it 'defaults to the name of the application user' do
        config.set :application_user, 'rabbitfoot'
        config.application_group.should eql('rabbitfoot')
      end
    end

    describe '#branch' do
      it 'defaults to master' do
        config.branch.should eql('master')
      end
    end

    describe '#deploy_to' do
      it 'defaults to a folder within the application user home directory' do
        config.set :application, 'hare'
        config.set :application_user, 'rabbitfoot'
        config.deploy_to.should eql('/home/rabbitfoot/apps/hare')
      end
    end

    describe '#release_tag' do
      it 'defaults to the current timestamp' do
        now = Time.now
        Time.stubs(:now).returns(now)
        config.release_tag.should eql(Time.now.utc.strftime("%Y%m%d%H%M%S"))
      end
    end

    describe '#latest_tag' do
      it 'lazily calls latest_tag_from_repository' do
        pending 'Test not written'
      end
    end
  end

  describe 'Tasks' do
    describe 'deploy:setup' do
      it 'runs deploy:clone_code task' do
        namespace.expects(:clone_code)
        config.find_and_execute_task('deploy:setup')
      end

      it 'calls deploy:clone_code task within a transaction' do
        namespace.stubs(:transaction)
        namespace.expects(:clone_code).never
        config.find_and_execute_task('deploy:setup')
      end
    end

    describe 'deploy:clone_code' do
      pending 'Tests not written'
    end

    describe 'deploy' do
      it 'runs deploy:update_code, deploy:tag and then deploy:restart tasks' do
        namespace.expects(:update_code).in_sequence
        namespace.expects(:tag).in_sequence
        namespace.expects(:restart).in_sequence
        config.find_and_execute_task('deploy')
      end

      it 'calls deploy:update_code task within a transaction' do
        namespace.stubs(:transaction)
        namespace.expects(:update_code).never
        config.find_and_execute_task('deploy')
      end

      it 'calls deploy:tag task within a transaction' do
        namespace.stubs(:transaction)
        namespace.expects(:tag).never
        config.find_and_execute_task('deploy')
      end

      it 'calls restart outside the transaction' do
        namespace.stubs(:transaction)
        namespace.expects(:restart)
        config.find_and_execute_task('deploy')
      end
    end

    describe 'deploy:update_code' do
      pending 'Tests not written'
    end

    describe 'deploy:tag' do
      pending 'Tests not written'
    end

    describe 'deploy:rollback' do
      pending 'Tests not written'
    end

    describe 'deploy:restart' do
      it 'does nothing (but can be overidden by other recipes)' do
        namespace.expects(:run).never
        namespace.expects(:sudo).never
        namespace.find_and_execute_task('deploy:restart')
      end
    end

    describe 'deploy:destroy' do
      it 'removes all files from the deployment folder' do
        config.set :deploy_to, 'path/to/deploy/app'
        config.expects(:sudo).with('rm -rf path/to/deploy/app')
        config.find_and_execute_task('deploy:destroy')
      end
    end
  end
end