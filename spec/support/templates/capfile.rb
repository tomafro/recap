class Capfile < Mustache
  def initialize(options)
    @options = options
  end

  def recap_require
    'recap/recipes/' + @options[:type]
  end

  def project_name
    @options[:name]
  end

  def private_key_path
    @options[:ssh_config][:keys].first
  end

  def host_name
    @options[:ssh_config][:host_name]
  end

  def port
    @options[:ssh_config][:port]
  end

  def user
    @options[:ssh_config][:user]
  end

  def additions
    @additions ||= []
  end
end
