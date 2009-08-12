require 'version'

module LaserLemon
  module VestalVersions
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def versioned
        has_many :versions, :as => :versioned, :order => 'versions.number ASC', :dependent => :destroy do
          def at(value)
            case value
            when Version: value
            when Numeric: find_by_number(value.floor)
            when Symbol: respond_to?(value) ? send(value) : nil
            when Date, Time: last(:conditions => ['versions.created_at <= ?', value.to_time.in_time_zone])
            end
          end
          
          def between(from_value, to_value)
            from, to = number_at(from_value), number_at(to_value)
            return [] if from.nil? || to.nil? || (from == to)
            all(
              :conditions => {:number => Range.new(*[from, to].sort)},
              :order => "versions.number #{(from > to) ? 'DESC' : 'ASC'}"
            )
          end
          
          private
          
          def number_at(value)
            case value
            when Version: value.number
            when Numeric: value.floor
            when Symbol, Date, Time: at(value).try(:number)
            end
          end
        end
        
        after_save :create_version, :if => :needs_version?
        
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      private
      
      def needs_version?
        !changed.empty?
      end
      
      def create_version
        if versions.empty?
          versions.create(:changes => attributes, :number => 1)
        else
          @version = nil
          versions.create(:changes => changes, :number => (version.to_i + 1))
        end
        
        @version = nil
      end
      
      public
      
      def version
        @version ||= versions.maximum(:number)
      end
      
      def revert_to(value)
        chain = versions.between(version, value)
        return version unless chain.size > 1
        
        new_version, backward = chain.last.number, (chain.first > chain.last)
        backward ? chain.pop : chain.shift
        
        chain.each do |version|
          version.changes.except('updated_at', 'updated_on').each do |attribute, change|
            write_attribute(attribute, backward ? change.first : change.last)
          end
        end
        
        @version = new_version
      end
      
      def revert_to!(value)
        revert_to(value) && save
      end
      
      def last_changes
        versions.at(version).changes
      end
      
      def last_changed
        last_changes.keys
      end
    end
  end
end

ActiveRecord::Base.send(:include, LaserLemon::VestalVersions)
