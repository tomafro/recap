[recap](http://github.com/freerange/recap) is an opinionated set of capistrano deployment recipes, designed to use git's strengths to deploy applications and websites in a fast and simple manner.  It has the following main features and aims:

  * Releases are managed using git.  All code is deployed to a single directory, and git tags are used to manage different released versions.  No `releases`, `current` or `shared` directories are created, avoiding unecessary symlinking.
  * Deployments do the minimum work possible, using git to determine whether tasks need to run.  e.g. the `bundle:install` task only runs if the app contains a `Gemfile.lock` file and it has changed since the last deployment.
  * Applications have their own user account and group, owning all of that application's associated files and processes.  This gives them a dedicated environment, allowing environment variables to be used for application specific configuration.  Tasks such as `env`, `env:set` and `env:edit` make setting and changing these variables easy.
  * Personal accounts are used to deploy to the server, distinct from the application user.  The right to deploy an application is granted simply by adding a user to the application group.

For more information, the main documentation can be found at [http://code.gofreerange.com/recap](http://code.gofreerange.com/recap), while the code is available [on github](https://github.com/freerange/recap).

Recap was written by [Tom Ward](http://tomafro.net) and the other members of [Go Free Range](http://gofreerange.com), and is released under the [MIT License](https://github.com/freerange/recap/blob/master/LICENSE).