# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "typed/version"

Gem::Specification.new do |s|
  s.name        = "typed"
  s.version     = Typed::VERSION
  s.authors     = ["maiha"]
  s.email       = ["maiha@wota.jp"]
  s.homepage    = "https://github.com/maiha/typed"
  s.summary     = %q{A Ruby library for Typed variables}
  s.description = %q{Typed::Hash}

  s.rubyforge_project = "typed"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activesupport"
  s.add_dependency "must", ">= 0.2.7"

  s.add_development_dependency "rspec"
end
