module VestalVersions
  # Allows version creation to occur conditionally based on given <tt>:if</tt> and/or
  # <tt>:unless</tt> options.
  module Conditions
    def self.included(base) # :nodoc:
      base.class_eval do
        extend ClassMethods
        include InstanceMethods

        alias_method_chain :create_version?, :conditions
        alias_method_chain :update_version?, :conditions

        class << self
          alias_method_chain :prepare_versioned_options, :conditions
        end
      end
    end

    # Class methods on ActiveRecord::Base to prepare the <tt>:if</tt> and <tt>:unless</tt> options.
    module ClassMethods
      # After the original +prepare_versioned_options+ method cleans the given options, this alias
      # also extracts the <tt>:if</tt> and <tt>:unless</tt> options, chaning them into arrays
      # and converting any symbols to procs. Procs are called with the ActiveRecord model instance
      # as the sole argument.
      #
      # If all of the <tt>:if</tt> conditions are met and none of the <tt>:unless</tt> conditions
      # are unmet, than version creation will proceed, assuming all other conditions are also met.
      def prepare_versioned_options_with_conditions(options)
        result = prepare_versioned_options_without_conditions(options)

        self.vestal_versions_options[:if] = Array(options.delete(:if)).map(&:to_proc)
        self.vestal_versions_options[:unless] = Array(options.delete(:unless)).map(&:to_proc)

        result
      end
    end

    # Instance methods that determine based on the <tt>:if</tt> and <tt>:unless</tt> conditions,
    # whether a version is to be create or updated.
    module InstanceMethods
      private
        # After first determining whether the <tt>:if</tt> and <tt>:unless</tt> conditions are
        # satisfied, the original, unaliased +create_version?+ method is called to determine
        # whether a new version should be created upon update of the ActiveRecord::Base instance.
        def create_version_with_conditions?
          version_conditions_met? && create_version_without_conditions?
        end

        # After first determining whether the <tt>:if</tt> and <tt>:unless</tt> conditions are
        # satisfied, the original, unaliased +update_version?+ method is called to determine
        # whther the last version should be updated to include changes merged from the current
        # ActiveRecord::Base instance update.
        #
        # The overridden +update_version?+ method simply returns false, effectively delegating
        # the decision to whether the <tt>:if</tt> and <tt>:unless</tt> conditions are met.
        def update_version_with_conditions?
          version_conditions_met? && update_version_without_conditions?
        end

        # Simply checks whether the <tt>:if</tt> and <tt>:unless</tt> conditions given in the
        # +versioned+ options are met: meaning that all procs in the <tt>:if</tt> array must
        # evaluate to a non-false, non-nil value and that all procs in the <tt>:unless</tt> array
        # must all evaluate to either false or nil.
        def version_conditions_met?
          vestal_versions_options[:if].all?{|p| p.call(self) } && !vestal_versions_options[:unless].any?{|p| p.call(self) }
        end
    end
  end
end
