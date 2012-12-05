# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'vestal_versions/version_num'

files = ["README*", "LICENSE", "lib/**/*"].map do |glob|
  Dir[glob]
end.flatten
test_files = ["spec/**/*"].map do |glob|
  Dir[glob]
end.flatten

Gem::Specification.new do |s|
  s.name        = 'vestal_versions'
  s.version     = VestalVersions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Adam Cooper"]
  s.email       = ['adam.cooper@gmail.com']
  s.homepage    = 'http://github.com/adamcooper/vestal_versions'
  s.summary     = "Keep a DRY history of your ActiveRecord models' changes"
  s.description = "Keep a DRY history of your ActiveRecord models' changes"

  s.files         = files
  s.test_files    = test_files
  s.require_paths = ['lib']

  s.add_dependency 'activerecord', '>= 3.0.0'
  s.add_dependency 'activesupport', '>= 3.0.0'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'rake'
end
