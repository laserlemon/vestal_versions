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
      # to extract the <tt>:notify_dependencies</tt> options
      # into +vestal_versions_options+.
      def prepare_versioned_options(options)
        result = super(options)

        self.vestal_versions_options[:notify_dependencies] = Array(options.delete(:notify_dependencies)).map(&:to_s).uniq if options[:notify_dependencies]

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

    # Returns whether a notification should be sent to the dependencies upon event on the parent record.
    def notify_dependencies?
      vestal_versions_options[:notify_dependencies] && vestal_versions_options[:notify_dependencies].any?
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
      else
        dependency.each do |sub_dependency|
          sub_dependency.notify({self.class.name.underscore => [ self.id, status ]})
        end
      end
    end
  end
end
