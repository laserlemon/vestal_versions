# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'vestal_versions/version_num'

Gem::Specification.new do |s|
  s.name        = 'vestal_versions'
  s.version     = VestalVersions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["laserlemon"]
  s.email       = ['steve@laserlemon.com']
  s.homepage    = 'http://github.com/laserlemon/vestal_versions'
  s.summary     = "Keep a DRY history of your ActiveRecord models' changes"
  s.description = "Keep a DRY history of your ActiveRecord models' changes"

  s.files         = `git ls-files lib`.split("\n") + ['README.rdoc', 'LICENSE']
  s.test_files    = `git ls-files spec`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_dependency 'activesupport', '>= 3.0.0'
  s.add_dependency 'railties', '>= 3.0.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rcov'
  s.add_development_dependency 'sqlite3-ruby'
end
