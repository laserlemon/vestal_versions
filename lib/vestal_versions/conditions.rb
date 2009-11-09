module VestalVersions
  module Conditions
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods

        alias_method_chain :create_version?, :conditions
        alias_method_chain :update_version?, :conditions

        class << self
          alias_method_chain :prepare_versioned_options, :conditions
        end
      end
    end

    module ClassMethods
      def prepare_versioned_options_with_conditions(options)
        prepare_versioned_options_without_conditions(options)

        self.vestal_versions_options[:if] = Array(options.delete(:if)).map(&:to_proc)
        self.vestal_versions_options[:unless] = Array(options.delete(:unless)).map(&:to_proc)
      end
    end

    module InstanceMethods
      private
        def create_version_with_conditions?
          version_conditions_met? && create_version_without_conditions?
        end

        def update_version_with_conditions?
          version_conditions_met? && update_version_without_conditions?
        end

        def version_conditions_met?
          vestal_versions_options[:if].all?{|p| p.call(self) } && !vestal_versions_options[:unless].any?{|p| p.call(self) }
        end
    end
  end
end
