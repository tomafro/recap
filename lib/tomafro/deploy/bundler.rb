# Adds support for bundler within deployments.  This can be added to any `Capfile` by simply 
# requiring it, e.g.:
#
#     require 'tomafro/deploy/bundler'

Capistrano::Configuration.instance(:must_exist).load do
  set(:bundle_gemfile) {"#{deploy_to}/Gemfile"}
  set(:bundle_gemfile_lock) {"#{deploy_to}/Gemfile.lock"}
  set(:bundle_dir) {"#{deploy_to}/.bundle/gems"}

  namespace :bundle do
    namespace :install do
      desc "Install the latest gem bundle"
      task :default do
        bundler "install --gemfile #{bundle_gemfile} --path #{bundle_dir} --deployment --quiet --without development test"
      end

      desc "Install the latest gem bundle only if Gemfile.lock has changed"
      task :if_changed do
        if deployed_file_changed?(bundle_gemfile_lock)
          top.bundle.install
        end
      end
    end
  end

  # After deploy updates the code, install the latest bundle if required
  after 'deploy:update_code', 'bundle:install:if_changed'
end
