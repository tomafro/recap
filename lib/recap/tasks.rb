# Recap provides a number of capistrano tasks to aid with deployment.  The core functionality
# is found in the [tasks for deployment](tasks/deploy.html) and those for
# [altering environment variables](tasks/env.html).
#
# Supporting these are [preflight checks](tasks/preflight.html) to ensure servers and
# users are correctly setup, and the [bootstrap tasks](tasks/bootstrap.html) that help
# do this setting up.
#
# In addition, there are extensions for [bundler](tasks/bundler.html),
# [foreman](tasks/foreman.html), and [rails](tasks/rails.html) that add extra
# functionality to the standard deploy.

require 'recap'

module Recap::Tasks
end