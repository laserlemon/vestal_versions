module VestalVersions
  # Allows version creation to occur conditionally based on given <tt>:if</tt> and/or
  # <tt>:unless</tt> options.
  module Deletion
    extend ActiveSupport::Concern

    included do
      before_destroy :create_destroyed_version, :if => :delete_version?
    end

    # Class methods on ActiveRecord::Base
    module ClassMethods
      # After the original +prepare_versioned_options+ method cleans the given options, this alias
      # also extracts the <tt>:depedent</tt> if it set to <tt>:tracking</tt>
      def prepare_versioned_options(options)
        result = super(options)
        if result[:dependent] == :tracking
          self.vestal_versions_options[:track_destroy] = true
          options.delete(:dependent)
        end

        result
      end
    end

		private

			def delete_version?
				vestal_versions_options[:track_destroy]
			end

			def create_destroyed_version
				create_version({:modifications => attributes, :number => last_version + 1, :tag => 'deleted'})
			end

  end
end
