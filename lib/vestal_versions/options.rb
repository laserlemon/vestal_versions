module VestalVersions
  module Options
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      def prepare_versioned_options(options)
        options.symbolize_keys!
        options.reverse_merge!(Configuration.options)
        options.reverse_merge!(
          :class_name => 'VestalVersions::Version',
          :dependent => :delete_all
        )

        class_inheritable_accessor :vestal_versions_options
        self.vestal_versions_options = options.dup

        options.merge!(
          :as => :versioned,
          :extend => Array(options[:extend]).unshift(Versions)
        )
      end
    end
  end
end
