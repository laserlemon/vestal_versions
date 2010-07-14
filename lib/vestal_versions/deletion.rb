module VestalVersions
  # Allows version creation to occur conditionally based on given <tt>:if</tt> and/or
  # <tt>:unless</tt> options.
  module Deletion
    def self.included(base) # :nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods

        before_destroy :create_destroyed_version, :if => :delete_version?

        class << self
          alias_method_chain :prepare_versioned_options, :deletion
        end
      end
    end

    # Class methods on ActiveRecord::Base 
    module ClassMethods
      # After the original +prepare_versioned_options+ method cleans the given options, this alias
      # also extracts the <tt>:depedent</tt> if it set to <tt>:tracking</tt> 
      def prepare_versioned_options_with_deletion(options)
        result = prepare_versioned_options_without_deletion(options)
        if result[:dependent] == :tracking
          self.vestal_versions_options[:track_destroy] = true
          options.delete(:dependent)
        end

        result
      end
    end

    module InstanceMethods
      private

        def delete_version?
          vestal_versions_options[:track_destroy]
        end

        def create_destroyed_version
          versions.create({:modifications => attributes, :number => last_version + 1, :tag => 'deleted'})
        end

    end
  end
end
