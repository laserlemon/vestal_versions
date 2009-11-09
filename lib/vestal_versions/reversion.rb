module VestalVersions
  module Reversion
    def self.included(base)
      base.class_eval do
        include InstanceMethods
      end
    end

    module InstanceMethods
      def version
        @version ||= last_version
      end

      def revert_to(value)
        to_number = versions.number_at(value)

        changes_between(version, to_number).each do |attribute, change|
          write_attribute(attribute, change.last)
        end

        reset_version(to_number)
      end

      def revert_to!(value)
        revert_to(value)
        reset_version if saved = save
        saved
      end

      def reverted?
        version != last_version
      end

      private
        def last_version
          @last_version ||= versions.maximum(:number) || 1
        end

        def reset_version(version = nil)
          @last_version = nil if version.nil?
          @version = version
        end
    end
  end
end
