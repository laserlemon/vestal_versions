require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rcov/rcovtask'
require 'rake/rdoctask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |g|
    g.name = 'vestal_versions'
    g.summary = %(Keep a DRY history of your ActiveRecord models' changes)
    g.description = %(Keep a DRY history of your ActiveRecord models' changes)
    g.email = 'steve@laserlemon.com'
    g.homepage = 'http://github.com/laserlemon/vestal_versions'
    g.authors = %w(laserlemon)
    g.add_dependency 'activerecord', '>= 3.0.0.beta4'
    g.add_development_dependency 'shoulda'
    g.add_development_dependency 'mocha'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler'
end

Rake::TestTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/**/*_test.rb'
end

Rcov::RcovTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/**/*_test.rb'
end

task :test => :check_dependencies
task :default => :test

Rake::RDocTask.new do |r|
  version = File.exist?('VERSION') ? File.read('VERSION') : nil
  r.rdoc_dir = 'rdoc'
  r.title = ['vestal_versions', version].compact.join(' ')
  r.options << '--line-numbers' << '--inline-source'
  r.rdoc_files.include('README*')
  r.rdoc_files.include('lib/**/*.rb')
end
