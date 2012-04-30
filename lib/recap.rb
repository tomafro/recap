module Recap
  module Support
    autoload :Namespace, 'recap/support/namespace'
    autoload :Compatibility, 'recap/support/compatibility'
    autoload :Environment, 'recap/support/environment'
  end

  module Tasks
    autoload :Bootstrap, 'recap/tasks/bootstrap'
    autoload :Bundler, 'recap/tasks/bundler'
    autoload :Deploy, 'recap/tasks/deploy'
    autoload :Env, 'recap/tasks/env'
    autoload :Foreman, 'recap/tasks/foreman'
  end

  autoload :Rails, 'recap/rails'
end