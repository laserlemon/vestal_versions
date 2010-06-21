require 'rails/generators'

class VestalVersionsGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration
  
  argument :name, :type => :string, :default => "create_vestal_versions"
  source_root File.expand_path('../templates', __FILE__)
  
  def generate_files
    migration_template 'migration.rb', File.join('db', 'migrate', 'create_vestal_versions')
    template 'initializer.rb', File.join('config', 'initializers', 'vestal_versions.rb')
  end
  
protected
  # Lets make this hacky thing while ticket #3820 isn't applied again...
  # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/3820
  def self.next_migration_number(dirname) #:nodoc:
    orm = Rails.configuration.generators.options[:rails][:orm]
    require "rails/generators/#{orm}"
    "#{orm.to_s.camelize}::Generators::Base".constantize.next_migration_number(dirname)
  rescue
    raise NotImplementedError
  end
end
