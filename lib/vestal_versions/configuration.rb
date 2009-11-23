module VestalVersions
  # Allows for easy application-wide configuration of options passed into the +versioned+ method.
  module Configuration
    # The VestalVersions module is extended by VestalVersions::Configuration, allowing the
    # +configure method+ to be used as follows in a Rails initializer:
    #
    #   VestalVersions.configure do |config|
    #     config.class_name = "MyCustomVersion"
    #     config.dependent = :destroy
    #   end
    #
    # Each variable assignment in the +configure+ block corresponds directly with the options
    # available to the +versioned+ method. Assigning common options in an initializer can keep your
    # models tidy.
    #
    # If an option is given in both an initializer and in the options passed to +versioned+, the
    # value given in the model itself will take precedence.
    def configure
      yield Configuration
    end

    class << self
      # Simply stores a hash of options given to the +configure+ block.
      def options
        @options ||= {}
      end

      # If given a setter method name, will assign the first argument to the +options+ hash with
      # the method name (sans "=") as the key. If given a getter method name, will attempt to
      # a value from the +options+ hash for that key. If the key doesn't exist, defers to +super+.
      def method_missing(symbol, *args)
        if (method = symbol.to_s).sub!(/\=$/, '')
          options[method.to_sym] = args.first
        else
          options.fetch(method.to_sym, super)
        end
      end
    end
  end
end
