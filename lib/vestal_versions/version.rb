require 'active_record'
require 'active_support/configurable'

module VestalVersions
  # The ActiveRecord model representing versions.
  class Version < ActiveRecord::Base
    include Comparable
    include ActiveSupport::Configurable

    # Associate polymorphically with the parent record.
    belongs_to :versioned, :polymorphic => true

    # ActiveRecord::Base#changes is an existing method, so before serializing the +changes+ column,
    # the existing +changes+ method is undefined. The overridden +changes+ method pertained to
    # dirty attributes, but will not affect the partial updates functionality as that's based on
    # an underlying +changed_attributes+ method, not +changes+ itself.
    undef_method :changes
    def changes
      self[:modifications]
    end
    serialize :modifications, Hash

    # In conjunction with the included Comparable module, allows comparison of version records
    # based on their corresponding version numbers, creation timestamps and IDs.
    def <=>(other)
      [number, created_at, id].map(&:to_i) <=> [other.number, other.created_at, other.id].map(&:to_i)
    end

    # Returns whether the version has a version number of 1. Useful when deciding whether to ignore
    # the version during reversion, as initial versions have no serialized changes attached. Helps
    # maintain backwards compatibility.
    def initial?
      number == 1
    end
    
    # Returns the original version number that this version was.
    def original_number
      if reverted_from.nil?
        number
      else
        version = versioned.versions.at(reverted_from)
        version.nil? ? 1 : version.original_number
      end
    end

    def restore!
      model = restore
      
      if model
        model.save!
        destroy
      end
      
      model
    end
    
    def restore
      if tag == 'deleted'
        attrs = modifications

        class_name = attrs['type'].blank? ? versioned_type : attrs['type']
        klass = class_name.constantize
        model = klass.new

        attrs.each do |k, v|
          begin
            model.send "#{k}=", v
          rescue NoMethodError
            logger.warn "Attribute #{k} does not exist on #{class_name} (Version id: #{id})." rescue nil
          end
        end

        model
      else
        latest_version = self.class.find(:first, :conditions => {:versioned_id => versioned_id, :versioned_type => versioned_type, :tag => 'deleted'})
        latest_version.nil? ? nil : latest_version.restore
      end
    end
  end
end
