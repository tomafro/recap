Capistrano::Configuration.instance(:must_exist).load do
  before 'deploy:setup', 'preflight:check'
  before 'deploy', 'preflight:check'

  set(:remote_username) { capture('whoami').strip }

  namespace :preflight do
    task :check do
      if capture("id #{application_user} > /dev/null 2>&1; echo $?").strip != "0"
        abort %{
The application user '#{application_user}' doesn't exist.  You can create this user by logging into the server and running:

    sudo useradd #{application_user}
\n}
      end

      if capture("id -g #{application_group} > /dev/null 2>&1; echo $?").strip != "0"
        abort %{
The application group '#{application_group}' doesn't exist.  You can create this group by logging into the server and running:

    sudo groupadd #{application_group}
    sudo usermod --append -G #{application_group} #{application_user}
\n}
      end

      if capture('git config user.name || true').strip.empty? || capture('git config user.email || true').strip.empty?
        abort %{
Your remote user must have a git user.name and user.email set.  You can set these by logging into the server as #{remote_username} and running:

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
\n}
      end

      unless capture('groups').split(" ").include?(application_group)
        abort %{
Your remote user must be a member of the '#{application_group}' group in order to perform deployments.  You can add yourself to this group by logging into the server and running:

    sudo usermod --append -G #{application_group} #{remote_username}
\n}
      end
    end
  end
end