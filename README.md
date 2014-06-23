# Recap

[![Build Status](https://travis-ci.org/tomafro/recap.png?branch=1.x)](https://travis-ci.org/tomafro/recap)

[Recap](https://github.com/freerange/recap) is an opinionated set of [Capistrano](https://github.com/capistrano/capistrano) deployment recipes, that use git's strengths to deploy applications and websites in a fast and simple manner.


## Features & Aims

  * Releases are managed using git.  All code is deployed to a single directory, and git tags are used to manage different released versions.  No `releases`, `current` or `shared` directories are created, avoiding unnecessary sym-linking.
  * Deployments do the minimum work possible, using git to determine whether tasks need to run.  e.g. the `bundle:install` task only runs if the app contains a `Gemfile.lock` file and it has changed since the last deployment.
  * Applications have their own user account and group, owning all of that application's associated files and processes.  This gives them a dedicated environment, allowing environment variables to be used for application specific configuration.  Tasks such as `env`, `env:set` and `env:edit` make setting and changing these variables easy.
  * Personal accounts are used to deploy to the server, distinct from the application user.  The right to deploy an application is granted simply by adding a user to the application group.


## Documentation

For more information, the main documentation can be found at [http://gofreerange.com/recap/docs](http://gofreerange.com/recap/docs).


## Prerequistes

* Recap's built-in tasks only support deploying to Ubuntu
* Your user account (as opposed to the application account) must be able to `sudo`
* Your user account should be able to connect to the remote git repository from your deployment server(s)


## Source

The source code is available [on Github](https://github.com/freerange/recap).


## Running Tests

- Run the following commands from the checked out project directory.
- Install dependencies (assumes the bundler gem is installed).

    `$ bundle install`

- Run specs

    `$ bundle exec rake`

- Install [VirtualBox](https://www.virtualbox.org/) - only necessary if you want to run [Cucumber](https://github.com/cucumber/cucumber) features.
- Install and provision a test VM based on the [Vagrantfile](https://github.com/freerange/recap/blob/master/Vagrantfile) (assumes VirtualBox is installed)

    `$ bundle exec vagrant up`

- Run features

    `$ bundle exec cucumber`


## Publishing documentation

This defaults to publishing to gofreerange.com but that can be customised by setting the `RECAP_DOCS_HOST` environment variable.

    $ rake doc publish

*NOTE*. The recap docs rely on a rocco.css file being available at `#{RECAP_DOCS_HOST}/stylesheets/rocco.css`. This was [added to our site in e41bac][e41bac]

[e41bac]: https://github.com/freerange/site/commit/e41bac9954eddd2ca9dda0f8d034bb3f8ac77bd3


## Credits

Recap was written by [Tom Ward](http://tomafro.net) and the other members of [Go Free Range](http://gofreerange.com).


## License

Recap is released under the [MIT License](https://github.com/freerange/recap/blob/master/LICENSE).
