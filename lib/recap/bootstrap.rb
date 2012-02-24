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
      as_app "touch .profile", "~"

      if exit_code(%{grep 'if \\[ -s "\\$HOME\\/\\.env" ]; then export \\$(cat \\$HOME\\/\\.env); fi' $HOME/.profile}) != "0"
        as_app %{echo >> .profile && echo "if [ -s \\"\\$HOME/.env\\" ]; then export \\$(cat \\$HOME/.env); fi" >> .profile}, "~"
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