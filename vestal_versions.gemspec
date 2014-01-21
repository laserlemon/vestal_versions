# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = 'vestal_versions'
  gem.version = '1.2.3'

  gem.authors     = ['Steve Richert', "James O'Kelly"]
  gem.email       = ['steve.richert@gmail.com', 'dreamr.okelly@gmail.com']
  gem.description = "Keep a DRY history of your ActiveRecord models' changes"
  gem.summary     = gem.description
  gem.homepage    = 'http://github.com/laserlemon/vestal_versions'
  gem.license     = 'MIT'

  gem.add_dependency 'activerecord', '~> 3.0'
  gem.add_dependency 'activesupport', '~> 3.0'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ['lib']
end
