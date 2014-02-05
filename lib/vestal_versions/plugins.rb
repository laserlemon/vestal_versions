module VestalVersions
  # Allows custom modules to be loaded based on given <tt>:plugins</tt> option
  module Plugins
    extend ActiveSupport::Concern
    # Class methods on ActiveRecord::Base to prepare the <tt>:plugins</tt> option.
    module ClassMethods
      # After the original +prepare_versioned_options+ method cleans the given options, this alias
      # also extracts the <tt>:plugins</tt> and includes them if required
      def prepare_versioned_options(options)
        result = super(options)

        # Pull the plugins out of options, constantize or ensure they're a Module, otherwise drop them
        plugins = Array(result.delete :plugins).map{|p|
          if p.is_a? Module
            p
          elsif p.is_a? String
            p.constantize
          end
        }.flatten.compact

        # Include requested plugins
        plugins.each {|p| include p unless self.included_modules.include? p}
        self.vestal_versions_options[:plugins] = plugins

        result
      end
    end
  end
end
