require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
require 'rcov/rcovtask'
require 'rake/rdoctask'

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
