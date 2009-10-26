module VestalVersions
  module Reset
    def self.included(base)
      Version.send(:include, VersionMethods)
    end

    def reset_to!(value)
      if saved = skip_version{ revert_to(value) }
        versions.between(value, last_version).each(&version_reset_method)
        versions.reload
        reset_version
      end
      saved
    end

    private
      def version_reset_method
        vestal_versions_options[:dependent].to_s.gsub(/_all$/, '').to_sym
      end

    module VersionMethods
      def nullify
        update_attribute(:versioned_id, nil)
      end
    end
  end
end
