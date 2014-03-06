module VestalVersions
  # Provides a way for information to be associated with specific versions as to who was
  # responsible for the associated update to the parent.
  module Users
    extend ActiveSupport::Concern

    included do
      attr_accessor :updated_by
    end

    # Methods added to versioned ActiveRecord::Base instances to enable versioning with additional
    # user information.
    
    
    private
    # Overrides the +version_attributes+ method to include user information passed into the
    # parent object, by way of a +updated_by+ attr_accessor.
    def version_attributes
      super.merge(:user => updated_by)
    end
  end
end
