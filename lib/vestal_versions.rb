%w(changes conditions control creation reload reversion tagging version versions).each do |f|
  require File.join(File.dirname(__FILE__), 'vestal_versions', f)
end

module VestalVersions
  def versioned(options = {}, &block)
    class << self
      def versioned?
        true
      end
    end

    options.symbolize_keys!

    class_inheritable_accessor :version_only, :version_except
    self.version_only = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
    self.version_except = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]

    class_inheritable_accessor :version_if, :version_unless
    self.version_if = Array(options.delete(:if)).map(&:to_proc)
    self.version_unless = Array(options.delete(:unless)).map(&:to_proc)

    options.merge!(
      :as => :versioned,
      :extend => Array(options[:extend]).unshift(Versions)
    ).reverse_merge!(
      :class_name => '::VestalVersions::Version',
      :dependent => :delete_all
    )

    has_many :versions, options, &block

    include Changes
    include Creation
    include Reversion
    include Conditions
    include Control
    include Tagging
    include Reload
  end

  def versioned?
    false
  end
end

ActiveRecord::Base.extend(VestalVersions)
