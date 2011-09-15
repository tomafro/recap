require 'tomafro/deploy'

Capistrano::Configuration.instance(:must_exist).load do
  # To use this recipe, both the application's name and its git repository are required.
  set(:rails_env, "production")

  def rails_rake(cmd)
    "RAILS_ENV=#{rails_env} cd #{deploy_to} && ./bin/rake #{cmd}"
  end

  namespace :rails do
    namespace :db do
      task :load do
        rails_rake 'db:schema:load'
      end

      task :migrate do
        rails_rake 'db:migrate'
      end
    end
  end

  after "deploy:clone_code", "rails:db:load"
  after "deploy:migrate", "rails:db:migrate"
end
