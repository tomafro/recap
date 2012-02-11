# This is the annotated source code and documentation for
# [recap](http://github.com/freerange/recap), a simple, opinionated set of capistrano
# deployment recipes.

# Inspired in part by
# [this blog post](https://github.com/blog/470-deployment-script-spring-cleaning), these recipes use
# git's strengths to deploy applications in a faster, simpler manner than a standard capistrano
# deployment.  Using git to manage release versions means apps can be deployed to a single directory.
# There's no need for `releases`, `shared` or `current` folders, and no symlinking.

# ### Goals ###

# These deployment recipes try to do the following:

# Where possible run commands as the `application_user`, loading the full user environment.  The only
# exceptions are `git` commands (which often rely on SSH agent forwarding for authentication), and
# anything that requires `sudo`.
#

# Use `git` to avoid unecessary work.  If the `Gemfile.lock` hasn't changed, there's no need to run
# `bundle install`.  Similarly if there are no new migrations, why do `rake db:migrate`?  Faster
# deploys mean more frequent deploys.
#

# Avoid the use of `sudo` (other than to change to the `application_user`).  As much as possible,
# `sudo` is only used to `su` to the `application_user` before running a command.  To avoid having to
# type a password to perform the majority of deployment tasks, these lines can be added to
# `/etc/sudoers.d/application` (change `application` to the name of your app).

%application ALL=NOPASSWD: /sbin/start application*
%application ALL=NOPASSWD: /sbin/stop application*
%application ALL=NOPASSWD: /sbin/restart application*
%application ALL=NOPASSWD: /bin/su - application*
%application ALL=NOPASSWD: /bin/su application*

# Use environment variables for configuration.  Rather than setting `rails_env` in the `Capfile`,
# `RAILS_ENV` (or `RACK_ENV`) variables should be set for the `application_user`.  The `env:set` and
# `env:edit` tasks help do this.

# ### Code layout ###

# The main deployment tasks are defined in [recap/deploy.rb](lib/recap/deploy.html).  Automatic
# checks to ensure servers are correctly setup are in
# [recap/preflight.rb](lib/recap/preflight.html), while tasks for environment variables are in
# [recap/env.rb](lib/recap/env.html)

# In addition, there are extensions for [bundler](lib/recap/bundler.html),
# [foreman](lib/recap/foreman.html) and [rails](lib/recap/rails.html)

# For limited compatability with other existing recipes, see
# [compatibility](lib/recap/compatibility.html).

# ### Deployment target ###

# These recipes have been developed and tested using Ubuntu 11.04, though they may work well with
# other flavours of unix.

# The application should be run as the application user; if using Apache and Passenger, you should
# set the `PassengerDefaultUser` directive to be the same as the `application_user`.

# The code is available [on github](http://github.com/freerange/recap) and released under the
# [MIT License](https://github.com/freerange/recap/blob/master/LICENSE)
