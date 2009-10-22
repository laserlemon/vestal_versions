module VestalVersions
  module Tagging
    def self.included(base)
      Version.send(:include, VersionMethods)
    end

    def tag_version(tag)
      v = versions.at(version) || versions.build(:number => 1)
      v.tag!(tag)
    end

    module VersionMethods
      def self.included(base)
        base.class_eval do
          validates_uniqueness_of :tag, :scope => [:versioned_id, :versioned_type], :if => :tagged?
        end
      end

      def tag!(tag)
        write_attribute(:tag, tag)
        save ? tag : nil
      end

      def tagged?
        !tag.nil?
      end
    end
  end
end
