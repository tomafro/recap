Capistrano::Configuration.instance(:must_exist).load do
  namespace :env do
    set(:environment_file) { "/home/#{application_user}/.env" }

    def current_environment
      @current_environment ||= begin
        if deployed_file_exists?(environment_file)
          capture("cat #{environment_file}").split("\n").inject({}) do |env, line|
            if line =~ /\A([A-Za-z_]+)=(.*)\z/
              env[$1] = $2
            end
            env
          end
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
      additions = variables.inject({}) do |memo, (k, v)|
        memo[k.to_s[1..-1]] = v if k.to_s[0] == "_"
        memo
      end
      env = write_environment(current_environment.merge(additions))
      as_app "echo #{env.inspect} > #{environment_file}"
    end
  end
end


class Env
  def self.read(filename)
    if File.exists?(filename)
      File.read(filename).split("\n").inject({}) do |env, line|
        if line =~ /\A([A-Za-z_]+)=(.*)\z/
          env[$1] = $2
        end
        env
      end
    end
  end

  def self.write(environment, filename)
    environment.keys.sort.collect do |v|
      "#{v}=#{environment[v]}"
    end.join("\n")
  end
end