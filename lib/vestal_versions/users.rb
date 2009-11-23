module VestalVersions
  # Provides a way for information to be associated with specific versions as to who was
  # responsible for the associated update to the parent.
  module Users
    def self.included(base) # :nodoc:
      Version.send(:include, VersionMethods)

      base.class_eval do
        include InstanceMethods

        attr_accessor :updated_by
        alias_method_chain :version_attributes, :user
      end
    end

    # Methods added to versioned ActiveRecord::Base instances to enable versioning with additional
    # user information.
    module InstanceMethods
      private
        # Overrides the +version_attributes+ method to include user information passed into the
        # parent object, by way of a +updated_by+ attr_accessor.
        def version_attributes_with_user
          version_attributes_without_user.merge(:user => updated_by)
        end
    end

    # Instance methods added to VestalVersions::Version to accomodate incoming user information.
    module VersionMethods
      def self.included(base) # :nodoc:
        base.class_eval do
          belongs_to :user, :polymorphic => true

          alias_method_chain :user, :name
          alias_method_chain :user=, :name
        end
      end

      # Overrides the +user+ method created by the polymorphic +belongs_to+ user association. If
      # the association is absent, defaults to the +user_name+ string column. This allows
      # VestalVersions::Version#user to either return an ActiveRecord::Base object or a string,
      # depending on what is sent to the +user_with_name=+ method.
      def user_with_name
        user_without_name || user_name
      end

      # Overrides the +user=+ method created by the polymorphic +belongs_to+ user association.
      # Based on the class of the object given, either the +user+ association columns or the
      # +user_name+ string column is populated.
      def user_with_name=(value)
        case value
          when ActiveRecord::Base then self.user_without_name = value
          else self.user_name = value
        end
      end
    end
  end
end
