require 'thor'

module Recap::Support

  # Recap provides a simple command-line tool (`recap`) to generate a `Capfile` in your
  # project.

  class CLI < Thor
    include Thor::Actions

    attr_accessor :name, :repository, :recipe, :server

    def self.source_root
      File.expand_path("../templates", __FILE__)
    end

    desc 'setup', 'Setup basic capistrano recipes, e.g: recap setup'
    method_option :name
    method_option :repository
    method_option :server
    method_option :recipe, :type => 'string', :banner => 'static|ruby|rails'

    def setup
      self.name = options["name"] || guess_name
      self.repository = options["repo"] || guess_repository
      self.recipe = options["recipe"] || guess_recipe
      self.server = options["server"] || 'your-server-address'
      template 'Capfile.erb', 'Capfile'
    end

    private

    def guess_name
      Dir.pwd.split(File::SEPARATOR).last
    end

    def guess_repository
      `git remote -v`.split[1]
    end

    def guess_recipe
      if File.exist?('Gemfile.lock')
        if File.read('Gemfile.lock') =~ / rails /
          'rails'
        else
          'ruby'
        end
      else
        'static'
      end
    end
  end
end