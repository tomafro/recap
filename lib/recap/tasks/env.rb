require 'recap'

# Environment variables are a useful way to set application configuration, such as database passwords
# or S3 keys and secrets.  [recap](http://github.com/freerange/recap) stores these extra variables in
# a special file, usually stored at `$HOME/.env`.  This file is loaded each time the shell starts by
# adding the following to the user's `.profile`:
#
#     . $HOME/.recap
#
# The `.recap` script is automatically generated in the bootstrap process.

module Recap::Tasks::Env
  extend Recap::Support::Namespace

  def set_default_env(name, value)
    default_env[name] = value
  end

  def default_env
    @default_env ||= {}
  end

  namespace :env do
    set(:environment_file) { "/home/#{application_user}/.env" }

    def current_environment
      @current_environment ||= begin
        if deployed_file_exists?(environment_file)
          Recap::Support::Environment.from_string(capture("cat #{environment_file}"))
        else
          Recap::Support::Environment.new
        end
      end
    end

    task :default do
      if current_environment.empty?
        puts "There are no config variables set"
      else
        puts "The config variables are:"
        puts
        puts current_environment
      end
    end

    task :set do
      env = ARGV[1..-1].inject(current_environment) do |env, string|
        env.set_string(string)
        logger.debug "Setting #{string}"
        logger.debug "Env is now: #{env}"
        env
      end

      default_env.each do |name, value|
        env.set(name, value) unless env.get(name)
      end

      if env.empty?
        as_app "rm -f #{environment_file}", "~"
      else
        put_as_app env.to_s, environment_file
      end
      default
    end

    task :reset do
      as_app "rm -f #{environment_file}", "~"
      set
    end

    task :edit do
      content = edit_file environment_file
      env = Recap::Environment.from_string(content)

      default_env.each do |name, value|
        env.set(name, value) unless env.get(name)
      end

      if env.empty?
        as_app "rm -f #{environment_file}", "~"
      else
        put_as_app env.to_s, environment_file
      end
      default
    end
  end
end