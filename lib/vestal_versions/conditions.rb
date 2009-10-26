module VestalVersions
  module Conditions
    def self.included(base)
      base.alias_method_chain :create_version?, :conditions
      base.alias_method_chain :update_version?, :conditions
    end

    private
      def create_version_with_conditions?
        version_conditions_met? && create_version_without_conditions?
      end

      def update_version_with_conditions?
        version_conditions_met? && update_version_without_conditions?
      end

      def version_conditions_met?
        version_if.all?(&:call) && !version_unless.any?(&:call)
      end
  end
end
