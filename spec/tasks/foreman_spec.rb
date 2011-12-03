require 'spec_helper'

describe Recap::Foreman do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.foreman
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  before do
    config.set :application, 'example-app'
    config.set :application_user, 'example-app-user'
    config.set :deploy_to, deploy_to
    Recap::Foreman.load_into(config)
  end

  describe 'Settings' do
    describe '#procfile' do
      it 'defaults to deploy_to + /Procfile' do
        config.procfile.should eql(deploy_to + '/Procfile')
      end
    end

    describe '#foreman_export_format' do
      it 'defaults to upstart' do
        config.foreman_export_format.should eql('upstart')
      end
    end

    describe '#foreman_export_location' do
      it 'defaults to /etc/init' do
        config.foreman_export_location.should eql('/etc/init')
      end
    end

    describe '#foreman_tmp_location' do
      it 'defaults to deploy_to + /tmp/foreman' do
        config.foreman_tmp_location.should eql(deploy_to + '/tmp/foreman')
      end
    end

    describe '#foreman_export_command' do
      before :each do
        config.set :foreman_export_format, '<export-format>'
        config.set :foreman_tmp_location, '<tmp-location>'
      end

      it 'starts by exporting to the tmp location in the export format' do
        config.foreman_export_command.index('./bin/foreman export <export-format> <tmp-location>').should eql(0)
      end

      it 'includes --procfile option pointing to procfile' do
        config.set :procfile, '/custom/procfile/location'
        config.foreman_export_command.index("--procfile /custom/procfile/location").should_not be_nil
      end

      it 'includes --app option naming application' do
        config.set :application, 'my-application'
        config.foreman_export_command.index("--app my-application").should_not be_nil
      end

      it 'includes --user option pointing to procfile' do
        config.set :application_user, 'my-application-user'
        config.foreman_export_command.index("--user my-application-user").should_not be_nil
      end

      it 'includes --log option pointing to log location' do
        config.set :deploy_to, '/custom/deploy/location'
        config.foreman_export_command.index("--log /custom/deploy/location/log").should_not be_nil
      end
    end
  end

  describe 'Tasks' do
    describe 'foreman:export:if_changed' do
      it 'calls foreman:export if the Procfile has changed' do
        namespace.stubs(:deployed_file_changed?).with(config.procfile).returns(true)
        namespace.export.expects(:default)
        config.find_and_execute_task('foreman:export:if_changed')
      end

      it 'skips foreman:export if the Procfile has not changed' do
        namespace.stubs(:deployed_file_changed?).with(config.procfile).returns(false)
        namespace.export.expects(:default).never
        config.find_and_execute_task('foreman:export:if_changed')
      end
    end

    describe 'foreman:export' do
      pending 'Tests not written'
    end

    describe 'foreman:start' do
      pending 'Tests not written'
    end

    describe 'foreman:stop' do
      pending 'Tests not written'
    end

    describe 'foreman:restart' do
      pending 'Tests not written'
    end
  end
end