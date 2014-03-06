module VestalVersions
  # Instance methods added to VestalVersions::Version to accomodate incoming user information.
  module VersionUsers
    extend ActiveSupport::Concern

    included do
      belongs_to :user, :polymorphic => true

      alias_method_chain :user, :name
      alias_method_chain :user=, :name
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
