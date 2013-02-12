module VestalVersions
  # Adds the functionality necessary to control version notification on a versioned instance of
  # ActiveRecord::Base.
  module Notification
    extend ActiveSupport::Concern

    included do
      after_save     :notify_dependencies,  :if => :notify_dependencies?
      after_destroy  :notify_dependencies,  :if => :notify_dependencies?
    end

    # Class methods added to ActiveRecord::Base to facilitate the creation of new versions.
    module ClassMethods
      # Overrides the basal +prepare_versioned_options+ method defined in VestalVersions::Options
      # to extract the <tt>:dependencies</tt> options
      # into +vestal_versions_options+.
      def prepare_versioned_options(options)
        result = super(options)

        dependencies_options = options.delete(:dependencies)

        self.vestal_versions_options[:notify_dependencies] = Array(dependencies_options[:notify]).map(&:to_s).uniq if dependencies_options && dependencies_options[:notify]
        self.vestal_versions_options[:touch_dependencies]  = dependencies_options[:touch] if dependencies_options

        result
      end
    end

    private

    # Stores the current status for the notification
    def status
      @status
    end

    # Updates the current status for the notification
    def update_status(status)
      @status = status
    end

    def reset_status
      @status = nil
    end

    def touch_dependencies?
      vestal_versions_options[:touch_dependencies]
    end

    # Returns whether a notification should be sent to the dependencies upon event on the parent record.
    def notify_dependencies?
      (status.present? || version_changes.any?) && vestal_versions_options[:notify_dependencies] && vestal_versions_options[:notify_dependencies].any?
    end

    # Notifies all dependencies
    def notify_dependencies
      vestal_versions_options[:notify_dependencies].each do |dependency|
        notify_dependency(self.send(dependency)) if self.send(dependency)
      end
      reset_status
    end

    # Sends notification for a specific dependency whether it's an ActiveRecord::Base or an array (RecordRecord::Relation)
    def notify_dependency(dependency)
      if dependency.is_a?(ActiveRecord::Base)
        dependency.notify({self.class.name.underscore => [ self.id, status ]})
        dependency.touch if touch_dependencies?
      else
        dependency.each do |sub_dependency|
          sub_dependency.notify({self.class.name.underscore => [ self.id, status ]})
          sub_dependency.touch if touch_dependencies?
        end
      end
    end
  end
end
