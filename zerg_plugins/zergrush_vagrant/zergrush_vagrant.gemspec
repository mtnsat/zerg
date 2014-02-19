# -*- encoding: utf-8 -*-
require File.expand_path("../lib/zergrush_vagrant/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "zergrush_vagrant"
  s.version     = ZergrushVagrant::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["MTN Satellite Communications"]
  s.email       = ["Marat.Garafutdinov@mtnsat.com"]
  s.homepage    = "https://github.com/MTNSatelliteComm/zerg"
  s.license     = "MIT"
  s.summary     = "Vagrant driver for zergrush"
  s.description = "Vagrant driver for zergrush"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "zergrush_vagrant"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rake"

  s.add_dependency "zergrush"
  s.add_dependency "vagrant-omnibus"
  s.add_dependency "vagrant-aws"
  s.add_dependency "vagrant-libvirt"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
