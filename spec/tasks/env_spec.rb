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
      pending 'Tests not written'
    end
  end
end