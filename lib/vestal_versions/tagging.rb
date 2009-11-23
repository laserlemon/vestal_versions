module VestalVersions
  # Allows specific versions to be tagged with a custom string. Useful for assigning a more
  # meaningful value to a version for the purpose of reversion.
  module Tagging
    def self.included(base) # :nodoc:
      Version.send(:include, VersionMethods)

      base.class_eval do
        include InstanceMethods
      end
    end

    # Adds an instance method which allows version tagging through the parent object.
    module InstanceMethods
      # Accepts a single string argument which is attached to the version record associated with
      # the current version number of the parent object.
      #
      # Returns the given tag if successful, nil if not. Tags must be unique within the scope of
      # the parent object. Tag creation will fail if non-unique.
      #
      # Version records corresponding to version number 1 are not typically created, but one will
      # be built to house the given tag if the parent object's current version number is 1.
      def tag_version(tag)
        v = versions.at(version) || versions.build(:number => 1)
        v.tag!(tag)
      end
    end

    # Instance methods included into VestalVersions::Version to enable version tagging.
    module VersionMethods
      def self.included(base) # :nodoc:
        base.class_eval do
          validates_uniqueness_of :tag, :scope => [:versioned_id, :versioned_type], :if => :tagged?
        end
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
    end
  end
end
