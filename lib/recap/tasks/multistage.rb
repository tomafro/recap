# Recap doesn't yet provide any specific tools for multistage deployments
# (deploying to different servers for `production`, `staging`, `qa`, etc.),
# but you can still easily support them.
#
# The easiest way is to define your own task for each environment, and
# declare servers and other configuration within those tasks.  For example,
# a `Capfile` targetting both a `staging` and `production` environment
# might look like this:
#
# <pre>
# require 'recap/recipes/rails'
#
# set :application, 'blanche'
# set :repository, 'git@github.com:tomafro/blanche'
#
# task :staging do
#   server 'staging.example.com', :app
# end
#
# task :production do
#   set :branch, 'production'
#   server 'production.example.com', :app
# end
# </pre>
#
# The two environments deploy to different servers, and the production
# environment deploys the `production` branch of code, rather than
# the default (which is `master`).
#
# To run tasks against each environment, simply call the environment
# task first, i.e. `cap staging deploy`, or `cap production bootstrap`.