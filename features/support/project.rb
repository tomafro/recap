require 'fileutils'
require 'faker'

module ProjectSupport
  def project
    @project ||= Project.new(server)
  end

  class Capfile
    def initialize(project, options = {})
      @project = project
      @require = options[:require] || 'recap/static'
    end

    def to_s
      %{
  require '#{@require}'

  # To connect to the vagrant VM we need to set up a few non-standard parameters, including the
  # vagrant SSH port and private key

  set :user, 'vagrant'

  ssh_options[:port] = 2222
  ssh_options[:keys] = ['#{@project.private_key_path}']

  server '127.0.0.1', :web

  # Each project has its own location shared between the host machine and the VM

  set :application, '#{@project.name}'
  set :repository, '/recap/share/#{@project.name}'

  # Finally, to ensure tests don't fail if deployments are made within a second of each other
  # which they can do when automated like this, we use a finer-grained release tag

  set(:release_tag) { Time.now.utc.strftime("%Y%m%d%H%M%S%L") }
}
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
  end
end

World(ProjectSupport)
