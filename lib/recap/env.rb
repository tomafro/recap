# N.B. To get the environment loaded on every shell invocation add the following to .profile:
#
#     if [ -s "$HOME/.env" ]; then export $(cat $HOME/.env); fi
#
# This will eventually be done automatically

module Recap::Env
  extend Recap::Namespace

  namespace :env do
    set(:environment_file) { "/home/#{application_user}/.env" }

    def current_environment
      @current_environment ||= begin
        if deployed_file_exists?(environment_file)
          Recap::Environment.from_string(capture("cat #{environment_file}"))
        else
          Recap::Environment.new
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
        env.merge(Recap::Environment.from_string(string))
        env
      end
      if env.empty?
        as_app "rm -f #{environment_file}"
      else
        put_as_app env.to_s, environment_file
      end
      default
    end

    task :edit do
      edit_file environment_file
      default
    end
  end
end