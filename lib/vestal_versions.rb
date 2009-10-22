%w(changes control creation reload reversion tagging version versions).each do |f|
  require File.join(File.dirname(__FILE__), 'vestal_versions', f)
end

module VestalVersions
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def versioned(options = {})
      class_inheritable_accessor :version_only_columns
      self.version_only_columns = Array(options[:only]).map(&:to_s).uniq if options[:only]
      class_inheritable_accessor :version_except_columns
      self.version_except_columns = Array(options[:except]).map(&:to_s).uniq if options[:except]

      has_many :versions, :as => :versioned, :order => 'versions.number ASC', :dependent => :delete_all, :extend => Versions

      include InstanceMethods
      include Changes
      include Creation
      include Reversion
      include Reload
    end
  end

  module InstanceMethods
  end
end

ActiveRecord::Base.send(:include, VestalVersions)
