require 'fileutils'
require 'faker'
require 'erb'

module ProjectSupport
  def project
    @project ||= Project.new(server)
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
      @recap_require = options[:require] || 'recap/static'
    end
  end

  class Project
    def initialize(server = Server.instance)
      @server = server
      FileUtils.rm_rf repository_path
      git 'init'
      commit_file 'Capfile', Capfile.new(self)
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

    def commit_file(path, content = "")
      full_path = File.join(repository_path, path)
      FileUtils.mkdir_p File.dirname(full_path)
      File.write(full_path, content)
      git "add #{path}"
      git "commit -m 'Added #{path}'"
    end

    def repository_path(path = "")
      File.join('test-vm/share/', name, path)
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

    def git(command)
      FileUtils.mkdir_p repository_path
      FileUtils.chdir repository_path do
        `git #{command}`
      end
    end

    def commit_changes
      commit_file 'project-file', Faker::Lorem.sentence
    end
  end
end

World(ProjectSupport)
