# -*- encoding: utf-8 -*-
require File.expand_path("../lib/zergrush_cf/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "zergrush_cf"
  s.version     = ZergrushCF::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["MTN Satellite Communications"]
  s.email       = ["Marat.Garafutdinov@mtnsat.com"]
  s.homepage    = "https://github.com/MTNSatelliteComm/zerg"
  s.license     = "MIT"
  s.summary     = "Amazon Cloud Formation driver for zergrush"
  s.description = "Amazon Cloud Formation driver for zergrush"

  s.required_rubygems_version = ">= 2.0.0"
  s.rubyforge_project         = "zergrush_cf"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "zergrush", ">= 0.0.19"

  s.add_dependency "fog", ">=1.20.0"
  s.add_dependency "bunny", ">=1.2.1"
  s.add_dependency "retries", ">=0.0.5"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

  # metadata that marks this as a zergrush plugin
  s.metadata = { "zergrushplugin" => "driver" }
end
