module Recap::Bootstrap
  extend Recap::Namespace

  namespace :bootstrap do
    set(:remote_username) { capture('whoami').strip }
    set(:application_home) { "/home/#{application_user}"}

    task :default do
      application
      user
    end

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

    task :user do
      run "git config --global user.name '#{`git config user.name`.strip}'"
      run "git config --global user.email '#{`git config user.email`.strip}'"
      sudo "usermod --append -G #{application_group} #{remote_username}"
    end
  end
end