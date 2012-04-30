require 'thor'

module Recap::Support
  class CLI < Thor
    include Thor::Actions

    attr_accessor :name, :repository

    def self.source_root
      File.expand_path("../templates", __FILE__)
    end

    desc 'setup', 'Setup basic capistrano recipes, e.g: recap setup'
    method_option :name, :aliases => "-n"
    method_option :repository, :aliases => "-r"
    def setup
      self.name = options["name"] || guess_name
      self.repository = options["repo"] || guess_repository
      template 'Capfile.erb', 'Capfile'
    end

    private

    def guess_name
      Dir.pwd.split(File::SEPARATOR).last
    end

    def guess_repository
      `git remote -v`.split[1]
    end
  end
end