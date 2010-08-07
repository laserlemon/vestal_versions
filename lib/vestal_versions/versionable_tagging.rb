module VestalVersions
  # Allows specific versions to be versionable_tagged with a custom string. Useful for assigning a more
  # meaningful value to a version for the purpose of reversion.
  module VersionableTagging
    def self.included(base) # :nodoc:
      Version.send(:include, VersionMethods)

      base.class_eval do
        include InstanceMethods
      end
    end

    # Adds an instance method which allows version versionable_tagging through the parent object.
    module InstanceMethods
      # Accepts a single string argument which is attached to the version record associated with
      # the current version number of the parent object.
      #
      # Returns the given versionable_tag if successful, nil if not. VersionableTags must be unique within the scope of
      # the parent object. VersionableTag creation will fail if non-unique.
      #
      # Version records corresponding to version number 1 are not typically created, but one will
      # be built to house the given versionable_tag if the parent object's current version number is 1.
      def versionable_tag_version(versionable_tag)
        v = versions.at(version) || versions.build(:number => 1)
        v.versionable_tag!(versionable_tag)
      end
    end

    # Instance methods included into VestalVersions::Version to enable version versionable_tagging.
    module VersionMethods
      def self.included(base) # :nodoc:
        base.class_eval do
          validates_uniqueness_of :versionable_tag, :scope => [:versioned_id, :versioned_type], :if => :versionable_tagged?
        end
      end

      # Attaches the given string to the version versionable_tag column. If the uniqueness validation fails,
      # nil is returned. Otherwise, the given string is returned.
      def versionable_tag!(versionable_tag)
        write_attribute(:versionable_tag, versionable_tag)
        save ? versionable_tag : nil
      end

      # Simply returns a boolean signifying whether the version instance has a versionable_tag value attached.
      def versionable_tagged?
        !versionable_tag.nil?
      end
    end
  end
end
