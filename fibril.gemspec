# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fibril/version'

Gem::Specification.new do |spec|
  spec.name          = "fibril"
  spec.version       = Fibril::VERSION
  spec.authors       = ["Wouter Coppieters"]
  spec.email         = ["wouter.coppieters@youdo.co.nz"]

  spec.summary       = "Fibril"
  spec.description   = "Fibril"
  spec.homepage      = "https://github.com/wouterken/Fibril"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "byebug", "~> 8.2.1"
  spec.add_development_dependency "pry-byebug", "~> 3.3.0"
  spec.add_development_dependency 'pry', '~> 0.10.2', '>= 0.10.0'
  spec.add_development_dependency 'redis'
  spec.add_development_dependency "minitest"
end
