# -*- encoding: utf-8 -*-
require File.expand_path("../lib/zerg/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "zergrush"
  s.version     = Zerg::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["MTN Satellite Communications"]
  s.email       = ["Marat.Garafutdinov@mtnsat.com"]
  s.homepage    = "https://github.com/MTNSatelliteComm/zerg"
  s.license     = "MIT"
  s.summary     = "Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once"
  s.description = "Zerg is a tool for launching an arbitrary number of virtual machines and running a task on all of them at once"

  s.required_rubygems_version = ">= 2.0.0"
  s.rubyforge_project         = "zergrush"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "cucumber"
  s.add_development_dependency "aruba"
  s.add_development_dependency "rake"
  s.add_development_dependency "ipaddress"

  s.add_dependency "awesome_print"
  s.add_dependency "json-schema"
  s.add_dependency "thor"
  s.add_dependency "highline"
  s.add_dependency "zergrush_vagrant", ">= 0.0.4"
  s.add_dependency "zergrush_cf", ">= 0.0.1"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
