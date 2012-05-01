# This is the documentation for [recap](http://github.com/freerange/recap), a simple, opinionated
# set of capistrano deployment recipes.
#
# Inspired in part by
# [this blog post](https://github.com/blog/470-deployment-script-spring-cleaning), these recipes use
# git's strengths to deploy applications in a faster, simpler manner than the standard capistrano
# deployment.
#
# ### Aims and features
#
# Releases are managed using git.  All code is deployed to a single directory, and git tags are
# used to manage different released versions.  No `releases`, `current` or `shared` directories are
# created, avoiding unnecessary sym-linking.  For more information on how releases work, see
# [recap/tasks/deploy.rb](recap/tasks/deploy.html).
#
# Deployments do the minimum work possible, using git to determine whether tasks need to run.  e.g.
# the `bundle:install` task only runs if the app contains a `Gemfile.lock` file and it has changed
# since the last deployment.  You can see how this works in
# [recap/tasks/bundler.rb](recap/tasks/bundler.html).
#
# Applications have their own user and group, owning all of that application's associated
# files and processes.  This gives them a dedicated environment, allowing environment variables to
# be used for application specific configuration.  Tasks such as `env`, `env:set` and `env:edit` make
# setting and changing these variables easy.  [recap/tasks/env.rb](recap/tasks/env.html) has more
# information about using these environment variables.
#
# Personal accounts are used to deploy to the server, distinct from the application user.  The right
# to deploy an application is granted simply by adding a user to the application group.  Most tasks
# are run as the application user using `sudo su...`.  To avoid having to enter a password when
# running them, these lines can be added to `/etc/sudoers.d/application`
# (change `application` to the name of your app).
#
# <pre>%application ALL=NOPASSWD: /sbin/start application*
# %application ALL=NOPASSWD: /sbin/stop application*
# %application ALL=NOPASSWD: /sbin/restart application*
# %application ALL=NOPASSWD: /bin/su - application*
# %application ALL=NOPASSWD: /bin/su application*</pre>
#
# ### Limitations and Constraints
#
# Recap has been developed and tested using Ubuntu 11.04. It may work well with
# other flavours of unix, but proceed with caution.
#
# Recap also uses a different file layout than other capistrano-based deployments, so other
# recipes may not work well with it.  You can improve compatibility with other recipes using
# [recap/support/compatibility.rb](recap/support/compatibility.html).
#
# ### Getting started
#
# To use recap you'll need a project stored in `git`.  You'll also need a server with `git` installed
# and if deploying a rails or ruby app, `bundler` and `ruby` too.  Finally you need an account on the
# server which you can SSH into and which is a sudoer.
#
# #### Preparing your project
#
# To get a project ready to deploy with recap, you'll need to install the gem, most likely by adding
# an entry like the following to the `Gemfile`, then running `bundle install`.
#
# <pre>gem 'recap', '~>1.0.0'</pre>
#
# Once the gem is installed, generate a `Capfile` by running `recap setup` within your project
# folder.  You can see the supported options with `recap help setup`.  The generated `Capfile`
# will look something like this:
#
# <pre>require 'recap/recipes/rails'
#
# set :application, 'example-app'
# set :repository, 'git@example.com:example/example-app.git'
#
# server 'server.example.com', :app</pre>
#
# Edit the `Capfile` to point at your deployment server and your project should be ready.  `cap -T`
# will show all the tasks now available.
#
# #### Preparing the server
#
# The next step is setting up the server.  Running `cap bootstrap` will check your personal account
# on the server is configured correctly, and add an account for your application.
#
# This application account is dedicated to your app, so you can edit its `.profile` as much as you
# need (to add a particular version of `ruby` to the path, for example).
# [recap/tasks/env.rb](recap/tasks/env.html) information on how to use the `env:set` and `env:edit`
# tasks to set configuration variables.
#
# #### Preparing the app
#
# Running `cap deploy:setup` clones your code and sets up everything ready for the first deployment.
# Once this has been run, you might want to set up a virtual host entry for nginx or Apache to
# point at your app.
#
# #### Deploying
#
# Finally running `cap deploy` will deploy your app for the first time.  Each time you make a change
# you want deployed, commit and push your changes to your `git` repository, and run `cap deploy` to
# push those changes to the server.
#
# ### Further information
#
# Recap has recipes to deploy static, ruby-based and rails apps which you can find out about in
# [recap/recipes](recap/recipes.html).
#
# For more information about all the capistrano tasks recap provides, see
# [recap/tasks](recap/tasks.html).
#
# ### Versioning and License ###
#
# recap uses [semantic versioning](http://semver.org/).
# The code is available [on github](http://github.com/freerange/recap) and released under the
# [MIT License](https://github.com/freerange/recap/blob/master/LICENSE)

module Recap
  module Support
    autoload :Compatibility, 'recap/support/compatibility'
    autoload :Namespace, 'recap/support/namespace'
    autoload :Environment, 'recap/support/environment'
    autoload :ShellCommand, 'recap/support/shell_command'
    autoload :CLI, 'recap/support/cli'
  end

  autoload :Version, 'recap/version'
end
