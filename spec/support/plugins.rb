module MyCustomPlugin
  extend ActiveSupport::Concern

  included do
    class_attribute :plugged_in_model
    VestalVersions::Version.class_eval{ include MyCustomPluginMethods}
  end
end

module MyCustomPluginMethods
  extend ActiveSupport::Concern

  included do
    class_attribute :plugged_in_version
  end
end
