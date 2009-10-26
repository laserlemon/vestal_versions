module VestalVersions
  module Configuration
    class << self
      def options
        @options ||= {}
      end

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
