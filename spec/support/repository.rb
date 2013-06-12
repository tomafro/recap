class Repository
  attr_reader :name

  def initialize(name)
    @name = name
    FileUtils.rm_rf path
    FileUtils.mkdir_p path
    git 'init'
  end

  def path(file = '')
    File.expand_path File.join('test-vm/share/projects/', name, file)
  end

  def versions
    git('log --pretty=format:"%H"').split("\n")
  end

  def write(file, content = '')
    File.write path(file), content
  end

  def write_and_commit(file, content = '')
    write file, content
    commit_all
  end

  def commit_all
    git "add --all"
    git "commit -m 'Updated project'"
  end

  private

  def git(command)
    `cd #{path} && git #{command}`
  end
end
