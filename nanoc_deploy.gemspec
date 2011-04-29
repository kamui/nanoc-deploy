# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nanoc_deploy/version"

Gem::Specification.new do |s|
  s.name        = "nanoc_deploy"
  s.version     = NanocDeploy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jack Chu"]
  s.email       = ["jack@jackchu.com"]
  s.homepage    = "https://github.com/kamui/nanoc_deploy"
  s.summary     = %q{nanoc 3.1 extension adds rake cloud deployment options using fog.}
  s.description = %q{}

  s.rubyforge_project = "nanoc_deploy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('nanoc', '>= 3.1.6')
  s.add_runtime_dependency('fog', '>= 0.7.2')
end
