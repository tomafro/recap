# Recap has a number of requirements on your server before you can deploy applications
# with it.  These include:
#
# - Each application needs its own account on the server.  The full account environment
#   is loaded whenever an application command or process is run, so this is the place where
#   other application specific configuration should happen.
# - Each deploying user needs a personal account on the server which they should be able to
#   ssh into.
# - This personal account needs to be able to `sudo`, both to switch to the application user
#   and to run other administrative commands.

require 'recap/tasks'

module Recap::Tasks::Bootstrap
  extend Recap::Support::Namespace

  # The bootstrap namespace has a couple of task that help configure application and personal accounts
  # to meet these requirements.
  namespace :bootstrap do
    _cset(:remote_username) { capture('whoami').strip }
    _cset(:application_home) { "/home/#{application_user}"}

    # The `bootstrap:application` task sets up the account on the server the application itself uses.  This
    # account should be dedicated to running this application.
    desc 'Sets up the server account used by the application, including home directory and environment support'
    task :application do
      # If the account doesn't already exist on the server, the task creates it.
      if exit_code("id #{application_user}").strip != "0"
        sudo "useradd #{application_user} -d #{application_home}"
      end

      # If the home directory doesn't exist, or isn't both readable and writable by members of the application
      # group (all the accounts allowed to deploy the app) then the task creates the directory and fixes
      # file permissions.
      sudo "mkdir -p #{application_home}"
      sudo "chown #{application_user}:#{application_group} #{application_home}"
      sudo "chmod 755 #{application_home}"

      # A script `.recap` is added to set the configuration environment (set with `env:set` and
      # `env:edit` tasks).  The script loads the `.env` file in the users home folder, creates
      # a new copy with `export ` prefixed to each line, and sources this new copy.
      put_as_app %{
if [ -s #{application_home}/.env ]; then
  sed -e 's/\\r//g' -e 's/^/export /g' #{application_home}/.env > #{application_home}/.recap-env-export
  . #{application_home}/.recap-env-export
fi
      }, "#{application_home}/.recap"

      # Finally, `.profile` needs to source the `.recap` script, so that the configuration environment is
      # available whenever the environment is loaded.
      as_app "touch .profile", "#{application_home}"

      if exit_code("grep '\\. #{application_home}/\\.recap' #{application_home}/.profile") != "0"
        as_app %{echo ". #{application_home}/.recap" >> .profile}, "#{application_home}"
      end
    end

    # The `bootstrap:user` task sets up the personal accounts of users who can deploy applications.
    # In order to deploy a particular app, the account's git configuration must be set (so
    # that releases can be tagged), and the account must be a member of the application group.
    desc 'Sets up the server account used by a deploying user'
    task :user do
      git_user_name = Recap::Support::ShellCommand.execute("git config user.name").strip
      git_user_email = Recap::Support::ShellCommand.execute("git config user.email").strip
      run "git config --global user.name '#{git_user_name}'"
      run "git config --global user.email '#{git_user_email}'"
      sudo "usermod --append -G #{application_group} #{remote_username}"

      if repository.match /github\.com/
        run "mkdir -p ~/.ssh; touch ~/.ssh/known_hosts; (ssh-keygen -f ~/.ssh/known_hosts -H -F github.com | grep 'github.com') || ssh-keyscan -H github.com > ~/.ssh/known_hosts"
      end
    end

    # The `bootstrap` task simply runs both the `bootstrap:application` and `bootstrap:user` tasks
    # in turn.
    task :default do
      application
      user
    end
  end
end
