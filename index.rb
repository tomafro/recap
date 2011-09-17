# This is the annotated source code and documentation for
# [tomafro-deploy](http://github.com/tomafro/tomafro-deploy), a simple, opinionated set of capistrano
# deployment recipes.  Inspired by
# [this blog post](https://github.com/blog/470-deployment-script-spring-cleaning), these recipes use
# git's strengths to deploy applications in a faster, simpler manner than a standard capistrano
# deployment.  Using git to manage release versions means apps can be deployed to a single directory.
# There's no need for `releases`, `shared` or `current` folders, and no symlinking.

# ### Goals ###

# These deployment recipes try to do the following:

# Run all commands as the `application_user`, loading the full user environment.  The only
# exceptions are `git` commands (which often rely on SSH agent forwarding for authentication), and anything
# that requires `sudo`.
#

# Use `git` to avoid unecessary work.  If the `Gemfile.lock` hasn't changed, there's no need to run
# `bundle install`.  Similarly if there are no new migrations, why do `rake db:migrate`.  Faster deploys
# mean more frequent deploys, which in our experience leads to better applications.
#

# Avoid the use of `sudo` (other than to change to the `application_user`).  As much as possible, `sudo`
# is only used to `su` to the `application_user` before running a command.  To avoid typing a password
# to perform the majority of deployment tasks, this code can be added to
# `/etc/sudoers.d/application` (change `application` to the name of your app).

%application ALL=NOPASSWD: /sbin/start application*
%application ALL=NOPASSWD: /sbin/stop application*
%application ALL=NOPASSWD: /sbin/restart application*
%application ALL=NOPASSWD: /bin/su - application*
%application ALL=NOPASSWD: /bin/su application*

# ### Code layout ###

# The main deployment tasks are defined in [tomafro/deploy.rb](lib/tomafro/deploy.html).  Automatic
# checks to ensure servers are correctly setup are in
# [tomafro/deploy/preflight.rb](lib/tomafro/deploy/preflight.html).

# In addition, there are extensions for [bundler](lib/tomafro/deploy/bundler.html) and
# [foreman](lib/tomafro/deploy/foreman.html).

# For (limited) compatability with other existing recipes, see
# [compatibility](lib/tomafro/deploy/compatibility.html)

# ### Deployment target ###

# These recipes have been run successful against Ubuntu.

# The application should be run as the application user; if using Apache and Passenger, you should set the `PassengerDefaultUser` directive to be the same as the `application_user`.

# The code is available [on github](http://github.com/tomafro/tomafro-deploy) and released under the
# [MIT License](https://github.com/tomafro/tomafro-deploy/blob/master/LICENSE)
