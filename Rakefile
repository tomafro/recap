require 'bundler/gem_tasks'
require 'rocco/tasks'

desc 'build docs'
Rocco::Task.new :rocco, 'doc/', ['index.rb', 'lib/**/*.rb']

desc 'publish docs'
task :publish do
  sha = `git ls-tree -d HEAD doc | awk '{print $3}'`.strip
  commit = `echo "Publishing docs from master branch" | git commit-tree #{sha} -p refs/heads/gh-pages`.strip
  `git update-ref refs/heads/gh-pages #{commit}`
end
