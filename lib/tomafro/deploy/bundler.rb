# The bundler recipe ensures that the application bundle is installed whenever the code is updated.

Capistrano::Configuration.instance(:must_exist).load do
  set(:bundle_gemfile) {"#{deploy_to}/Gemfile"}
  set(:bundle_gemfile_lock) {"#{deploy_to}/Gemfile.lock"}
  set(:bundle_dir) {"#{deploy_to}/.bundle/gems"}

  namespace :bundle do
    namespace :install do
      desc "Install the latest gem bundle only if Gemfile.lock has changed"
      task :if_changed do
        if deployed_file_changed?(bundle_gemfile_lock)
          top.bundle.install
        end
      end

      desc "Install the latest gem bundle"
      task :default do
        if deployed_file_exists?(bundle_gemfile)
          bundler "install --gemfile #{bundle_gemfile} --path #{bundle_dir} --deployment --quiet --without development test"
        else
          puts "Skipping bundle:install as no Gemfile found"
        end
      end
    end
  end

  # After deploy clones or updates the code, install the latest bundle (if needed)
  after 'deploy:clone_code', 'bundle:install:if_changed'
  after 'deploy:update_code', 'bundle:install:if_changed'
end
