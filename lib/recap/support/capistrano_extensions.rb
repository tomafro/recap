require 'tempfile'

# These methods are used by recap tasks to run commands and detect when files have changed
# as part of a deployments

module Recap::Support::CapistranoExtensions
  # Run a command as the given user
  def as_user(user, command, pwd = deploy_to)
    sudo "su - #{user} -c 'cd #{pwd} && #{command}'"
  end

  # Run a command as root
  def as_root(command, pwd = deploy_to)
    as_user 'root', command, pwd
  end

  # Run a command as the application user
  def as_app(command, pwd = deploy_to)
    as_user application_user, command, pwd
  end

  # Put a string into a file as the application user
  def put_as_app(string, path)
    put string, "/tmp/recap-put-as-app"
    as_app "cp /tmp/recap-put-as-app #{path} && chmod g+rw #{path}", "/"
  ensure
    run "rm /tmp/recap-put-as-app"
  end

  def editor
    ENV['DEPLOY_EDITOR'] || ENV['EDITOR']
  end

  # Edit a file on the remote server, using a local editor
  def edit_file(path)
    if editor
      as_app "touch #{path} && chmod g+rw #{path}"
      local_path = Tempfile.new('deploy-edit').path
      get(path, local_path)
      Recap::Support::ShellCommand.execute_interactive("#{editor} #{local_path}")
      File.read(local_path)
    else
      abort "To edit a remote file, either the EDITOR or DEPLOY_EDITOR environment variables must be set"
    end
  end

  # Run a git command in the `deploy_to` directory
  def git(command)
    run "cd #{deploy_to} && umask 002 && sg #{application_group} -c \"git #{command}\""
  end

  # Capture the result of a git command run within the `deploy_to` directory
  def capture_git(command)
    capture "cd #{deploy_to} && umask 002 && sg #{application_group} -c 'git #{command}'"
  end

  def exit_code(command)
    capture("#{command} > /dev/null 2>&1; echo $?").strip
  end

  def exit_code_as_app(command, pwd = deploy_to)
    capture(%|sudo -p 'sudo password: ' su - #{application_user} -c 'cd #{pwd} && #{command} > /dev/null 2>&1'; echo $?|).strip
  end

  # Find the latest tag from the repository.  As `git tag` returns tags in order, and our release
  # tags are timestamps, the latest tag will always be the last in the list.
  def latest_tag_from_repository
    result = capture_git("tag | tail -n1").strip
    result.empty? ? nil : result
  end

  # Does the given file exist within the deployment directory?
  def deployed_file_exists?(path)
    exit_code("cd #{deploy_to} && [ -f #{path} ]") == "0"
  end

  # Has the given path been created or changed since the previous deployment?  During the first
  # successful deployment this will always return true.
  def deployed_file_changed?(path)
    return true unless latest_tag
    exit_code("cd #{deploy_to} && git diff --exit-code #{latest_tag} origin/#{branch} #{path}") == "1"
  end

  Capistrano::Configuration.send :include, self
end