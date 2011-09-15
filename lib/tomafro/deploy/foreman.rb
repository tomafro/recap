Capistrano::Configuration.instance(:must_exist).load do
  namespace :foreman do
    set(:procfile) {"#{deploy_to}/Procfile"}
    set(:foreman_export_format, "upstart")
    set(:foreman_export_location, "/etc/init")

    namespace :export do
      task :if_changed do
        if deployed_file_changed?(procfile)
          top.foreman.export.default
        end
      end

      task :default, :roles => :app do
        if deployed_file_exists?(procfile)
          tmp = "#{deploy_to}/tmp/foreman"
          as_app "./bin/foreman export #{foreman_export_format} #{tmp} --procfile #{procfile} --app #{application} --user #{application_user} --log #{deploy_to}/log"
          sudo "rm -f #{foreman_export_location}/#{application}*"
          sudo "cp #{tmp}/* #{foreman_export_location}"
        end
      end
    end

    task :start, :roles => :app do
      if deployed_file_exists?(procfile)
        sudo "start #{application}"
      end
    end

    task :restart, :roles => :app do
      if deployed_file_exists?(procfile)
        sudo "restart #{application} || sudo start #{application}"
      end
    end

    task :stop, :roles => :app do
      if deployed_file_exists?(procfile)
        sudo "stop #{application}"
      end
    end

    after 'deploy:update_code', 'foreman:export:if_changed'
    after 'deploy:restart', 'foreman:restart'
  end
end
