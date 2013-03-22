require 'spec_helper'
require 'recap/tasks/ruby'

describe Recap::Tasks::Ruby do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.ruby
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  before do
    config.set :deploy_to, deploy_to
    Recap::Tasks::Ruby.load_into(config)
  end

  describe 'Tasks' do
    describe 'ruby:preflight' do
      before do
        namespace.stubs(:exit_code).with('grep rails path/to/deploy/to/Gemfile').returns("0")
      end

      it 'warns user if rails tasks not loaded for rails project' do
        namespace.logger.expects(:important)
        Recap::Tasks.stubs(:const_defined?).with(:Rails).returns(false)
        config.find_and_execute_task('ruby:preflight')
      end

      it 'skips warning if rails tasks have been loaded' do
        namespace.logger.expects(:important).never
        Recap::Tasks.stubs(:const_defined?).with(:Rails).returns(true)
        config.find_and_execute_task('ruby:preflight')
      end

      it 'skips warning if skip_rails_recipe_not_used_warning set' do
        namespace.logger.expects(:important).never
        Recap::Tasks.stubs(:const_defined?).with(:Rails).returns(false)
        config.set :skip_rails_recipe_not_used_warning, true
        config.find_and_execute_task('ruby:preflight')
      end

      it 'skips warning if rails project not detected' do
        namespace.logger.expects(:important).never
        namespace.stubs(:exit_code).with('grep rails path/to/deploy/to/Gemfile').returns("1")
        Recap::Tasks.stubs(:const_defined?).with(:Rails).returns(false)
        config.set :skip_rails_recipe_not_used_warning, true
        config.find_and_execute_task('ruby:preflight')
      end
    end
  end

  describe 'Callbacks' do
    before do
      Recap::Tasks::Preflight.load_into(config)
    end

    it 'runs `ruby:preflight` after `preflight:check`' do
      config.expects(:find_and_execute_task).with('ruby:preflight')
      config.trigger :after, config.find_task('preflight:check')
    end
  end
end