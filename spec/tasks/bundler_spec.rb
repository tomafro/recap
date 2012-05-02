require 'spec_helper'

describe Recap::Tasks::Bundler do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.bundle
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  before do
    config.set :deploy_to, deploy_to
    Recap::Tasks::Bundler.load_into(config)
  end

  describe 'Settings' do
    describe '#bundle_gemfile' do
      it 'defaults to deploy_to + /Gemfile' do
        config.bundle_gemfile.should eql(deploy_to + '/Gemfile')
      end
    end

    describe '#bundle_gemfile_lock' do
      it 'defaults to bundle_gemfile + .lock' do
        config.set :bundle_gemfile, 'custom/Gemfile'
        config.bundle_gemfile_lock.should eql('custom/Gemfile.lock')
      end
    end

    describe '#bundle_path' do
      it 'defaults to deploy_to + /vendor/gems' do
        config.bundle_path.should eql(deploy_to + '/vendor/gems')
      end
    end

    describe '#bundle_without' do
      it 'defaults to development and test groups' do
        config.bundle_without.should eql("development test")
      end
    end

    describe '#bundle_install_command' do
      it 'takes --gemfile from the bundle_gemfile setting' do
        config.set :bundle_gemfile, 'path/to/bundle/Gemfile'
        config.bundle_install_command.include?(" --gemfile path/to/bundle/Gemfile ").should be_true
      end

      it 'takes --path from the bundle_path setting' do
        config.set :bundle_path, 'path/to/install/gems'
        config.bundle_install_command.include?(" --path path/to/install/gems ").should be_true
      end

      it 'takes --without from the bundle_without setting' do
        config.set :bundle_without, 'groups to skip'
        config.bundle_install_command.include?(" --without groups to skip").should be_true
      end

      it 'includes --deployment flag to ensure Gemfile.lock exists' do
        config.bundle_install_command.include?(" --deployment ").should be_true
      end

      it 'includes --binstubs flag to generate binary stubs used by other tasks' do
        config.bundle_install_command.include?(" --binstubs ").should be_true
      end

      it 'includes --quiet flag to reduce uneccessary noise' do
        config.bundle_install_command.include?(" --quiet ").should be_true
      end
    end
  end

  describe 'Tasks' do
    describe 'bundle:install' do
      it 'run bundle_install_command as the app if the Gemfile and Gemfile.lock exist' do
        namespace.stubs(:deployed_file_exists?).with(config.bundle_gemfile).returns(true)
        namespace.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(true)
        namespace.expects(:as_app).with(config.bundle_install_command)

        config.find_and_execute_task('bundle:install')
      end

      it 'skips bundle_install if the Gemfile missing' do
        namespace.stubs(:deployed_file_exists?).with(config.bundle_gemfile).returns(false)
        namespace.expects(:as_app).never

        config.find_and_execute_task('bundle:install')
      end

      it 'aborts with warning if Gemfile exists but Gemfile.lock doesn\'t' do
        namespace.stubs(:deployed_file_exists?).with(config.bundle_gemfile).returns(true)
        namespace.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(false)
        expected_message = 'Gemfile found without Gemfile.lock.  The Gemfile.lock should be committed to the project repository'
        namespace.install.expects(:abort).with(expected_message)
        namespace.find_and_execute_task('bundle:install')
      end
    end

    describe 'bundle:install:if_changed' do
      it 'calls bundle:install:default if the Gemfile.lock has changed' do
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile).returns(false)
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile_lock).returns(true)
        namespace.install.expects(:default)
        config.find_and_execute_task('bundle:install:if_changed')
      end

      it 'calls bundle:install:default if the Gemfile has changed' do
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile).returns(true)
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile_lock).returns(false)
        namespace.install.expects(:default)
        config.find_and_execute_task('bundle:install:if_changed')
      end

      it 'skips bundle_install if neither Gemfile nor Gemfile.lock have changed' do
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile).returns(false)
        namespace.stubs(:deployed_file_changed?).with(config.bundle_gemfile_lock).returns(false)
        namespace.install.expects(:default).never
        config.find_and_execute_task('bundle:install:if_changed')
      end
    end

    describe 'bundle:check_installed' do
      before do
        config.set(:application_user, 'fred')
      end

      it 'checks to see whether bundler is installed' do
        namespace.expects(:exit_code_as_app).with('bundle --version').returns("0")
        config.find_and_execute_task('bundle:check_installed')
      end

      it 'aborts with explanation if bundler command fails' do
        namespace.stubs(:exit_code_as_app).returns("1")
        namespace.expects(:abort).with("The application user 'fred' cannot execute `bundle`.  Please check you have bundler installed.")
        config.find_and_execute_task('bundle:check_installed')
      end
    end
  end

  describe 'Callbacks' do
    describe 'bundle:check_installed' do
      before do
        Recap::Tasks::Preflight.load_into(config)
      end

      it 'runs after `preflight:check`' do
        config.stubs(:find_and_execute_task)
        config.expects(:find_and_execute_task).with('bundle:check_installed')
        config.trigger :after, config.find_task('preflight:check')
      end
    end
  end
end