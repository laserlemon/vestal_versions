module VestalVersions
  module Versioned
    def self.extended(base)
      base.class_eval do
        class << self
          alias_method_chain :versioned, :versioned?
        end
      end
    end

    def versioned_with_versioned?(*args)
      class << self
        def versioned?
          true
        end
      end

      versioned_without_versioned?(*args)
    end

    def versioned?
      false
    end
  end
end
