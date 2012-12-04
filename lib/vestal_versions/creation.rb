module VestalVersions
  # Adds the functionality necessary to control version creation on a versioned instance of
  # ActiveRecord::Base.
  module Creation
    extend ActiveSupport::Concern

    included do
      after_create :create_initial_version, :if => :create_initial_version?
      after_update :create_version, :if => :create_version?
      after_update :update_version, :if => :update_version?
    end

    # Class methods added to ActiveRecord::Base to facilitate the creation of new versions.
    module ClassMethods
      # Overrides the basal +prepare_versioned_options+ method defined in VestalVersions::Options
      # to extract the <tt>:only</tt>, <tt>:except</tt> and <tt>:initial_version</tt> options
      # into +vestal_versions_options+.
      def prepare_versioned_options(options)
        result = super(options)

        self.vestal_versions_options[:only] = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
        self.vestal_versions_options[:except] = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]
        self.vestal_versions_options[:initial_version] = options.delete(:initial_version)
        
        result
      end
    end

    # Instance methods that determine whether to save a version and actually perform the save.

		private
			# Returns whether an initial version should be created upon creation of the parent record.
			def create_initial_version?
				vestal_versions_options[:initial_version] == true
			end

			# Creates an initial version upon creation of the parent record.
			def create_initial_version
				versions.create(version_attributes.merge(:number => 1))
				reset_version_changes
				reset_version
			end
							
			# Returns whether a new version should be created upon updating the parent record.
			def create_version?
				!version_changes.blank?
			end

			# Creates a new version upon updating the parent record.
			def create_version(attributes = nil)
				versions.create(attributes || version_attributes)
				reset_version_changes
				reset_version
			end

			# Returns whether the last version should be updated upon updating the parent record.
			# This method is overridden in VestalVersions::Control to account for a control block that
			# merges changes onto the previous version.
			def update_version?
				false
			end

			# Updates the last version's changes by appending the current version changes.
			def update_version
				return create_version unless v = versions.last
				v.modifications_will_change!
				v.update_attribute(:modifications, v.changes.append_changes(version_changes))
				reset_version_changes
				reset_version
			end

			# Returns an array of column names that should be included in the changes of created
			# versions. If <tt>vestal_versions_options[:only]</tt> is specified, only those columns
			# will be versioned. Otherwise, if <tt>vestal_versions_options[:except]</tt> is specified,
			# all columns will be versioned other than those specified. Without either option, the
			# default is to version all columns. At any rate, the four "automagic" timestamp columns
			# maintained by Rails are never versioned.
			def versioned_columns
				case
					when vestal_versions_options[:only] then self.class.column_names & vestal_versions_options[:only]
					when vestal_versions_options[:except] then self.class.column_names - vestal_versions_options[:except]
					else self.class.column_names
				end - %w(created_at created_on updated_at updated_on)
			end

			# Specifies the attributes used during version creation. This is separated into its own
			# method so that it can be overridden by the VestalVersions::Users feature.
			def version_attributes
				{:modifications => version_changes, :number => last_version + 1}
			end
  end
end
