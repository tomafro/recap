# The rails tasks build on standard deployment with support for running
# database migrations and precompiling assets.

require 'recap/tasks'

module Recap::Tasks::Rails
  extend Recap::Support::Namespace

  namespace :rails do
    # In traditional capistrano deployments, there's a configuration variable
    # `rails_env` to declare the rails environment.  Recap prefers using
    # environment variables for things like this, and rails handily supports
    # the `RAILS_ENV` variable.  As a default, `RAILS_ENV` is set to
    # `production`, but this can be changed using the `env:set` or
    # `env:edit` tasks.
    set_default_env :RAILS_ENV, 'production'

    namespace :db do
      task :load_schema do
        if deployed_file_exists?("db/schema.rb")
          as_app './bin/rake db:create db:schema:load'
        end
      end

      task :migrate do
        if deployed_file_changed?("db/schema.rb")
          as_app './bin/rake db:migrate'
        end
      end
    end

    # The `rails:assets:precompile` runs rails' asset precompilation rake task on
    # the server.  As assets come from so many sources (app/assets, vendor/assets
    # and from individual gems) it's not easy to determine whether compilation is
    # required, so it is done on every deploy.
    namespace :assets do
      task :precompile do
        as_app "./bin/rake RAILS_GROUPS=assets assets:precompile"
      end
    end

    # After the code is first cloned (during `deploy:setup`) load the schema into
    # the database.
    after "deploy:clone_code", "rails:db:load_schema"

    # On every deploy, after the code is updated, run the database migrations
    # and precompile the assets.
    after "deploy:update_code", "rails:db:migrate", "rails:assets:precompile"
  end
end