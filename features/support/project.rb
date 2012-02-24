require 'fileutils'
require 'faker'
require 'timecop'

module ProjectSupport
  def project
    @project ||= Project.new(server)
  end

  class Project
    def initialize(server = Server.instance)
      @server = server
      FileUtils.rm_rf repository_path
      git 'init'
      write_capfile
    end

    def name
      @name ||= Faker::Name.first_name.downcase
    end

    def repository_path
      'test-vm/share/' + name
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

    def write_capfile(content = '')
      commit_file 'Capfile', %{
  require 'recap/deploy'

  set :user, 'vagrant'

  server '127.0.0.1', :web

  ssh_options[:port] = 2222
  ssh_options[:keys] = ['#{@server.private_key_path}']

  set :application, '#{name}'
  set :repository, '/recap/share/#{name}'
      }
    end

    def capfile_location
      repository_path + '/Capfile'
    end

    def deployment_path(path = "")
      "/home/#{name}/apps/#{name}/#{path}"
    end

    def deployed_version
      (@server.run "cd #{deployment_path} && git rev-parse HEAD").strip
    end

    def run_cap(command)
      Timecop.travel 60 # Make sure tags are unique
      `cap -l STDOUT -f #{capfile_location} #{command}`
      raise "Exit code returned running 'cap #{command}'" if $?.exitstatus != 0
    end

    def git(command)
      FileUtils.mkdir_p repository_path
      FileUtils.chdir repository_path do
        `git #{command}`
      end
    end

    def read_deployed_file(path)
      @server.run "cat #{deployment_path(path)}"
    end
  end
end

World(ProjectSupport)
