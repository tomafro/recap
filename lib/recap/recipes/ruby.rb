# Require `recap/recipes/ruby` in your `Capfile` to use the default recap recipies for deploying a
# Ruby application.
require 'recap/tasks/deploy'
require 'recap/tasks/ruby'

# If your application uses Bundler, `bundle install` will be run automatically when deploying
# any changes to your `Gemfile`.
require 'recap/tasks/bundler'

# If your application uses Foreman, recap will use that to stop, start and restart your
# application processes.
require 'recap/tasks/foreman'