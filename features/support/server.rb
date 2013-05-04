require 'net/ssh'
require 'tempfile'

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
      ssh_config[:keys].first
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
      run(command)
      run('echo $?').to_i == 0
    end

    def run(command)
      stdout = ''
      ssh.exec!("PATH=/opt/ruby/bin:$PATH #{command}") do |channel, stream, data|
        stdout << data if stream == :stdout
      end
      stdout
    end

    def ssh_config
      Net::SSH.configuration_for('default', ssh_config_file.path)
    end

    private

    def ssh
      @ssh ||= Net::SSH.start 'default', nil, config: ssh_config_file.path
    end

    def ssh_config_file
      @config_file ||= begin
        file = Tempfile.new('ssh-config')
        `vagrant ssh-config > #{file.path}`
        file
      end
    end
  end
end

World(ServerSupport)
