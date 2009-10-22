module VestalVersions
  module Changes
    def changes_between(from, to)
      from_number, to_number = versions.number_at(from), versions.number_at(to)
      return {} if from_number == to_number
      chain = versions.between(from_number, to_number).reject(&:initial?)
      return {} if chain.empty?

      backward = from_number > to_number
      backward ? chain.pop : chain.shift unless [from_number, to_number].include?(1)

      chain.inject({}) do |changes, version|
        version.changes.each do |attribute, change|
          change.reverse! if backward
          new_change = [changes.fetch(attribute, change).first, change.last]
          changes.update(attribute => new_change)
        end
        changes
      end
    end
  end
end
