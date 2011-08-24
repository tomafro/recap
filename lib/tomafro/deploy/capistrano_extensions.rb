module Tomafro
  module Deploy
    module CapistranoExtensions
      # Run a git command in the `deploy_to` directory
      def git(command)
        run "cd #{deploy_to} && git #{command}"
      end

      # Capture the result of a git command run within the `deploy_to` directory
      def capture_git(command)
        capture "cd #{deploy_to} && git #{command}"
      end

      # Run a bundle command in the `deploy_to` directory
      def bundler(command)
        run "cd #{deploy_to} && bundle #{command}"
      end

      # Run a command as root using a full shell within the `deploy_to` directory
      def run_as_root(command, pwd = deploy_to)
        sudo "su - root -c 'cd #{pwd} && #{command}'"
      end

      # Find the latest tag from the repository.  As `git tag` returns tags in order, and our release
      # tags are timestamps, the latest tag will always be the last in the list.
      def latest_tag_from_repository
        result = capture_git("tag | tail -n1").strip
        result.empty? ? nil : result
      end

      # Does the given file exist within the deployment directory?
      def deployed_file_exists?(path)
        capture("cd #{deploy_to} && [ -f #{path} ]; echo $?").strip == "0"
      end

      # Has the given path been created or changed since the previous deployment?  During the first 
      # successful deployment this will always return true.
      def deployed_file_changed?(path)
        return true unless latest_tag
        capture_git("diff --exit-code #{latest_tag} origin/#{branch} #{path} > /dev/null; echo $?").strip != "0"
      end
    end
  end
end