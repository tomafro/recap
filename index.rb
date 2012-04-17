# This is the documentation for [recap](http://github.com/freerange/recap), a simple, opinionated
# set of capistrano deployment recipes.

# Inspired in part by
# [this blog post](https://github.com/blog/470-deployment-script-spring-cleaning), these recipes use
# git's strengths to deploy applications in a faster, simpler manner than the standard capistrano
# deployment.

# These deployment recipes try to do the following:

# Releases are managed using git.  All code is deployed to a single directory, and git tags are used
# to manage different released versions.  No `releases`, `current` or `shared` directories are
# created, avoiding unecessary symlinking.  For more information on how releases work, see
# [recap/deploy.rb](lib/recap/deploy.html)

# Deployments do the minimum work possible, using git to determine whether tasks need to run.  e.g.
# the `bundle:install` task only runs if the app contains a `Gemfile.lock` file and it has changed
# since the last deployment.  You can see how this works in the
# (recap/bundler.rb)[lib/recap/bundler.html] recipe.

# Applications have their own user account and group, owning all of that application's associated
# files and processes.  This gives them a dedicated environment, allowing environment variables to
# be used for application specific configuration.  Tasks such as `env`, `env:set` and `env:edit` make
# setting and changing these variables easy. (recap/env.rb)[lib/recap/env.html] has more
# information about using these environment variables.

# Personal accounts are used to deploy to the server, distinct from the application user.  The right
# to deploy an application is granted simply by adding a user to the application group.  Most tasks
# are run as the application user using `sudo su...`.  To avoid having to enter a password when
# running them, these lines can be added to `/etc/sudoers.d/application`
# (change `application` to the name of your app).

%application ALL=NOPASSWD: /sbin/start application*
%application ALL=NOPASSWD: /sbin/stop application*
%application ALL=NOPASSWD: /sbin/restart application*
%application ALL=NOPASSWD: /bin/su - application*
%application ALL=NOPASSWD: /bin/su application*

# ### Getting started ###

# To use recap you'll need to install the gem, most likely by adding an entry like this to the
# `Gemfile`

gem 'recap', '~>0.3.0'

# Recap currently supports three types of deployment.  These are for static sites (as described
# in [recap/static.rb](lib/recap/static.html)), ruby apps ([recap/ruby.rb](lib/recap/ruby.html)),
# and rails apps ([recap/rails.rb](lib/recap/rails.html)).  Using all three is similar. Add this
# `Capfile` to your project, changing the first line to reflect the project you have.

require 'recap/ruby'

set :application, 'example-app'
set :repository, 'git@example.com:example/example-app.git'

server 'example-app.example.com', :app

# Then run `cap -T` to show all available tasks.  To get most apps running, you'll need to run the
# following tasks.  First `cap bootstrap` will add the application user and directory to your
# server.  Next `cap deploy:setup` gets everything ready for deployment.  Finally `cap deploy`
# will deploy your app.

# ### Code layout ###

# The main deployment tasks are defined in [recap/deploy.rb](lib/recap/deploy.html).  Automatic
# checks to ensure servers and users are correctly setup are in
# [recap/preflight.rb](lib/recap/preflight.html), while tasks to bootstrap the machine and users
# are in [recap/bootstrap.rb](lib/recap/bootstrap.rb).  Tasks to alter environment variables are
# in [recap/env.rb](lib/recap/env.html)

# In addition, there are extensions for [bundler](lib/recap/bundler.html),
# [foreman](lib/recap/foreman.html) and [rails](lib/recap/rails.html)

# For limited compatability with other existing recipes, see
# [compatibility](lib/recap/compatibility.html).

# ### Versioning ###

# recap uses [semantic versioning](http://semver.org/), so things may change before the `1.0.0`
# release.

# ### Deployment target ###

# These recipes have been developed and tested using Ubuntu 11.04, though they may work well with
# other flavours of unix.

# The application should be run as the application user; if using Apache and Passenger, you should
# set the `PassengerDefaultUser` directive to be the same as the `application_user`.

# The code is available [on github](http://github.com/freerange/recap) and released under the
# [MIT License](https://github.com/freerange/recap/blob/master/LICENSE)
