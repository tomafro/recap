require 'spec_helper'

describe Recap::Bundler do
  let :config do
    Capistrano::Configuration.new
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  before do
    config.set :deploy_to, deploy_to
    Recap::Bundler.load_into(config)
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
      it 'defaults to development, test and assets groups' do
        config.bundle_without.should eql("development test assets")
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
      it 'run bundle_install_command as the app if the Gemfile.lock exists' do
        config.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(true)
        config.expects(:as_app).with(config.bundle_install_command)

        config.find_and_execute_task('bundle:install')
      end

      it 'skips bundle_install if the Gemfile missing' do
        config.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(false)
        config.expects(:as_app).never

        config.find_and_execute_task('bundle:install')
      end
    end

    describe 'bundle:install:if_changed' do
      it 'calls bundle_install if the Gemfile.lock has changed' do
        config.stubs(:deployed_file_changed?).with(config.bundle_gemfile_lock).returns(true)
        config.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(true)
        config.expects(:as_app).with(config.bundle_install_command)

        config.find_and_execute_task('bundle:install:if_changed')
      end

      it 'skips bundle_install if the Gemfile missing' do
        config.stubs(:deployed_file_changed?).with(config.bundle_gemfile_lock).returns(false)
        config.stubs(:deployed_file_exists?).with(config.bundle_gemfile_lock).returns(false)
        config.expects(:as_app).never

        config.find_and_execute_task('bundle:install')
      end
    end
  end
end