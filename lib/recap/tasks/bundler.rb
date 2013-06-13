# The bundler recipe ensures that the application bundle is installed whenever the code is updated.

require 'recap/tasks/deploy'

module Recap::Tasks::Bundler
  extend Recap::Support::Namespace

  namespace :bundle do
    # Each bundle is declared in a `Gemfile`, by default in the root of the application directory.
    set(:bundle_gemfile) { "Gemfile" }

    # As well as a `Gemfile`, application repositories should also contain a `Gemfile.lock`.
    set(:bundle_gemfile_lock) { "#{bundle_gemfile}.lock" }

    # An application's gems are installed within the application directory.  By default they are
    # placed under `vendor/gems`.
    set(:bundle_path) { "#{deploy_to}/vendor/gems" }

    # Not all gems are needed for production environments, so by default the `development`, `test` and
    # `assets` groups are skipped.
    set(:bundle_without) { "development test" }

    # The main bundle install command uses all the settings above, together with the `--deployment`,
    # `--binstubs` and `--quiet` flags
    set(:bundle_install_command) { "bundle install --gemfile #{bundle_gemfile} --path #{bundle_path} --deployment --quiet --binstubs --without #{bundle_without}" }

    namespace :install do
      # After cloning or updating the code, we only install the bundle if the `Gemfile` or `Gemfile.lock` have changed.
      desc "Install the latest gem bundle only if Gemfile or Gemfile.lock have changed"
      task :if_changed do
        if trigger_update?(bundle_gemfile) || trigger_update?(bundle_gemfile_lock)
          top.bundle.install.default
        end
      end

      # Occassionally it's useful to force an install (such as if something has gone wrong in
      # a previous deployment).
      desc "Install the latest gem bundle"
      task :default do
        if deployed_file_exists?(bundle_gemfile)
          if deployed_file_exists?(bundle_gemfile_lock)
            as_app bundle_install_command
          else
            abort 'Gemfile found without Gemfile.lock.  The Gemfile.lock should be committed to the project repository'
          end
        else
          puts "Skipping bundle:install as no Gemfile found"
        end
      end
    end

    task :check_installed do
      puts exit_code_as_app('bundle --version', '.')
      if exit_code_as_app('bundle --version', '.') != "0"
        abort "The application user '#{application_user}' cannot execute `bundle`.  Please check you have bundler installed."
      end
    end
    after 'preflight:check', 'bundle:check_installed'

    # To install the bundle automatically each time the code is updated or cloned, hooks are added to
    # the `deploy:clone_code` and `deploy:update_code` tasks.
    after 'deploy:clone_code', 'bundle:install:if_changed'
    after 'deploy:update_code', 'bundle:install:if_changed'
  end
end
