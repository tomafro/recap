# The `recap/recipes/rails` builds on the [ruby](ruby.html)
# recipe, which provides support for both `bundler` and `foreman`.
require 'recap/recipes/ruby'

# It adds to this with a number of rails specific tasks.  See the
# [rails tasks](../tasks/rails.html) documentation for more information
# about the rails support.
require 'recap/tasks/rails'
