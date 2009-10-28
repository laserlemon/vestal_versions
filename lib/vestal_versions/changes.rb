module VestalVersions
  module Changes
    def self.included(base)
      Hash.send(:include, HashMethods)

      base.class_eval do
        after_update :merge_version_changes
      end
    end

    def changes_between(from, to)
      from_number, to_number = versions.number_at(from), versions.number_at(to)
      return {} if from_number == to_number
      chain = versions.between(from_number, to_number).reject(&:initial?)
      return {} if chain.empty?

      backward = from_number > to_number
      backward ? chain.pop : chain.shift unless from_number == 1 || to_number == 1

      chain.inject({}) do |changes, version|
        changes.append_changes!(backward ? version.changes.reverse_changes : version.changes)
      end
    end

    private
      def merge_version_changes
        version_changes.append_changes!(incremental_version_changes)
      end

      def version_changes
        @version_changes ||= {}
      end

      def incremental_version_changes
        changes.slice(*versioned_columns)
      end

      def reset_version_changes
        @version_changes = nil
      end

    module HashMethods
      def append_changes(changes)
        changes.inject(self) do |new_changes, (attribute, change)|
          new_change = [new_changes.fetch(attribute, change).first, change.last]
          new_changes.merge!(attribute => new_change)
        end

        delete_if{|k,v| v.first == v.last }
      end

      def append_changes!(changes)
        replace(append_changes(changes))
      end

      def prepend_changes(changes)
        changes.append_changes(self)
      end

      def prepend_changes!(changes)
        replace(prepend_changes(changes))
      end

      def reverse_changes
        inject({}){|nc,(a,c)| nc.merge!(a => c.reverse) }
      end

      def reverse_changes!
        replace(reverse_changes)
      end
    end
  end
end
