require 'open4'

module Recap::Support
  class ShellCommand
    def self.execute(*commands)
      output, error = "", ""
      commands.each do |command|
        status = Open4::popen4(command) do |pid, stdin, stdout, stderr|
          output, error = stdout.read, stderr.read
        end
        unless status.success?
          message = [
            "Executing shell command failed.",
            "  Command: #{command}",
            "  Status:  #{status.exitstatus}",
            "  Message: #{error}"
          ].join("\n")
          raise message
        end
      end
      output
    end

    def self.execute_interactive(command)
      unless system(command)
        message = [
          "Executing shell command failed.",
          "  Command: #{command}",
          "  Status:  #{$?.exitstatus}"
        ].join("\n")
        raise message
      end
    end
  end
end
