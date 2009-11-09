module VestalVersions
  module Users
    def self.included(base)
      Version.send(:include, VersionMethods)

      base.class_eval do
        include InstanceMethods

        attr_accessor :updated_by
        alias_method_chain :version_attributes, :user
      end
    end

    module InstanceMethods
      private
        def version_attributes_with_user
          version_attributes_without_user.merge(:user => updated_by)
        end
    end

    module VersionMethods
      def self.included(base)
        base.class_eval do
          belongs_to :user, :polymorphic => true

          alias_method_chain :user, :name
          alias_method_chain :user=, :name
        end
      end

      def user_with_name
        user_without_name || user_name
      end

      def user_with_name=(value)
        case value
          when ActiveRecord::Base then self.user_without_name = value
          else self.user_name = value
        end
      end
    end
  end
end
