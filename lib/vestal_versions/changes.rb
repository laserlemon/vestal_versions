module VestalVersions
  module Changes
    def self.included(base)
      Hash.send(:include, HashMethods)
    end

    def changes_between(from, to)
      from_number, to_number = versions.number_at(from), versions.number_at(to)
      return {} if from_number == to_number
      chain = versions.between(from_number, to_number).reject(&:initial?)
      return {} if chain.empty?

      backward = from_number > to_number
      backward ? chain.pop : chain.shift unless [from_number, to_number].include?(1)

      chain.inject({}) do |changes, version|
        changes.append_changes!(backward ? version.changes.reverse_changes : version.changes)
      end
    end

    module HashMethods
      def append_changes(changes)
        changes.inject(self) do |new_changes, (attribute, change)|
          new_change = [new_changes.fetch(attribute, change).first, change.last]
          new_changes.merge!(attribute => new_change)
        end
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
        replace(reverse(perform))
      end
    end
  end
end
