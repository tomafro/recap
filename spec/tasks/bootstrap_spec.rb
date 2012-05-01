require 'spec_helper'
require 'recap/tasks/bootstrap'

describe Recap::Tasks::Bootstrap do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.bootstrap
  end

  let :commands do
    sequence('commands')
  end

  before do
    Recap::Tasks::Bootstrap.load_into(config)
  end

  describe 'Tasks' do
    describe 'bootstrap' do
      it 'runs bootsrap:application and bootstrap:user tasks' do
        namespace.expects(:application).in_sequence(commands)
        namespace.expects(:user).in_sequence(commands)
        config.find_and_execute_task('bootstrap')
      end
    end
  end
end