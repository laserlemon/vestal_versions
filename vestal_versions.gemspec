# encoding: utf-8

Gem::Specification.new do |gem|
  gem.name    = 'vestal_versions'
  gem.version = '2.0.1'

  gem.authors     = ['Steve Richert', "James O'Kelly", 'C. Jason Harrelson']
  gem.email       = ['steve.richert@gmail.com', 'dreamr.okelly@gmail.com', 'jason@lookforwardenterprises.com']
  gem.description = "Keep a DRY history of your ActiveRecord models' changes"
  gem.summary     = gem.description
  gem.homepage    = 'http://github.com/laserlemon/vestal_versions'
  gem.license     = 'MIT'

  gem.add_dependency 'activerecord', '>= 4.1.0.rc1', '< 5'
  gem.add_dependency 'activesupport', '>= 4.1.0.rc1', '< 5'

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 10.0'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(/^spec/)
  gem.require_paths = ['lib']
end
