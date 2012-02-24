require 'vagrant'

module ServerSupport
  def server
    @server ||= Server.instance
  end

  class Server
    class << self
      def instance
        Server.new
      end
    end

    def private_key_path
      env.default_private_key_path
    end

    def run(command, user = 'vagrant')
      output = nil
      env.primary_vm.channel.sudo("su - #{user} -c '#{command}'") do |type, data|
        output = data if type == :stdout
      end
      output
    end

    def has_user?(name)
      test? "id -u #{name}"
    end

    def has_group?(name)
      test? "id -g #{name}"
    end

    def has_directory?(path)
      test? "[ -d #{path} ]"
    end

    def has_file?(path)
      test? "[ -f #{path} ]"
    end

    def test?(command)
      env.primary_vm.channel.test(command)
    end

    def env
      @env ||= Vagrant::Environment.new
    end
  end
end

World(ServerSupport)