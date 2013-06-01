class Project
  attr_reader :name, :repository, :capfile

  def initialize(options = {})
    @name = Faker::Name.first_name.downcase
    @repository = Repository.new(name)
    @capfile = Capfile.new(name: name, type: 'static', ssh_config: options[:ssh_config])
    repository.write_and_commit('Capfile', capfile)
  end

  def repository_path(path = "")
    repository.path(path)
  end

  def deployment_path
    "/home/#{name}/app"
  end

  def run_cap(command)
    `cap -l capistrano.log -f #{repository_path('Capfile')} #{command}`
    raise "Exit code returned running 'cap #{command}'" if $?.exitstatus != 0
  end

  def latest_version
    repository.versions.first
  end
end
