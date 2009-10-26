class VestalVersionsGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', File.join('db', 'migrate'), :migration_file_name => 'create_vestal_versions'

      m.directory File.join('config', 'initializers')
      m.template 'initializer.rb', File.join('config', 'initializers', 'vestal_versions.rb')
    end
  end
end
