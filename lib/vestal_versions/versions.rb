module VestalVersions
  module Versions
    def between(from, to)
      from_number, to_number = number_at(from), number_at(to)
      return [] if from_number.nil? || to_number.nil?

      condition = (from_number == to_number) ? to_number : Range.new(*[from_number, to_number].sort)
      all(
        :conditions => {:number => condition},
        :order => "#{aliased_table_name}.number #{(from_number > to_number) ? 'DESC' : 'ASC'}"
      )
    end

    def at(value)
      case value
        when Date, Time then last(:conditions => ["#{aliased_table_name}.created_at <= ?", value.to_time])
        when Numeric then find_by_number(value.floor)
        when String then first(:conditions => {:tag => value})
        when Symbol then respond_to?(value) ? send(value) : nil
        when Version then value
      end
    end

    def number_at(value)
      case value
        when Date, Time then at(value).try(:number) || 1
        when Numeric then value.floor
        when String, Symbol then at(value).try(:number)
        when Version then value.number
      end
    end
  end
end
