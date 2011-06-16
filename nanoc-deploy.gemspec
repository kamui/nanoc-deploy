# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "nanoc-deploy/version"

Gem::Specification.new do |s|
  s.name        = "nanoc-deploy"
  s.version     = NanocDeploy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jack Chu"]
  s.email       = ["jack@jackchu.com"]
  s.homepage    = "http://jackchu.com/easily-deploy-static-sites-into-the-cloud-wit"
  s.summary     = %q{nanoc extension adds rake cloud deployment options using fog.}
  s.description = %q{}

  s.rubyforge_project = "nanoc-deploy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('nanoc', '>= 3.1.6')
  s.add_runtime_dependency('fog', '>= 0.7.2')
end
