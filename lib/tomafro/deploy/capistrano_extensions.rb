module Tomafro
  module Deploy
    module CapistranoExtensions
      # Run a git command in the `deploy_to` directory
      def git(command)
        run "cd #{deploy_to} && git #{command}"
      end

      # Find the latest tag from the repository.  As `git tag` returns tags in order, and our release
      # tags are timestamps, the latest tag will always be the last in the list.
      def latest_tag_from_repository
        capture("cd #{deploy_to} && git tag | tail -n1")
      end
    end
  end
end