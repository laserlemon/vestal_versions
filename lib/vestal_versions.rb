require 'version'

module LaserLemon
  module VestalVersions
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      def versioned
        has_many :versions, :as => :versioned, :order => 'versions.number', :dependent => :destroy, :autosave => true do
          def current
            first(:conditions => {:number => versioned.version})
          end
          
          def at(value)
            case value
            when Version: value
            when Symbol: send(value)
            when Numeric: first(:conditions => {:number => value.floor})
            when Date, Time: last(:conditions => ['versions.created_at <= ?', value.to_time])
            end
          end
          
          def between(from_value, to_value)
            from, to = at(from_value), at(to_value)
            return [] unless [from, to].all?{|v| v.is_a?(Version) }
            all(
              :conditions => {:number => ([from, to].min.number..[from, to].max.number)},
              :order => "versions.number #{(from > to) ? 'DESC' : 'ASC'}"
            )
          end
        end
        
        before_save :build_version
        
        include InstanceMethods
      end
    end
    
    module InstanceMethods
      def build_version
        @version = nil
        unless changes.blank?
          if versions.empty?
            content_columns = self.class.column_names.delete_if{|c| c == self.class.primary_key }.delete_if{|c| c =~ /^(cre|upd)ated_(at|on)$/ }
            content_attributes = attributes.slice(*content_columns)
            if new_record?
              versions.build(:changes => content_attributes)
            else
              reverted_attributes = content_attributes.inject({}){|h,(k,v)| h.update(k => (changed.include?(k) ? changes[k].first : v)) }
              version_timestamp = (try(:updated_at) || try(:created_at))
              versions.build(:changes => reverted_attributes, :created_at => version_timestamp)
            end
          end
          versions.build(:changes => changes) unless new_record?
        end
      end
      
      def version
        @version ||= begin
          last_version = versions.last
          last_version.nil? ? 1 : last_version.number
        end
      end
      
      def revert_to(value)
        chain = versions.between(version, value)
        return version unless chain.size > 1
        new_version, backward = chain.last.number, (chain.first > chain.last)
        backward ? chain.pop : chain.shift
        chain.each do |version|
          version.changes.each do |attribute, change|
            write_attribute(attribute, backward ? change.first : change.last)
          end
        end
        @version = new_version
      end
      
      def revert_to!(value)
        revert_to(value) && save
      end
    end
  end
end

ActiveRecord::Base.send(:include, LaserLemon::VestalVersions)
