module VestalVersions
  # Allows associations to be automatically reverted_to a given instance method.
  module Associations
    def self.extended(base) # :nodoc:
      base.class_eval do
        valid_keys_for_belongs_to_association               << :revert_to
        valid_keys_for_has_and_belongs_to_many_association  << :revert_to
        valid_keys_for_has_many_association                 << :revert_to
        valid_keys_for_has_one_association                  << :revert_to
      end

      ActiveRecord::Associations::AssociationProxy.send(:include, AssociationProxy::Reversion)
      ActiveRecord::Associations::AssociationProxy.send(:include, AssociationProxy)
      ActiveRecord::Associations::AssociationCollection.send(:include, AssociationProxy)
    end

    module AssociationProxy
      def self.included(base) # :nodoc:
        base.class_eval do
          alias_method_chain :load_target, :reversion
        end
      end

      def load_target_with_reversion
        result = load_target_without_reversion
        revert_target if @reflection.options.has_key?(:revert_to)
        result
      end

      module Reversion
        private
          def revert_target
            case @target
              when ActiveRecord::Base then revert_record(@target)
              when Array then @target.each{|r| revert_record(r) }
            end
          end

          def revert_record(record)
            record.revert_to(@owner.send(@reflection.options[:revert_to])) if record.class.versioned?
          end
      end
    end
  end
end
