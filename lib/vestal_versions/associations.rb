module VestalVersions
  # Allows associations to be automatically reverted_to a given instance method.
  module Associations
    def self.extended(base) # :nodoc:
      base.class_eval do
        valid_keys_for_belongs_to_association << :revert_to
        valid_keys_for_has_and_belongs_to_many_association << :revert_to
        valid_keys_for_has_many_association << :revert_to
        valid_keys_for_has_one_association << :revert_to

        extend ClassMethods

        class << self
          alias_method_chain :belongs_to, :reversion
          alias_method_chain :has_and_belongs_to_many, :reversion
          alias_method_chain :has_many, :reversion
          alias_method_chain :has_one, :reversion
        end
      end
    end

    module ClassMethods
      def belongs_to_with_reversion(association_id, options = {})
        returning(belongs_to_without_reversion(association_id, options)) do
          
        end
      end

      def has_and_belongs_to_many_with_reversion(association_id, options = {}, &extension)
        returning(has_and_belongs_to_many_without_reversion(association_id, options, &extension)) do
          
        end
      end

      def has_many_with_reversion(association_id, options = {}, &extension)
        returning(has_many_without_reversion(association_id, options, &extension)) do
          
        end
      end

      def has_one_with_reversion(association_id, options = {})
        returning(has_one_without_reversion(association_id, options)) do
          
        end
      end
    end

    class AssociationProxy
    end

    class AssociationCollection
    end
  end
end
