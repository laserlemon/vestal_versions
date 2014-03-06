module VestalVersions
  # Allows specific versions to be tagged with a custom string. Useful for assigning a more
  # meaningful value to a version for the purpose of reversion.
  module VersionTagging
    extend ActiveSupport::Concern

    # Adds an instance method which allows version tagging through the parent object.

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
      t = v.tag!(tag)
      versions.reload
      t
    end
  end
end
