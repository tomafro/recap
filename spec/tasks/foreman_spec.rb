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
  end

  describe 'Tasks' do
    describe 'foreman:export:if_changed' do
      pending 'Tests not written'
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