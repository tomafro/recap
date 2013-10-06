# Before `recap` will work correctly, a small amount of setup work needs to be performed on
# all target servers.
#
# First, each user who can deploy the app needs to have an account on each server, and must be able
# to ssh into the box.  They'll also each need to be sudoers.
#
# Secondly, each deploying user should set their git `user.name` and `user.email`.  This can easily
# be done by running:
#
# `git config --global user.email "you@example.com"`
# `git config --global user.name "Your Name"`
#
# Finally, a user and group representing the application (and usually with the same name) should be
# created.  Where possible, the application user will run application code, while the group will own
# application specific files.  Each deploying user should be added to the application group.
#
# This preflight recipe checks each of these things in turn, and attempts to give helpful advice
# should a check fail.

require 'recap/tasks'

module Recap::Tasks::Preflight
  extend Recap::Support::Namespace

  namespace :preflight do
    # The preflight check is pretty quick, so run it before every `deploy:setup` and `deploy`.
    before 'deploy:setup', 'preflight:check'
    before 'deploy', 'preflight:check'

    _cset(:remote_username) { capture('whoami').strip }

    task :check do
      # First check the `application_user` exists.
      if exit_code("id #{application_user}").strip != "0"
        abort %{
The application user '#{application_user}' doesn't exist.  Did you run the `bootstrap` task?  You can also create this user by logging into the server and running:

    sudo useradd #{application_user}
\n}
      end

      # Then the `application_group`.
      if exit_code("id -g #{application_group}") != "0"
        abort %{
The application group '#{application_group}' doesn't exist.  Did you run the `bootstrap` task?  You can also create this group by logging into the server and running:

    sudo groupadd #{application_group}
    sudo usermod --append -G #{application_group} #{application_user}
\n}
      end

      # Check the git configuration exists.
      if capture('git config user.name || true').strip.empty? || capture('git config user.email || true').strip.empty?
        abort %{
Your remote user must have a git user.name and user.email set.  Did you run the `bootstrap` task?  You can also set these by logging into the server as #{remote_username} and running:

    git config --global user.email "you@example.com"
    git config --global user.name "Your Name"
\n}
      end

      # And finally check the remote user is a member of the `application_group`.
      unless capture('groups').split(" ").include?(application_group)
        abort %{
Your remote user must be a member of the '#{application_group}' group in order to perform deployments.  Did you run the `bootstrap` task?  You can also add yourself to this group by logging into the server and running:

    sudo usermod --append -G #{application_group} #{remote_username}
\n}
      end
    end
  end
end
