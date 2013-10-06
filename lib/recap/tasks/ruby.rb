module Recap::Tasks::Ruby
  extend Recap::Support::Namespace

  namespace :ruby do
    _cset(:skip_rails_recipe_not_used_warning, false)

    task :preflight do
      if exit_code("grep rails #{deploy_to}/Gemfile") == "0"
        unless skip_rails_recipe_not_used_warning || Recap::Tasks.const_defined?(:Rails)
          logger.important %{
Warning: it looks like you're using the recap ruby recipe on a rails project.
This will prevent some rails specific features such as asset compilation and
database migrations from working correctly.
To fix this, require 'recap/recipes/rails' from within your Capfile.  To
suppress this warning, set :skip_rails_recipe_not_used_warning to true.
}
        end
      end
    end

    after "preflight:check", "ruby:preflight"
  end
end
