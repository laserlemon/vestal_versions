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
        when Version then value
        when Numeric then find_by_number(value.floor)
        when Date, Time then last(:conditions => ["#{aliased_table_name}.created_at <= ?", value.to_time])
        when Symbol then respond_to?(value) ? send(value) : nil
      end
    end

    def number_at(value)
      case value
        when Version then value.number
        when Numeric then value.floor
        when Date, Time then at(value).try(:number) || 1
        when Symbol then at(value).try(:number)
      end
    end
  end
end
