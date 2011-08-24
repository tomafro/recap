Capistrano::Configuration.instance(:must_exist).load do
  namespace :foreman do
    set(:procfile) {"#{deploy_to}/Procfile"}
    set(:foreman_export_format, "upstart")
    set(:foreman_export_location, "/etc/init")
    set(:procfile_exists?) { deployed_file_exists?(procfile) }

    task :export, :roles => :app do
      if procfile_exists?
        run_as_root "bundle exec foreman export #{foreman_export_format} #{foreman_export_location} --procfile #{procfile} --app #{application} --user #{application_user} --log #{deploy_to}/log"
      end
    end

    task :start, :roles => :app do
      if procfile_exists?
        sudo "start #{application}"
      end
    end

    task :restart, :roles => :app do
      if procfile_exists?
        sudo "restart #{application} || sudo start #{application}"
      end
    end

    task :stop, :roles => :app do
      if procfile_exists?
        sudo "stop #{application}"
      end
    end

    after 'deploy:restart', 'foreman:restart'
  end
end
