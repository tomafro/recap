# N.B. To get the environment loaded on every shell invocation add the following to .profile:
#
#     if [ -s "$HOME/.env" ]; then export $(cat $HOME/.env); fi
#
# This will eventually be done automatically

module Recap::Env
  extend Recap::Namespace

  namespace :env do
    set(:environment_file) { "/home/#{application_user}/.env" }

    def extract_environment(declarations)
      declarations.inject({}) do |env, line|
        if line =~ /\A([A-Za-z_]+)=(.*)\z/
          env[$1] = $2.strip
        end
        env
      end
    end

    def current_environment
      @current_environment ||= begin
        if deployed_file_exists?(environment_file)
          extract_environment(capture("cat #{environment_file}").split("\n"))
        else
          {}
        end
      end
    end

    def write_environment(env)
      env.keys.sort.collect do |v|
        "#{v}=#{env[v]}" unless env[v].nil? || env[v].empty?
      end.compact.join("\n")
    end

    task :default do
      puts write_environment(current_environment)
    end

    task :set do
      additions = extract_environment(ARGV[1..-1])
      env = write_environment(current_environment.merge(additions))
      if env.empty?
        as_app "rm -f #{environment_file}"
      else
        put_as_app env, environment_file
      end
    end

    task :edit do
      edit_file environment_file
    end
  end
end