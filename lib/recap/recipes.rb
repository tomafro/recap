# There are three main recipes, defined in [recap/recipes/static.rb](recipes/static.html),
# [recap/recipes/ruby.rb](recipes/ruby.html) and [recap/recipes/rails.rb](recipes/rails.html)
# that include tasks for static, ruby-based and rails sites respectively.  One of these should be
# required at the top of your `Capfile`.
#
# The static recipe includes all the main deployment behaviour.  It provides everything you
# should need to push static content up to one or more servers, as well as the ability to
# rollback to a previous release if you make a mistake.
#
# The ruby recipe builds on this with support for `bundler`, to automatically install any
# bundled gems.  It also includes `foreman` support, starting and restarting processes
# defined in a `Procfile`.
#
# The rails recipe includes all the above, and adds automatic database migration and
# asset compilation to each deploy.
#
# To swap between each of these, simply change the top line of your `Capfile` to require
# the one you want.