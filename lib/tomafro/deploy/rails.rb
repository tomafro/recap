require 'tomafro/deploy'

Capistrano::Configuration.instance(:must_exist).load do
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
  end

  after "deploy:clone_code", "rails:db:load_schema"
  after "deploy:update_code", "rails:db:migrate"
end
