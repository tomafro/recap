require 'spec_helper'

describe Recap::Tasks::Deploy do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.deploy
  end

  before do
    Recap::Tasks::Deploy.load_into(config)
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
      it 'memoizes call to latest_tag_from_repository' do
        namespace.stubs(:latest_tag_from_repository).returns('abc123').then.returns('something-else')
        config.latest_tag.should eql('abc123')
        config.latest_tag.should eql('abc123')
      end
    end
  end

  describe 'Tasks' do
    let :application do
      'romulus'
    end

    let :repository do
      'git@github.com/example/romulus.git'
    end

    let :deploy_to do
      '/path/to/deploy/romulus/into'
    end

    before do
      config.set :application, application
      config.set :repository, repository
      config.set :deploy_to, deploy_to
    end

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
      it 'creates deploy_to dir, ensures it\'s group writable, then clones the repository into it' do
        namespace.expects(:as_app).with('mkdir -p ' + deploy_to, '~').in_sequence
        namespace.expects(:as_app).with('chmod g+rw ' + deploy_to).in_sequence
        namespace.expects(:git).with('clone ' + repository + ' .').in_sequence
        config.find_and_execute_task('deploy:clone_code')
      end
    end

    describe 'deploy' do
      it 'runs env:set, deploy:update_code, deploy:tag and then deploy:restart tasks' do
        env = stub('env')
        config.stubs(:env).returns(env)
        env.expects('set')
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
      it 'fetches latest changes, then resets to repository branch' do
        config.set :branch, 'release-branch'
        namespace.expects(:git).with('fetch').in_sequence
        namespace.expects(:git).with('reset --hard origin/release-branch').in_sequence
        namespace.find_and_execute_task('deploy:update_code')
      end
    end

    describe 'deploy:tag' do
      before do
        config.set :release_tag, 'abcd1234'
        config.set :release_message, 'Released into the wild'
      end

      it 'tags code with the release tag and release message' do
        namespace.expects(:git).with('tag abcd1234 -m \'Released into the wild\'')
        namespace.find_and_execute_task('deploy:tag')
      end
    end

    describe 'deploy:rollback' do
      it 'deletes latest tag, resets to previous tag and restarts' do
        config.stubs(:latest_tag).returns('release-2')
        config.stubs(:latest_tag_from_repository).returns('release-1')
        namespace.expects(:git).with('tag -d release-2').in_sequence
        namespace.expects(:git).with('reset --hard release-1').in_sequence
        namespace.expects(:restart).in_sequence
        namespace.find_and_execute_task('deploy:rollback')
      end

      it 'aborts if no tag has been deployed' do
        config.stubs(:latest_tag).returns(nil)
        lambda do
          namespace.find_and_execute_task('deploy:rollback')
        end.should raise_error(SystemExit, 'This app is not currently deployed')
      end
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