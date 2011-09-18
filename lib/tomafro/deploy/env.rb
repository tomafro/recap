# N.B. To get the environment loaded on every shell invocation add the following to .profile:
#
#     if [ -s "$HOME/.env" ]; then export $(cat $HOME/.env); fi
#
# This will eventually be done automatically

Capistrano::Configuration.instance(:must_exist).load do
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

    task :read do
      puts write_environment(current_environment)
    end

    task :set do
      additions = extract_environment(ARGV[1..-1])
      env = write_environment(current_environment.merge(additions))
      as_app "echo #{env.inspect} > #{environment_file}"
    end
  end
end