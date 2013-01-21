require 'spec_helper'
require 'recap/tasks/deploy'

describe Recap::Tasks::Deploy do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.deploy
  end

  let :commands do
    sequence('commands')
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
        namespace.expects(:abort).with(regexp_matches(/You must set the name of your application in your Capfile/))
        config.application
      end
    end

    describe '#repository' do
      it 'exits if accessed before being set' do
        namespace.expects(:abort).with(regexp_matches(/You must set the git respository location in your Capfile/))
        config.repository
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
      it 'defaults to an `app` folder within the application user home directory' do
        config.set :application, 'hare'
        config.set :application_user, 'rabbitfoot'
        config.deploy_to.should eql('/home/rabbitfoot/app')
      end
    end

    describe '#release_tag' do
      it 'defaults to the current timestamp' do
        now = Time.now
        Time.stubs(:now).returns(now)
        config.release_tag.should eql(Time.now.utc.strftime("%Y%m%d%H%M%S"))
      end
    end

    describe '#release_matcher' do
      it 'defaults to a matcher matching timestamps' do
        ("20130908123422" =~ config.release_matcher).should be_true
      end

      it 'does not match timestamp-like numbers with too many digits' do
        ("201309081234221" =~ config.release_matcher).should be_false
      end

      it 'does not match timestamp-like numbers with too few digits' do
        ("2013090812342" =~ config.release_matcher).should be_false
      end

      it 'does not match strings with non-numeric characters' do
        ("2013090a123421" =~ config.release_matcher).should be_false
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
      it 'runs env:set and deploy:clone_code tasks' do
        env = stub('env')
        config.stubs(:env).returns(env)
        env.expects('set')
        namespace.expects(:clone_code)
        config.find_and_execute_task('deploy:setup')
      end

      it 'calls deploy:clone_code task within a transaction' do
        namespace.stubs(:transaction)
        namespace.expects(:clone_code).never
        config.find_and_execute_task('deploy:setup')
      end

      it 'removes the deploy_to dir if a rollback is triggered' do
        config.stubs(:env).returns(stub_everything('env'))
        namespace.stubs(:as_app)
        namespace.expects(:as_app).with('rm -fr ' + deploy_to)
        namespace.stubs(:git).raises(RuntimeError)
        config.find_and_execute_task('deploy:setup') rescue RuntimeError
      end
    end

    describe 'deploy:clone_code' do
      it 'creates deploy_to dir, ensures it\'s group writable, then clones the repository into it' do
        config.set :branch, 'given-branch'

        namespace.expects(:as_app).with('mkdir -p ' + deploy_to, '~').in_sequence(commands)
        namespace.expects(:as_app).with('chmod g+rw ' + deploy_to).in_sequence(commands)
        namespace.expects(:git).with('clone ' + repository + ' .').in_sequence(commands)
        namespace.expects(:git).with('reset --hard origin/given-branch').in_sequence(commands)
        config.find_and_execute_task('deploy:clone_code')
      end
    end

    describe 'deploy' do
      it 'runs env:set, deploy:update_code, deploy:tag and then deploy:restart tasks' do
        env = stub('env')
        config.stubs(:env).returns(env)
        env.expects('set')
        namespace.expects(:update_code).in_sequence(commands)
        namespace.expects(:tag).in_sequence(commands)
        namespace.expects(:restart).in_sequence(commands)
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
        namespace.expects(:git).with('fetch').in_sequence(commands)
        namespace.expects(:git).with('reset --hard origin/release-branch').in_sequence(commands)
        namespace.find_and_execute_task('deploy:update_code')
      end
    end

    describe 'deploy:tag' do
      before do
        config.set :release_tag, '20120101012034'
        config.set :release_message, 'Released into the wild'
      end

      it 'tags code with the release tag and release message' do
        namespace.expects(:git).with('tag 20120101012034 -m \'Released into the wild\'')
        namespace.find_and_execute_task('deploy:tag')
      end

      it 'aborts if prospective release_tag does not match release_matcher' do
        config.set :release_matcher, /abcd/
        namespace.expects(:abort).with("The release_tag must be matched by the release_matcher regex, 20120101012034 doesn't match (?-mix:abcd)")
        namespace.stubs(:git)
        namespace.find_and_execute_task('deploy:tag')
      end
    end

    describe 'deploy:rollback' do
      it 'deletes latest tag, resets to previous tag and restarts' do
        config.stubs(:latest_tag).returns('release-2')
        config.stubs(:latest_tag_from_repository).returns('release-1')
        namespace.expects(:git).with('tag -d release-2').in_sequence(commands)
        namespace.expects(:git).with('reset --hard release-1').in_sequence(commands)
        namespace.expects(:restart).in_sequence(commands)
        namespace.find_and_execute_task('deploy:rollback')
      end

      it 'aborts if no tag has been deployed' do
        config.stubs(:latest_tag).returns(nil)
        namespace.rollback.expects(:abort).with('This app is not currently deployed')
        namespace.find_and_execute_task('deploy:rollback')
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