# `recap` isn't intended to be compatible with tasks (such as those within the `bundler`
# or `whenever` projects) that are built on the original capistrano deployment recipes.  At times
# though there are tasks that would work, but for some missing (and redundant) settings.
#
# Including this recipe adds these legacy settings, but provides no guarantee that original tasks
# will work.  Many are based on assumptions about the deployment layout that no longer hold true.

module Recap::Support::Compatibility
  extend Recap::Support::Namespace

  # As `git` to manages releases, all deployments are placed directly in the `deploy_to` folder.  The
  # `current_path` is always this directory (no symlinking required).
  _cset(:current_path) { deploy_to }

  # Deploys do not require source code to be local so using the HEAD on server
  _cset(:real_revision) { capture_git('rev-parse HEAD') }
end
