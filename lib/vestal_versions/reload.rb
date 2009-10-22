module VestalVersions
  module Reload
    def self.included(base)
      base.alias_method_chain :reload, :versions
    end

    def reload_with_versions(*args)
      reset_version
      reload_without_versions(*args)
    end
  end
end
