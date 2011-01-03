require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

if RUBY_VERSION < '1.9'
  desc "Run all tests with coverage"
  RSpec::Core::RakeTask.new :coverage => :cleanup_coverage_files do |t|
    t.rcov = true
    t.rcov_opts =  %[-Ilib -Ispec --exclude "gems/*,spec/support,spec/vestal_versions,spec/spec_helper.rb"]
  end
else
  desc 'Run all tests with coverage'
  task :coverage => :cleanup_coverage_files do
    require 'simplecov'

    SimpleCov.start do
      add_filter '/spec/'

      require 'rspec/core'
      spec_dir = File.expand_path('../spec', __FILE__)
      RSpec::Core::Runner.disable_autorun!
      RSpec::Core::Runner.run [spec_dir], STDERR, STDOUT
    end

  end
end

task :cleanup_coverage_files do
  rm_rf 'coverage*'
end

task :clobber => :cleanup_coverage_files do
  rm_rf 'pkg'
  rm_rf 'tmp'
end
