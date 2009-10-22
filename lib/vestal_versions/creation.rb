module VestalVersions
  module Creation
    def self.included(base)
      base.class_eval do
        after_update :create_version, :if => :create_version?
        after_update :update_version, :if => :update_version?
      end
    end

    private
      def create_version?
        !(versioned_columns & changed).empty?
      end

      def create_version
        versions.create(:changes => version_changes, :number => (last_version + 1))
        reset_version_changes
        reset_version
      end

      def update_version?
        false
      end

      def update_version
        (v = versions.last).update_attribute(:changes, v.changes.append_changes(version_changes))
        reset_version_changes
        reset_version
      end

      def versioned_columns
        case
          when version_only then self.class.column_names & version_only
          when version_except then self.class.column_names - version_except
          else self.class.column_names
        end - %w(created_at created_on updated_at updated_on)
      end
  end
end
