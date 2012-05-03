require 'bundler/gem_tasks'
require 'rocco/tasks'
require 'rspec/core/rake_task'

desc 'build docs'
task :doc do
  FileUtils.cd('lib') do
    files = Dir['**/*.rb']
    files.each do |source_file|
      rocco = Rocco.new(source_file, files.to_a, {})
      dest_file = '../doc/' + source_file.sub(Regexp.new("#{File.extname(source_file)}$"), '.html')
      FileUtils.mkdir_p(File.dirname(dest_file))
      File.open(dest_file, 'wb') { |fd| fd.write(rocco.to_html) }
    end
  end
  File.open('doc/index.html', 'w') do |f|
    f.write <<-EOS
      <html><meta http-equiv="refresh" content="0; url=recap.html">
    EOS
  end
end

desc 'publish docs'
task :publish do
  sha = `git ls-tree -d HEAD doc | awk '{print $3}'`.strip
  commit = `echo "Publishing docs from master branch" | git commit-tree #{sha} -p refs/heads/gh-pages`.strip
  `git update-ref refs/heads/gh-pages #{commit}`
  puts "The gh-pages branch now points to the latest version of the docs."
  puts "All that remains is for you to push gh-pages to github."
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rspec_opts = "-fn --color"
end

task :default => :spec
