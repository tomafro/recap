# These tasks provide the basic mechanism getting new code onto servers using git.

require 'recap/tasks'
require 'recap/support/capistrano_extensions'

# These deployment tasks are designed to work alongside the tasks for
# [altering environment variables](env.html), as well as the
# [preflight checks](preflight.html) and
# [bootstrap tasks](bootstrap.html).

require 'recap/tasks/env'
require 'recap/tasks/preflight'
require 'recap/tasks/bootstrap'

module Recap::Tasks::Deploy
  extend Recap::Support::Namespace

  namespace :deploy do
    # To use this recipe, both the application's name and its git repository are required.
    _cset(:application) { abort "You must set the name of your application in your Capfile, e.g.: set :application, 'tomafro.net'" }
    _cset(:repository) { abort "You must set the git respository location in your Capfile, e.g.: set :respository, 'git@github.com/tomafro/tomafro.net'" }

    # The recipe assumes that the application code will be run as a dedicated user.  Any user who
    # can deploy the application should be added as a member of the application's group.  By default,
    # both the application user and group take the same name as the application.
    _cset(:application_user) { application }
    _cset(:application_group) { application_user }

    # Deployments can be made from any branch. `master` is used by default.
    _cset(:branch, 'master')

    # Unlike a standard capistrano deployment, all releases are stored directly in the `deploy_to`
    # directory.  The default is `/home/#{application_user}/app`.
    _cset(:deploy_to)   { "/home/#{application_user}/app" }

    # Each release is marked by a unique tag, generated with the current timestamp.  This should
    # not be changed, as the format is matched in the list of tags to find deploy tags.
    _cset(:release_tag) { Time.now.utc.strftime("%Y%m%d%H%M%S") }

    # If `release_tag` is changed, then `release_matcher` must be too, to a regular expression
    # that will match all generated release tags.  In general it's best to leave both unchanged.
    _cset(:release_matcher) { /\A[0-9]{14}\Z/ }

    # On tagging a release, a message is also recorded alongside the tag.  This message can contain
    # anything useful - its contents are not important for the recipe.
    _cset(:release_message, "Deployed at #{Time.now}")

    # Some tasks need to know the `latest_tag` - the most recent successful deployment.  If no
    # deployments have been made, this will be `nil`.
    _cset(:latest_tag) { latest_tag_from_repository }

    # Force a complete deploy, even if no trigger files have changed
    _cset(:force_full_deploy, false)

    # A lock file is used to ensure deployments don't overlap
    _cset(:deploy_lock_file) { "#{deploy_to}/.recap-lock"}

    # The lock file is set to include a message that can be displayed
    # if claiming the lock fails
    _cset(:deploy_lock_message) { "Deployment in progress (started #{Time.now.to_s})" }

    # To authenticate with github or other git servers, it is easier (and cleaner) to forward the
    # deploying user's ssh key than manage keys on deployment servers.
    ssh_options[:forward_agent] = true

    # If key forwarding isn't possible, git may show a password prompt which stalls capistrano unless
    # `:pty` is set to `true`.
    default_run_options[:pty] = true

    # The `deploy:setup` task prepares all the servers for the deployment.  It ensures the `env`
    # has been set, and clones the code.
    desc "Prepare servers for deployment"
    task :setup, :except => {:no_release => true} do
      transaction do
        top.env.set
        clone_code
      end
    end

    # The `deploy:clone_code` task clones the project repository into the `deploy_to` location
    # and ensures it has the correct file permissions.  It shouldn't be necessary to call this
    # task manually as it is run as part of `deploy:setup`.
    task :clone_code, :except => {:no_release => true} do
      on_rollback { as_app "rm -fr #{deploy_to}" }
      # Before cloning, the directory needs to exist and be both readable and writeable by the application group
      as_app "mkdir -p #{deploy_to}", "~"
      as_app "chmod g+rw #{deploy_to}"
      # Then clone the code and change to the given branch
      run "if [ ! -d #{deploy_to}/.git ]; then umask 002 && sg #{application_group} -c \"git clone #{repository} #{deploy_to}\"; fi"
      git "reset --hard origin/#{branch}"
    end

    # The `deploy` task ensures the environment is set, updates the application code,
    # tags the release and restarts the application.
    desc "Deploy the latest application code"
    task :default do
      transaction_with_lock deploy_lock_message do
        top.env.set
        update_code
        tag
      end
      restart
    end

    # `deploy:full` rung a standard deploy, but sets the `force_full_deploy` flag
    # first.  Any parts of the deploy that would normally only be triggered if
    # a file changes will always run.
    task :full do
      set(:force_full_deploy, true)
      default
    end

    # Fetch the latest changes, then update `HEAD` to the deployment branch.
    task :update_code, :except => {:no_release => true} do
      on_rollback { git "reset --hard #{latest_tag}" if latest_tag }
      git "fetch"
      git "reset --hard origin/#{branch}"
    end

    # Tag `HEAD` with the release tag and message
    task :tag, :except => {:no_release => true} do
      unless release_tag =~ release_matcher
        abort "The release_tag must be matched by the release_matcher regex, #{release_tag} doesn't match #{release_matcher}"
      end
      on_rollback { git "tag -d #{release_tag}" }
      git "tag #{release_tag} -m '#{release_message}'"
    end

    # After a successful deployment, the app is restarted.  In the most basic deployments this does
    # nothing, but other recipes may override it, or attach tasks to its before or after hooks.
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
          restart
        else
          abort "This app is not currently deployed"
        end
      end
    end

    # The `destroy` task can be used in an emergency or when manually testing deployment.  It removes
    # all previously deployed files, leaving a blank slate to run `deploy:setup` on.
    desc "Remove all deployed files"
    task :destroy do
      sudo "rm -rf #{deploy_to}"
    end

    # As well as locking during each deployment, locks can manually be set with `deploy:lock`.  To
    # use a custom lock message, do `DEPLOY_LOCK_MESSAGE="My message" cap deploy:lock`.  Locking
    # prevents deployments, but not other tasks.
    task :lock do
      claim_lock ENV['DEPLOY_LOCK_MESSAGE'] || "Manually locked at #{Time.now}"
    end

    # To unlock a manually set lock, or a lock that has been left behind in error, the `deploy:unlock`
    # task can be used.
    task :unlock do
      release_lock
    end
  end
end
