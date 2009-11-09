module VestalVersions
  module Versioned
    def self.extended(base)
      base.class_eval do
        class << self
          alias_method_chain :versioned, :flag
        end
      end
    end

    def versioned_with_flag(*args)
      class << self
        def versioned?
          true
        end
      end

      versioned_without_flag(*args)
    end

    def versioned?
      false
    end
  end
end
