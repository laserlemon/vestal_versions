module VestalVersions
  module Creation
    def self.included(base)
      base.class_eval do
        after_update :create_version, :if => :needs_version?
      end
    end

    private
      def needs_version?
        !(versioned_columns & changed).empty?
      end

      def create_version
        versions.create(:changes => changes.slice(*versioned_columns), :number => (last_version + 1))
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
