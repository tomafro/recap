require 'spec_helper'

describe Recap::Bootstrap do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.bootstrap
  end

  before do
    Recap::Env.load_into(config)
  end

  describe 'Tasks' do
    describe 'bootstrap' do
      it 'runs bootsrap:application and bootstrap:user tasks' do
        namespace.expects(:application).in_sequence
        namespace.expects(:user).in_sequence
        config.find_and_execute_task('bootstrap')
      end
    end

    describe 'bootstrap:user' do
      pending 'Tests not written'
    end

    describe 'bootstrap:application' do
      pending 'Tests not written'
    end
  end
end