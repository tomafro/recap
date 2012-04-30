require 'bundler/gem_tasks'
require 'rocco/tasks'
require 'rspec/core/rake_task'

Rocco.make('doc', ['index.rb', 'lib/**/*.rb'])

desc 'build docs'
task :doc => :rocco

desc 'publish docs'
task :publish do
  sha = `git ls-tree -d HEAD doc | awk '{print $3}'`.strip
  commit = `echo "Publishing docs from master branch" | git commit-tree #{sha} -p refs/heads/gh-pages`.strip
  `git update-ref refs/heads/gh-pages #{commit}`
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = "-fn --color"
end

task :default => :spec