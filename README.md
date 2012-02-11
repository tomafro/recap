[recap](http://github.com/freerange/recap) is an opinionated set of capistrano deployment recipes, designed to use git's strengths to deploy applications and websites in a fast and simple manner.

Recap's core features are:

  * Release versions are managed with git.  There's no need for `releases` or `current` folders, and no symlinking.
  * Intelligently decides whether tasks need to execute.  e.g. The `bundle:install` task will only run if a `Gemfile.lock` exists, and if it has changed since the last deployment.
  * A dedicated user account and group owns all an application's associated files and processes.
  * Deployments are run using personal logins.  The right to deploy is granted by adding a user to the application group.
  * Environment variables are used for application specific configuration.  These can easily be read and set using the `env` and `env:set` tasks.
  * Out of the box support for `bundler` and `foreman`

For more information, the main documentation can be found at [http://code.gofreerange.com/recap](http://code.gofreerange.com/recap), while the code is available [on github](https://github.com/freerange/recap).

Recap was written by [Tom Ward](http://tomafro.net) and the other members of [Go Free Range](http://gofreerange.com), and is released under the [MIT License](https://github.com/freerange/recap/blob/master/LICENSE).