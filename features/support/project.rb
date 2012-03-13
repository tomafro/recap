require 'fileutils'
require 'faker'
require 'erb'

module ProjectSupport
  def project
    @project
  end

  def start_project(options = {})
    @project = Project.new(options)
  end

  class Template
    def initialize(template_name)
      @template_name = template_name
    end

    def template_root
      File.expand_path("../../templates/", __FILE__)
    end

    def to_s
      ERB.new(read_template).result(binding)
    end

    def write_to(path)
      full_path = File.expand_path(path)
      FileUtils.mkdir_p File.dirname(full_path)
      File.write(full_path, to_s)
    end

    def read_template
      template_path = File.join(template_root, @template_name)
      File.read(template_path)
    end
  end

  class Capfile < Template
    attr_reader :project, :recap_require

    def initialize(project, options = {})
      super('project/Capfile.erb')
      @project = project
      @recap_require = options[:recap_require] || 'recap/static'
    end
  end

  class Gemfile < Template
    attr_accessor :foreman
    attr_accessor :gems

    def initialize(gems = {})
      super('project/Gemfile.erb')
      @gems = gems
    end
  end

  class Procfile < Template
    attr_reader :name, :command

    def initialize(name, command)
      super('project/Procfile.erb')
      @name = name
      @command = command
    end
  end

  class BundledGem
    def initialize(gem, version)
      @gem = gem
      @version = version
      @output_path = File.expand_path("../../../test-vm/share/gems/#{gem}", __FILE__)
    end

    def generate
      FileUtils.mkdir_p @output_path
      FileUtils.chdir @output_path do
        GemBinary.new(@gem, @version).write_to "bin/#{@gem}"
        Gemspec.new(@gem, @version).write_to "#{@name}.gemspec"

        `git init`
        `git add --all`
        `git commit -m 'Committed version #{@version}'`
        `git tag #{@version}`
      end
    end

    class Gemspec < Template
      attr_reader :gem, :version

      def initialize(gem, version)
        super 'gem/gemspec.erb'
        @gem = gem
        @version = version
      end
    end

    class GemBinary < Template
      attr_reader :gem, :version

      def initialize(name, version)
        super 'gem/binary.erb'
        @gem = name
        @version = version
      end
    end
  end

  class Project
    def initialize(options = {})
      @server = options[:server]
      @gems = {}
      FileUtils.rm_rf repository_path
      git 'init'
      write_and_commit_file 'Capfile', Capfile.new(self, options[:capfile] || {})
    end

    def name
      @name ||= Faker::Name.first_name.downcase
    end

    def private_key_path
      @server.private_key_path
    end

    def latest_version
      committed_versions[0]
    end

    def previous_version
      committed_versions[1]
    end

    def committed_versions
      `cd #{repository_path} && git log --pretty=format:"%H"`.split("\n")
    end

    def write_and_commit_file(path, content = "")
      full_path = File.join(repository_path, path)
      FileUtils.mkdir_p File.dirname(full_path)
      File.write(full_path, content)
      commit_files(path)
    end

    def commit_files(*paths)
      git "add #{paths.join(' ')}"
      git "commit -m 'Added #{paths.join(' ')}'"
    end

    def repository_path(path = "")
      File.join('test-vm/share/projects/', name, path)
    end

    def deployment_path(path = "")
      File.join("/home/#{name}/apps/#{name}", path)
    end

    def deployed_version
      (@server.run "cd #{deployment_path} && git rev-parse HEAD").strip
    end

    def run_cap(command)
      `cap -l capistrano.log -f #{repository_path('Capfile')} #{command}`
      raise "Exit code returned running 'cap #{command}'" if $?.exitstatus != 0
    end

    def run_on_server(cmd)
      @server.run("cd #{deployment_path} && #{cmd}")
    end

    def git(command)
      FileUtils.mkdir_p repository_path
      FileUtils.chdir repository_path do
        `git #{command}`
      end
    end

    def gemfile
      @gemfile ||= Gemfile.new
    end

    def add_gem_to_bundle(gem, version)
      gemfile.gems[gem] = version
      BundledGem.new(gem, version).generate
      regenerate_bundle
    end

    def add_foreman_to_bundle
      gemfile.foreman = true
      regenerate_bundle
    end

    def regenerate_bundle
      write_and_commit_file 'Gemfile', gemfile
      # Nasty hack to generate a Gemfile.lock
      @server.run "cd /recap/share/projects/#{name} && bundle install"
      commit_files 'Gemfile.lock'
    end

    def add_command_to_procfile(name, command)
      write_and_commit_file 'Procfile', Procfile.new(name, command)
    end

    def commit_changes
      write_and_commit_file 'project-file', Faker::Lorem.sentence
    end
  end
end

World(ProjectSupport)
