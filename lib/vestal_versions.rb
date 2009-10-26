%w(changes conditions configuration control creation reload reset reversion tagging version versions).each do |f|
  require File.join(File.dirname(__FILE__), 'vestal_versions', f)
end

module VestalVersions
  class << self
    def configure
      yield Configuration
    end
  end

  def versioned(options = {}, &block)
    class << self
      def versioned?
        true
      end
    end

    options.symbolize_keys!
    options.reverse_merge!(Configuration.options)
    options.reverse_merge!(
      :class_name => '::VestalVersions::Version',
      :dependent => :delete_all
    )

    class_inheritable_accessor :vestal_versions_options
    self.vestal_versions_options = options.dup

    self.vestal_versions_options[:only] = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
    self.vestal_versions_options[:except] = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]

    self.vestal_versions_options[:if] = Array(options.delete(:if)).map(&:to_proc)
    self.vestal_versions_options[:unless] = Array(options.delete(:unless)).map(&:to_proc)

    options.merge!(
      :as => :versioned,
      :extend => Array(options[:extend]).unshift(Versions)
    )

    has_many :versions, options, &block

    include Changes
    include Creation
    include Reversion
    include Reset
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
