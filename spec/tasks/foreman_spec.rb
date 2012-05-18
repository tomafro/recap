require 'spec_helper'
require 'recap/tasks/foreman'

describe Recap::Tasks::Foreman do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.foreman
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  let :commands do
    sequence('commands')
  end

  before do
    config.set :application, 'example-app'
    config.set :application_user, 'example-app-user'
    config.set :deploy_to, deploy_to
    Recap::Tasks::Foreman.load_into(config)
  end

  describe 'Settings' do
    describe '#procfile' do
      it 'defaults Procfile' do
        config.procfile.should eql('Procfile')
      end
    end

    describe '#foreman_export_format' do
      it 'defaults to upstart' do
        config.foreman_export_format.should eql('upstart')
      end
    end

    describe '#foreman_template' do
      it 'defaults to nil' do
        config.foreman_template.should be_nil
      end
    end

    describe '#foreman_template_option' do
      it 'is nil if foreman_template is unset' do
        config.foreman_template_option.should be_nil
      end

      it 'points at the foreman_template if set' do
        config.set :foreman_template, '/path/to/template'
        config.foreman_template_option.should eql('--template /path/to/template')
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
        config.set :foreman_template_option, ''
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

      it 'includes --template option if set' do
        config.set :foreman_template_option, '--template /path/to/template'
        config.foreman_export_command.index("--template /path/to/template").should_not be_nil
      end
    end
  end

  describe 'Tasks' do
    describe 'foreman:export:if_changed' do
      before :each do
        namespace.stubs(:trigger_update?).with(config.procfile).returns(false)
      end

      it 'calls foreman:export if the Procfile has changed' do
        namespace.stubs(:trigger_update?).with(config.procfile).returns(true)
        namespace.export.expects(:default)
        config.find_and_execute_task('foreman:export:if_changed')
      end

      it 'skips foreman:export if the Procfile has not changed' do
        namespace.export.expects(:default).never
        config.find_and_execute_task('foreman:export:if_changed')
      end

      describe 'foreman_template is set' do
        before :each do
          config.set :foreman_template, 'config/foreman/upstart'
          namespace.stubs(:trigger_update?).with(config.foreman_template).returns(false)
        end

        it 'calls foreman:export if any of the templates have changed' do
          namespace.stubs(:trigger_update?).with(config.foreman_template).returns(true)
          namespace.export.expects(:default)
          config.find_and_execute_task('foreman:export:if_changed')
        end
      end
    end

    describe 'foreman:export' do
      it 'runs the foreman export command, then moves the exported files to the export location' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(true)
        namespace.expects(:sudo).with("mkdir -p #{config.deploy_to}/log").in_sequence(commands)
        namespace.expects(:sudo).with("chown #{config.application_user}: #{config.deploy_to}/log").in_sequence(commands)
        namespace.expects(:as_app).with(config.foreman_export_command).in_sequence(commands)
        namespace.expects(:sudo).with("rm -f #{config.foreman_export_location}/#{config.application}*").in_sequence(commands)
        namespace.expects(:sudo).with("cp #{config.foreman_tmp_location}/* #{config.foreman_export_location}").in_sequence(commands)
        config.find_and_execute_task('foreman:export')
      end

      it 'does nothing if no Procfile exists' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(false)
        namespace.expects(:as_app).never
        namespace.expects(:sudo).never
        config.find_and_execute_task('foreman:export')
      end
    end

    describe 'foreman:start' do
      it 'starts the application' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(true)
        namespace.expects(:sudo).with('start example-app')
        config.find_and_execute_task('foreman:start')
      end

      it 'does nothing if no Procfile exists' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(false)
        namespace.expects(:sudo).never
        config.find_and_execute_task('foreman:start')
      end
    end

    describe 'foreman:stop' do
      it 'starts the application' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(true)
        namespace.expects(:sudo).with('stop example-app')
        config.find_and_execute_task('foreman:stop')
      end

      it 'does nothing if no Procfile exists' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(false)
        namespace.expects(:sudo).never
        config.find_and_execute_task('foreman:stop')
      end
    end

    describe 'foreman:restart' do
      it 'restart or starts the application' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(true)
        namespace.expects(:sudo).with('restart example-app || sudo start example-app')
        config.find_and_execute_task('foreman:restart')
      end

      it 'does nothing if no Procfile exists' do
        namespace.stubs(:deployed_file_exists?).with(config.procfile).returns(false)
        namespace.expects(:sudo).never
        config.find_and_execute_task('foreman:restart')
      end
    end
  end
end
