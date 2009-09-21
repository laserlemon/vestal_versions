require 'version'

module LaserLemon
  module VestalVersions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def versioned
        has_many :versions, :as => :versioned, :order => 'versions.number ASC', :dependent => :delete_all do
          def between(from, to)
            from_number, to_number = number_at(from), number_at(to)
            return [] if from_number.nil? || to_number.nil?
            condition = (from_number == to_number) ? to_number : Range.new(*[from_number, to_number].sort)
            all(
              :conditions => {:number => condition},
              :order => "versions.number #{(from_number > to_number) ? 'DESC' : 'ASC'}"
            )
          end

          def at(value)
            case value
              when Version then value
              when Numeric then find_by_number(value.floor)
              when Symbol then respond_to?(value) ? send(value) : nil
              when Date, Time then last(:conditions => ['versions.created_at <= ?', value.to_time])
            end
          end

          def number_at(value)
            case value
              when Version then value.number
              when Numeric then value.floor
              when Symbol, Date, Time then at(value).try(:number)
            end
          end
        end

        after_create :create_initial_version
        after_update :create_initial_version, :if => :needs_initial_version?
        after_update :create_version, :if => :needs_version?

        include InstanceMethods
        alias_method_chain :reload, :versions
      end
    end

    module InstanceMethods
      private
        def needs_initial_version?
          versions.empty?
        end

        def needs_version?
          !changed.empty?
        end

        def reset_version(new_version = nil)
          @last_version = nil if new_version.nil?
          @version = new_version
        end

        def create_initial_version
          versions.create(:changes => nil, :number => 1)
        end

        def create_version
          versions.create(:changes => changes, :number => (last_version + 1))
          reset_version
        end

      public
        def version
          @version ||= last_version
        end

        def last_version
          @last_version ||= versions.maximum(:number)
        end

        def reverted?
          version != last_version
        end

        def reload_with_versions(*args)
          reset_version
          reload_without_versions(*args)
        end

        def revert_to(value)
          to_number = versions.number_at(value)
          return version if to_number == version
          chain = versions.between(version, to_number)
          return version if chain.empty?

          new_version = chain.last.number
          backward = chain.first > chain.last
          backward ? chain.pop : chain.shift

          timestamps = %w(created_at created_on updated_at updated_on)

          chain.each do |version|
            version.changes.except(*timestamps).each do |attribute, change|
              new_value = backward ? change.first : change.last
              write_attribute(attribute, new_value)
            end
          end

          reset_version(new_version)
        end

        def revert_to!(value)
          revert_to(value)
          reset_version if saved = save
          saved
        end

        def latest_changes
          return {} if version.nil? || version == 1
          versions.at(version).changes
        end
    end
  end
end

ActiveRecord::Base.send(:include, LaserLemon::VestalVersions)
