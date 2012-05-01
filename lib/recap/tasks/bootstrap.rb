# These tasks are used to perform the initial configuration of your servers
# for deployment with recap.

module Recap::Tasks::Bootstrap
  extend Recap::Support::Namespace

  namespace :bootstrap do
    set(:remote_username) { capture('whoami').strip }
    set(:application_home) { "/home/#{application_user}"}

    task :default do
      application
      user
    end

    desc 'Sets up the server account used by the application, including home directory and environment support'
    task :application do
      if exit_code("id #{application_user}").strip != "0"
        sudo "useradd #{application_user} -d #{application_home}"
      end
      sudo "mkdir -p #{application_home}"
      sudo "chown #{application_user}:#{application_group} #{application_home}"
      sudo "chmod 755 #{application_home}"

      put_as_app %{
if [ -s "$HOME/.env" ]; then
  sed -e 's/\\r//g' -e 's/^/export /g' .env > .recap-env-export
  . $HOME/.recap-env-export
fi
      }, "#{application_home}/.recap"

      as_app "touch .profile", "~"

      if exit_code("grep '\\. $HOME/\\.recap' #{application_home}/.profile") != "0"
        as_app %{echo ". \\$HOME/.recap" >> .profile}, "~"
      end

      as_app "mkdir -p #{deploy_to}", "~"
    end

    desc 'Sets up the server account used by a deploying user'
    task :user do
      git_user_name = Recap::Support::ShellCommand.execute("git config user.name").strip
      git_user_email = Recap::Support::ShellCommand.execute("git config user.email").strip
      run "git config --global user.name '#{git_user_name}'"
      run "git config --global user.email '#{git_user_email}'"
      sudo "usermod --append -G #{application_group} #{remote_username}"
    end
  end
end