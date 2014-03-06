module VestalVersions
  # Instance methods included into VestalVersions::Version to enable version tagging.
  module VersionVersionTagging
    extend ActiveSupport::Concern

    included do
      validates_uniqueness_of :tag, :scope => [:versioned_id, :versioned_type], :if => :validate_tags?
    end

    # Attaches the given string to the version tag column. If the uniqueness validation fails,
    # nil is returned. Otherwise, the given string is returned.
    def tag!(tag)
      write_attribute(:tag, tag)
      save ? tag : nil
    end

    # Simply returns a boolean signifying whether the version instance has a tag value attached.
    def tagged?
      !tag.nil?
    end

    def validate_tags?
      tagged? && tag != 'deleted'
    end
  end
end
