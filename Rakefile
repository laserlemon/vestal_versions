require 'rubygems'
require 'rake'
require 'rake/testtask'
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
    g.add_development_dependency 'thoughtbot-shoulda'
    g.rubyforge_project = 'laser-lemon'
  end
  Jeweler::RubyforgeTasks.new do |r|
    r.doc_task = 'rdoc'
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com'
end

Rake::TestTask.new do |t|
  t.libs = %w(test)
  t.pattern = 'test/**/*_test.rb'
end

task :default => :test

Rake::RDocTask.new do |r|
  version = File.exist?('VERSION') ? File.read('VERSION') : nil
  r.rdoc_dir = 'rdoc'
  r.title = ['vestal_versions', version].compact.join(' ')
  r.rdoc_files.include('README*')
  r.rdoc_files.include('lib/**/*.rb')
end
