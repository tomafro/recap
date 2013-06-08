# These tasks configure recap to use Foreman to stop, start and restart your application processes.
#
# You may declare the number of each process type to when defining servers:
#
#    server 'huge.example.com', :app, processes: { web: 10, queue: 10 }
#    server 'small.example.com', :app, processes: { web: 1 }

require 'recap/tasks/deploy'

module Recap::Tasks::Foreman
  extend Recap::Support::Namespace

  namespace :foreman do
    # Processes are declared in a `Procfile`, by default in the root of the application directory.
    set(:procfile) { "Procfile" }

    # Foreman startup scripts are exported in `upstart` format by default.
    set(:foreman_export_format, "upstart")

    # Scripts are exported (as the the application user) to a temporary location first.
    set(:foreman_tmp_location) { "#{deploy_to}/tmp/foreman" }

    # After exports, the scripts are moved to their final location, usually `/etc/init`.
    set(:foreman_export_location, "/etc/init")

    # The standard foreman export.
    set(:foreman_export_command) {
      "./bin/foreman export #{foreman_export_format} #{foreman_tmp_location} --procfile #{procfile} --app #{application} --user #{application_user} --log #{deploy_to}/log"
    }

    namespace :export do
      # After each deployment, the startup scripts are exported if the `Procfile` has changed.
      task :if_changed do
        if trigger_update?(procfile)
          top.foreman.export.default
        end
      end

      # To export the scripts, they are first generated in a temporary location, then copied to their final
      # destination.  This is done because the foreman export command needs to be run as the application user,
      # while sudo is required to write to `/etc/init`.
      desc 'Export foreman configuration'
      task :default do
        if deployed_file_exists?(procfile)
          find_servers_for_task(current_task).each do |server|
            sudo "mkdir -p #{deploy_to}/log", hosts: server
            sudo "chown #{application_user}: #{deploy_to}/log", hosts: server
            if server.options.has_key?(:processes)
              procs = server.options[:processes].map { |process, count| "#{process}=#{count}" }.join(',')
              # TODO: We could use Capistrano::Configuration#as_app here if latter passed options to underlying #sudo
              sudo "su - #{application_user} -c 'cd #{deploy_to} && #{foreman_export_command} --concurrency #{procs}'", hosts: server
            else
              sudo "su - #{application_user} -c 'cd #{deploy_to} && #{foreman_export_command}'", hosts: server
            end
            sudo "rm -f #{foreman_export_location}/#{application}*", hosts: server
            sudo "cp #{foreman_tmp_location}/* #{foreman_export_location}", hosts: server
          end
        end
      end
    end

    # Starts all processes that form the application.
    desc 'Start all application processes'
    task :start do
      if deployed_file_exists?(procfile)
        sudo "start #{application}"
      end
    end

    # Restarts all processes that form the application.
    desc 'Restart all application processes'
    task :restart do
      if deployed_file_exists?(procfile)
        sudo "restart #{application} || sudo start #{application}"
      end
    end

    # Stops all processes that form the application.
    desc 'Stop all application processes'
    task :stop do
      if deployed_file_exists?(procfile)
        sudo "stop #{application}"
      end
    end

    after 'deploy:update_code', 'foreman:export:if_changed'
    after 'deploy:restart', 'foreman:restart'
  end
end
