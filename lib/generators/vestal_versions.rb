require 'rails/generators/named_base'

module VestalVersions
  module Generators
    module Base
      def source_root
        @_vestal_versions_source_root ||= File.expand_path(File.join('../vestal_versions', generator_name, 'templates'), __FILE__)
      end
    end
  end
end
