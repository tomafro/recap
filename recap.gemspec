# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "recap/version"

Gem::Specification.new do |s|
  s.name        = "recap"
  s.version     = Recap::VERSION
  s.authors     = ["Tom Ward"]
  s.email       = ["tom@popdog.net"]
  s.homepage    = "http://code.gofreerange.com/recap"
  s.summary     = %q{GIT based deployment recipes for Capistrano}
  s.description = %q{GIT based deployment recipes for Capistrano}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency('capistrano', '~>2.9.0')
  s.add_dependency('thor')
  s.add_development_dependency('rake', '~>0.9.2')
  s.add_development_dependency('rocco', '~>0.8.1')
end
