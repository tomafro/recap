require 'tomafro/deploy/capistrano_extensions'
require 'tomafro/deploy/bundler'
require 'tomafro/deploy/preflight'

Capistrano::Configuration.instance(:must_exist).load do
  extend Tomafro::Deploy::CapistranoExtensions

  # To use this recipe, both the application's name and its git repository are required.
  set(:application) { abort "You must set the name of your application in your Capfile, e.g.: set :application, 'tomafro.net'" }
  set(:repository) { abort "You must set the git respository location in your Capfile, e.g.: set :respository, 'git@github.com/tomafro/tomafro.net'"}

  # The recipe assumes that the application code will be run as a dedicated user.  Any any user who
  # can deploy the application should be added as a member of the application's group.  By default,
  # both the application user and group take the same name as the application.
  set(:application_user) { application }
  set(:application_group) { application_user }

  # Deployments can be made from any branch. `master` is used by default.
  set(:branch, 'master')

  # Unlike a standard capistrano deployment, all releases are stored directly in the `deploy_to`
  # directory.  The default is `/var/apps/#{application}`.
  set(:deploy_to)   { "/var/apps/#{application}" }

  # Each release is marked by a unique tag, generated with the current timestamp.  While this can be
  # changed, it's not recommended, as the sort order of the tag names is important; later tags must
  # be listed after earlier tags.
  set(:release_tag) { "#{Time.now.utc.strftime("%Y%m%d%H%M%S")}"}

  # On tagging a release, a message is also recorded alongside the tag.  This message can contain
  # anything useful - its contents are not important for the recipe.
  set(:release_message, "Deployed at #{Time.now}")

  # Some tasks need to know the `latest_tag` - the most recent successful deployment.  If no
  # deployments have been made, this will be `nil`.
  set(:latest_tag) { latest_tag_from_repository }

  # To authenticate with github or other git servers, it is easier (and cleaner) to forward the
  # deploying user's ssh key than manage keys on deployment servers.
  ssh_options[:forward_agent] = true

  # If key forwarding isn't possible, git may show a password prompt which stalls capistrano unless
  # `:pty` is set to `true`.
  default_run_options[:pty] = true

  namespace :deploy do
    # The `deploy:setup` task prepares all the servers for the deployment.
    desc "Prepare servers for deployment"
    task :setup, :except => {:no_release => true} do
      transaction do
        clone_code
      end
    end

    # Clone the repository into the deployment directory.
    task :clone_code, :except => {:no_release => true} do
      # This is a slightly complicated process, as git doesn't allow us to clone into an existing
      # directory.  To get around this, using `sudo` we create the base deployment folder (if it
      # doesn't already exist).
      sudo "mkdir -p #{File.expand_path(deploy_to + "/..")}"
      # Next, clone our code into a temporary location.  This is necessary as our user might not have
      # permission to write in the base deployment folder.
      run "git clone #{repository} $HOME/#{application}.tmp"
      # Again using `sudo`, move the temporary clone to its final destination.
      sudo "mv $HOME/#{application}.tmp #{deploy_to}"
      # Finally ensure that members of the `application_group` can read and write all files.
      top.deploy.change_ownership
    end

    # Any files that have been created or updated by our user need to have thier permissions changed to
    # ensure they can be read and written by and member of the `application_group` (deploying users and
    # the application itself).
    task :change_ownership, :except => {:no_release => true} do
      run "find #{deploy_to} -user `whoami` ! -group #{application_group} -exec chown :#{application_group} {} \\;"
      run "find #{deploy_to} -user `whoami` -exec chmod g+rw {} \\;"
    end

    # The main deployment task (called with `cap deploy`) deploys the latest application code to all
    # servers, tags the release and restarts the application.
    desc "Deploy the latest application code"
    task :default do
      transaction do
        update_code
        tag
      end
      restart
    end

    # Fetch the latest changes, then update `HEAD` to the deployment branch.
    task :update_code, :except => {:no_release => true} do
      on_rollback { git "reset --hard #{latest_tag}" if latest_tag }
      git "fetch"
      git "reset --hard origin/#{branch}"
      # Finally ensure that the members of the `application_group` can read and write all files.
      top.deploy.change_ownership
    end

    # Tag `HEAD` with the release tag and message
    task :tag, :except => {:no_release => true} do
      on_rollback { git "tag -d #{release_tag}" }
      git "tag #{release_tag} -m '#{release_message}'"
    end

    # After a successful deployment, the app is restarted.  In the most basic deployments this does
    # nothing, but other recipes may override it, or attach tasks it's before or after hooks.
    desc "Restart the application following a deploy"
    task :restart do
    end

    # To rollback a release, the latest tag is deleted, and `HEAD` reset to the previous release
    # (if one exists).  Finally the application is restarted again.
    desc "Rollback to the previous release"
    namespace :rollback do
      task :default do
        if latest_tag
          git "tag -d #{latest_tag}"
          if previous_tag = latest_tag_from_repository
            git "reset --hard #{previous_tag}"
          end
        end
        restart
      end
    end

    # In case of emergency or when manually testing deployment, it can be useful to remove all
    # previously deployed files before starting again.
    desc "Remove all deployed files"
    task :destroy do
      sudo "rm -rf #{deploy_to}"
    end
  end
end
