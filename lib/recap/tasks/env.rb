# Recap encourages the storage of application configuration (such as database passwords, S3 keys and
# other things that change between deploys) in environment variables.
# [12factor.net](http://www.12factor.net) has [a good set of reasons](http://www.12factor.net/config)
# why this is desirable).
#
# To enable this, [recap](https://github.com/freerange/recap) stores these configuration variables
# in `.env`, and adds a script to the user's `.profile` to set these whenever the environment is
# loaded (see [bootstrap](bootstrap.html)).
#
# Variables can be set in two ways.  First, using either the `env:set` or `env:edit` tasks,
# the `.env` file can be directly manipulated.  This is generally the best way to manipulate
# these values.
#
# The other way to set them is using the `set_default_env` method directly in your `Capfile`.
# This sets a default value, which will be used if no other value is set.  An example where
# this might be useful is where you know your app should run using ruby 1.8.7.  Using
# `set_default_env :RBENV_VERSION, "1.8.7-p352"` in your `Capfile` will use this ruby as the default.
# Then, in a different deployment you might want to test using a different version of ruby,
# so could use `cap env:set RBENV_VERSION=1.9.3-p0` to override the default.

require 'recap/tasks'

module Recap::Tasks::Env
  extend Recap::Support::Namespace

  namespace :env do
    _cset(:environment_file) { "/home/#{application_user}/.env" }

    # The `env` task displays the current configuration environment.  Note that this doesn't
    # include all environment variables, only those stored in the `.env` file.
    desc 'View the current server environment'
    task :default do
      if current_environment.empty?
        puts "There are no config variables set"
      else
        puts "The config variables are:"
        puts
        puts current_environment
      end
    end

    # A single variable can be set using the `env:set` task, followed by a variable and value,
    # for example `cap env:set VARIABLE=VALUE`.  Variables can be unset using `cap env:set VARIABLE=`.
    desc 'Set a variable in the environment, using "cap env:set VARIABLE=VALUE".  Unset using "cap env:set VARIABLE="'
    task :set do
      env = env_argv.inject(current_environment) do |env, string|
        env.set_string(string)
        logger.debug "Setting #{string}"
        logger.debug "Env is now: #{env}"
        env
      end
      update_remote_environment(env)
      default
    end

    # The `env:edit` task uses your EDITOR to load the `.env` file locally, saving any changes
    # to all servers.
    desc 'Edit the server environment'
    task :edit do
      content = edit_file environment_file
      env = Recap::Support::Environment.from_string(content)
      update_remote_environment(env)
      default
    end

    # The `env:reset` tasks reverts all variables back to their default values.  If there is no default value,
    # the variable will be removed.
    desc 'Reset the server environment to its default values'
    task :reset do
      as_app "rm -f #{environment_file}", "~"
      set
    end

    def current_environment
      @current_environment ||= begin
        if deployed_file_exists?(environment_file, '.')
          Recap::Support::Environment.from_string(capture("cat #{environment_file}"))
        else
          Recap::Support::Environment.new
        end
      end
    end

    def update_remote_environment(env)
      logger.debug "Env is now #{env}"

      default_env.each do |name, value|
        env.set(name, value) unless env.get(name)
      end

      if env.empty?
        as_app "rm -f #{environment_file}", "~"
      else
        put_as_app env.to_s, environment_file
      end
    end
  end

  # Default environment values can be set by a recipe using `set_default_env :NAME, 'VALUE'`.
  def set_default_env(name, value)
    default_env[name.to_s] = value
  end

  def default_env
    @default_env ||= {}
  end

  def env_argv
    ARGV[1..-1]
  end
end
