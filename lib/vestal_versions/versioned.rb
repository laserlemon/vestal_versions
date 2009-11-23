module VestalVersions
  # Simply adds a flag to determine whether a model class if versioned.
  module Versioned
    def self.extended(base) # :nodoc:
      base.class_eval do
        class << self
          alias_method_chain :versioned, :flag
        end
      end
    end

    # Overrides the +versioned+ method to first define the +versioned?+ class method before
    # deferring to the original +versioned+.
    def versioned_with_flag(*args)
      versioned_without_flag(*args)

      class << self
        def versioned?
          true
        end
      end
    end

    # For all ActiveRecord::Base models that do not call the +versioned+ method, the +versioned?+
    # method will return false.
    def versioned?
      false
    end
  end
end
