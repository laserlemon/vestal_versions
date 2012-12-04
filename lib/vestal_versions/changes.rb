module VestalVersions
  # Provides the ability to manipulate hashes in the specific format that ActiveRecord gives to
  # dirty attribute changes: string keys and unique, two-element array values.
  module Changes
    extend ActiveSupport::Concern
    included do
      Hash.class_eval{ include HashMethods }

      after_update :merge_version_changes
    end

    # Methods available to versioned ActiveRecord::Base instances in order to manage changes used
    # for version creation.

		# Collects an array of changes from a record's versions between the given range and compiles
		# them into one summary hash of changes. The +from+ and +to+ arguments can each be either a
		# version number, a symbol representing an association proxy method, a string representing a
		# version tag or a version object itself.
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
			# Before a new version is created, the newly-changed attributes are appended onto a hash
			# of previously-changed attributes. Typically the previous changes will be empty, except in
			# the case that a control block is used where versions are to be merged. See
			# VestalVersions::Control for more information.
			def merge_version_changes
				version_changes.append_changes!(incremental_version_changes)
			end

			# Stores the cumulative changes that are eventually used for version creation.
			def version_changes
				@version_changes ||= {}
			end

			# Stores the incremental changes that are appended to the cumulative changes before version
			# creation. Incremental changes are reset when the record is saved because they represent
			# a subset of the dirty attribute changes, which are reset upon save.
			def incremental_version_changes
				changes.slice(*versioned_columns)
			end

			# Simply resets the cumulative changes after version creation.
			def reset_version_changes
				@version_changes = nil
			end

    # Instance methods included into Hash for dealing with manipulation of hashes in the specific
    # format of ActiveRecord::Base#changes.
    module HashMethods
      # When called on a hash of changes and given a second hash of changes as an argument,
      # +append_changes+ will run the second hash on top of the first, updating the last element
      # of each array value with its own, or creating its own key/value pair for missing keys.
      # Resulting non-unique array values are removed.
      #
      # == Example
      #
      # first = {
      #   "first_name" => ["Steve", "Stephen"],
      #   "age" => [25, 26]
      # }
      # second = {
      #   "first_name" => ["Stephen", "Steve"],
      #   "last_name" => ["Richert", "Jobs"],
      #   "age" => [26, 54]
      # }
      # first.append_changes(second)
      # # => {
      #   "last_name" => ["Richert", "Jobs"],
      #   "age" => [25, 54]
      # }
      def append_changes(changes)
        changes.inject(self) do |new_changes, (attribute, change)|
          new_change = [new_changes.fetch(attribute, change).first, change.last]
          new_changes.merge(attribute => new_change)
        end.reject do |attribute, change|
          change.first == change.last
        end
      end

      # Destructively appends a given hash of changes onto an existing hash of changes.
      def append_changes!(changes)
        replace(append_changes(changes))
      end

      # Appends the existing hash of changes onto a given hash of changes. Relates to the
      # +append_changes+ method in the same way that Hash#reverse_merge relates to
      # Hash#merge.
      def prepend_changes(changes)
        changes.append_changes(self)
      end

      # Destructively prepends a given hash of changes onto an existing hash of changes.
      def prepend_changes!(changes)
        replace(prepend_changes(changes))
      end

      # Reverses the array values of a hash of changes. Useful for reversion both backward and
      # forward through a record's history of changes.
      def reverse_changes
        inject({}){|nc,(a,c)| nc.merge!(a => c.reverse) }
      end

      # Destructively reverses the array values of a hash of changes.
      def reverse_changes!
        replace(reverse_changes)
      end
    end
  end
end
