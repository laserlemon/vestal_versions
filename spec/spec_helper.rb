if ENV['COVERAGE']
  require 'coveralls'
  Coveralls.wear!
end

require 'vestal_versions'

require 'bundler'
Bundler.require(:test)

RSpec.configure do |c|
  c.before(:suite) do
    CreateSchema.suppress_messages{ CreateSchema.migrate(:up) }
  end

  c.after(:suite) do
    FileUtils.rm_rf(File.expand_path('../test.db', __FILE__))
  end

  c.after(:each) do
    VestalVersions::Version.config.clear
    User.prepare_versioned_options({})
  end

  c.order = 'random'
end

Dir[File.expand_path('../support/*.rb', __FILE__)].each{|f| require f }
