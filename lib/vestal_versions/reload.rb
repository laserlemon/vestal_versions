module VestalVersions
  # Ties into the existing ActiveRecord::Base#reload method to ensure that version information
  # is properly reset.
  module Reload
    def self.included(base) # :nodoc:
      base.class_eval do
        include InstanceMethods

        alias_method_chain :reload, :versions
      end
    end

    # Adds instance methods into ActiveRecord::Base to tap into the +reload+ method.
    module InstanceMethods
      # Overrides ActiveRecord::Base#reload, resetting the instance-variable-cached version number
      # before performing the original +reload+ method.
      def reload_with_versions(*args)
        reset_version
        reload_without_versions(*args)
      end
    end
  end
end
