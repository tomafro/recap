# The `recap/recipes/rails` builds on the [ruby](recap/recipes/ruby.html)
# recipe, which provides support for both `bundler` and `foreman`.
require 'recap/recipes/ruby'

# It adds to this with a number of rails specific tasks.
module Recap::Rails
  extend Recap::Support::Namespace

  namespace :rails do
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

    after "deploy:clone_code", "rails:db:load_schema"
    after "deploy:update_code", "rails:db:migrate"
  end
end
