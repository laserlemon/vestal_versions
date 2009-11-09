module VestalVersions
  module Creation
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods

        after_update :create_version, :if => :create_version?
        after_update :update_version, :if => :update_version?

        class << self
          alias_method_chain :prepare_versioned_options, :creation
        end
      end
    end

    module ClassMethods
      def prepare_versioned_options_with_creation(options)
        prepare_versioned_options_without_creation(options)

        self.vestal_versions_options[:only] = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
        self.vestal_versions_options[:except] = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]
      end
    end

    module InstanceMethods
      private
        def create_version?
          version_changes.present?
        end

        def create_version
          versions.create(version_attributes)
          reset_version_changes
          reset_version
        end

        def update_version?
          false
        end

        def update_version
          (v = versions.last).changes_will_change!
          v.update_attribute(:changes, v.changes.append_changes(version_changes))
          reset_version_changes
          reset_version
        end

        def versioned_columns
          case
            when vestal_versions_options[:only] then self.class.column_names & vestal_versions_options[:only]
            when vestal_versions_options[:except] then self.class.column_names - vestal_versions_options[:except]
            else self.class.column_names
          end - %w(created_at created_on updated_at updated_on)
        end

        def version_attributes
          {:changes => version_changes, :number => last_version + 1}
        end
    end
  end
end
