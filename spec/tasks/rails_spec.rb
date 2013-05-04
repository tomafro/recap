require 'spec_helper'
require 'recap/tasks/rails'

describe Recap::Tasks::Rails do
  let :config do
    Capistrano::Configuration.new
  end

  let :namespace do
    config.rails
  end

  let :deploy_to do
    'path/to/deploy/to'
  end

  before do
    config.set :deploy_to, deploy_to
    config.stubs(:set_default_env)
    Recap::Tasks::Rails.load_into(config)
  end

  describe 'Settings' do
    describe '#asset_precompilation_triggers' do
      it 'includes app/assets, vendor/assets, Gemfile.lock and config' do
        namespace.asset_precompilation_triggers.include?('app/assets').should be_true
        namespace.asset_precompilation_triggers.include?('vendor/assets').should be_true
        namespace.asset_precompilation_triggers.include?('Gemfile.lock').should be_true
        namespace.asset_precompilation_triggers.include?('config').should be_true
      end
    end
  end

  describe 'Tasks' do
    describe 'rails:db:load_schema' do
      it 'loads the schema if db/schema.rb exists' do
        namespace.stubs(:deployed_file_exists?).with('db/schema.rb').returns(true)
        namespace.expects(:as_app).with('./bin/rake db:create db:schema:load')
        config.find_and_execute_task('rails:db:load_schema')
      end

      it 'does nothing if db/schema.rb does not exist' do
        namespace.stubs(:deployed_file_exists?).with('db/schema.rb').returns(false)
        namespace.expects(:as_app).never
        config.find_and_execute_task('rails:db:load_schema')
      end
    end

    describe 'rails:db:migrate' do
      it 'runs migrations if the schema has changed' do
        namespace.stubs(:deployed_file_exists?).with('db/schema.rb').returns(true)
        namespace.stubs(:trigger_update?).with('db/schema.rb').returns(true)
        namespace.expects(:as_app).with('./bin/rake db:migrate')
        config.find_and_execute_task('rails:db:migrate')
      end

      it 'does nothing if the schema has not changed' do
        namespace.stubs(:deployed_file_exists?).with('db/schema.rb').returns(true)
        namespace.stubs(:trigger_update?).with('db/schema.rb').returns(false)
        namespace.expects(:as_app).never
        config.find_and_execute_task('rails:db:migrate')
      end

      it 'does nothing if the schema does not exist' do
        namespace.stubs(:deployed_file_exists?).with('db/schema.rb').returns(false)
        namespace.stubs(:trigger_update?).with('db/schema.rb').returns(true)
        namespace.expects(:as_app).never
        config.find_and_execute_task('rails:db:migrate')
      end
    end

    describe 'assets:precompile:if_changed' do
      it 'calls assets:precompileassets:precompile if any of the triggers have changed' do
        config.set(:asset_precompilation_triggers, ['trigger-one', 'trigger-two'])
        namespace.stubs(:trigger_update?).with('trigger-one').returns(false)
        namespace.stubs(:trigger_update?).with('trigger-two').returns(true)
        namespace.assets.precompile.expects(:default)
        config.find_and_execute_task('rails:assets:precompile:if_changed')
      end

      it 'skips assets:precompile if none of the triggers have changed' do
        config.set(:asset_precompilation_triggers, ['trigger-one', 'trigger-two'])
        namespace.stubs(:trigger_update?).returns(false)
        namespace.assets.expects(:default).never
        config.find_and_execute_task('rails:assets:precompile:if_changed')
      end
    end

    describe 'assets:precompile' do
      it 'compiles assets on the server' do
        namespace.expects(:as_app).with('./bin/rake RAILS_GROUPS=assets assets:precompile')
        config.find_and_execute_task('rails:assets:precompile')
      end
    end
  end

  describe 'Callbacks' do
    before do
      Recap::Tasks::Deploy.load_into(config)
    end

    it 'runs `rails:db:migrate` after `deploy:update_code`' do
      config.stubs(:find_and_execute_task)
      config.expects(:find_and_execute_task).with('rails:db:migrate')
      config.trigger :after, config.find_task('deploy:update_code')
    end

    it 'runs `rails:assets:precompile` after `deploy:update_code`' do
      config.stubs(:find_and_execute_task)
      config.expects(:find_and_execute_task).with('rails:assets:precompile:if_changed')
      config.trigger :after, config.find_task('deploy:update_code')
    end
  end
end
