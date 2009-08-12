# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vestal_versions}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve Richert"]
  s.date = %q{2009-08-12}
  s.description = %q{Keep a DRY history of your ActiveRecord models' changes}
  s.email = %q{steve@laserlemon.com}
  s.extra_rdoc_files = ["lib/version.rb", "lib/vestal_versions.rb", "README.rdoc", "tasks/vestal_versions_tasks.rake"]
  s.files = ["generators/vestal_versions_migration/templates/migration.rb", "generators/vestal_versions_migration/vestal_versions_migration_generator.rb", "init.rb", "lib/version.rb", "lib/vestal_versions.rb", "Manifest", "MIT-LICENSE", "Rakefile", "README.rdoc", "tasks/vestal_versions_tasks.rake", "test/test_helper.rb", "test/vestal_versions_test.rb", "VERSION.yml", "vestal_versions.gemspec"]
  s.homepage = %q{http://github.com/laserlemon/vestal_versions}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Vestal_versions", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{vestal_versions}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Keep a DRY history of your ActiveRecord models' changes}
  s.test_files = ["test/test_helper.rb", "test/vestal_versions_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
