# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zerg/version'

Gem::Specification.new do |spec|
  spec.name          = "zerg"
  spec.version       = Zerg::VERSION
  spec.authors       = ["Marat Garafutdinov"]
  spec.email         = ["maratoid@gmail.com"]
  spec.description   = %q{Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once}
  spec.summary       = %q{Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once}
  spec.homepage      = "https://github.com/MTNSatelliteComm/zerg"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"

  spec.add_dependency "thor"
  spec.add_dependency "configatron"
end
