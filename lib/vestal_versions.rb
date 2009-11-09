Dir[File.join(File.dirname(__FILE__), 'vestal_versions', '*.rb')].each{|f| require f }

module VestalVersions
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      include Options
    end
  end

  module ClassMethods
    def versioned(options = {}, &block)
      include Changes
      include Creation
      include Users
      include Reversion
      include Reset
      include Conditions
      include Control
      include Tagging
      include Reload

      prepare_versioned_options(options)
      has_many :versions, options, &block
    end
  end

  extend Configuration
end

ActiveRecord::Base.send(:include, VestalVersions)
