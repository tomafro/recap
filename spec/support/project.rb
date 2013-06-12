class Project
  attr_reader :name, :repository, :capfile, :server

  def initialize(options = {})
    @name = Faker::Name.first_name.downcase
    @repository = Repository.new(name)
    @server = options[:server]
    @capfile = Capfile.new(name: name, type: options[:type] || 'static', ssh_config: server.ssh_config)
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

  def add_to_capfile(content)
    capfile.additions << content
    repository.write_and_commit('Capfile', capfile)
  end

  def gemfile
    @gemfile ||= Gemfile.new
  end

  def add_example_gem(name, version)
    example_gem = ExampleGem.new(name, version)
    example_gem.package_to(repository.path('vendor/cache'))
    add_gem_requirement(example_gem.name, example_gem.version)
  end

  def add_gem(name, version)
    add_gem_requirement(name, version)
  end

  def add_gem_requirement(name, version)
    gemfile.requirements[name] = version
    repository.write 'Gemfile', gemfile
    populate_gem_cache
    FileUtils.chdir repository.path do
      Bundler.with_clean_env do
        `bundle install --path .bundle/gems`
      end
    end
    repository.commit_all
  end

  def populate_gem_cache
    FileUtils.mkdir_p repository.path('vendor/cache')
    FileUtils.cp Dir.glob(File.expand_path("../gems/*.gem", __FILE__)), repository.path('vendor/cache')
  end
end
