# This is the annotated source code and documentation for
# [tomafro-deploy](http://github.com/tomafro/tomafro-deploy), a simple, opinionated set of capistrano
# deployment recipes.  Inspired by
# [this blog post](https://github.com/blog/470-deployment-script-spring-cleaning), these recipes use
# git's strengths to deploy applications in a faster, simpler manner than a standard capistrano
# deployment.  Using git to manage release versions means apps can be deployed to a single directory.
# There's no need for `releases`, `shared` or `current` folders, and no symlinking.

# The main deployment tasks are defined in [tomafro/deploy.rb](lib/tomafro/deploy.html).  Automatic
# checks to ensure servers are correctly setup are in 
# [tomafro/deploy/preflight.rb](lib/tomafro/deploy/preflight.html).

# In addition, there are extensions for [bundler](lib/tomafro/deploy/bundler.html) and
# [foreman](lib/tomafro/deploy/foreman.html).

# For (limited) compatability with other existing recipes, see 
# [compatibility](lib/tomafro/deploy/compatibility.html)

# The code is available [on github](http://github.com/tomafro/tomafro-deploy) and released under the
# [MIT License](https://github.com/tomafro/tomafro-deploy/blob/master/LICENSE)
