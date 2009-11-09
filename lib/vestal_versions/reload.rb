module VestalVersions
  module Reload
    def self.included(base)
      base.class_eval do
        include InstanceMethods

        alias_method_chain :reload, :versions
      end
    end

    module InstanceMethods
      def reload_with_versions(*args)
        reset_version
        reload_without_versions(*args)
      end
    end
  end
end
