module VestalVersions
  # Adds the ability to "reset" (or hard revert) a versioned ActiveRecord::Base instance.
  module Reset
    def self.included(base) # :nodoc:
      Version.send(:include, VersionMethods)

      base.class_eval do
        include InstanceMethods
      end
    end

    # Adds the instance methods required to reset an object to a previous version.
    module InstanceMethods
      # Similar to +revert_to!+, the +reset_to!+ method reverts an object to a previous version,
      # only instead of creating a new record in the version history, +reset_to!+ deletes all of
      # the version history that occurs after the version reverted to.
      #
      # The action taken on each version record after the point of reversion is determined by the
      # <tt>:dependent</tt> option given to the +versioned+ method. See the +versioned+ method
      # documentation for more details.
      def reset_to!(value)
        if saved = skip_version{ revert_to!(value) }
          versions.after(value).each(&version_reset_method)
          reset_version
        end
        saved
      end

      private
        # The method used to individually remove versions from the version history by way of the
        # +reset_to!+ method. There are three options for the <tt>:dependent</tt> option given
        # to the +versioned+ method: <tt>:delete_all</tt>, <tt>:destroy</tt> and <tt>:nullify</tt>.
        # If none is given, <tt>:delete_all</tt> is the default.
        #
        # If <tt>:delete_all</tt> is given, each version will be deleted from the database,
        # triggering no callbacks. If <tt>:destroy</tt> is given, each version will likewise be
        # deleted from the database, but any callbacks associated with version destruction will be
        # triggered. If <tt>:nullify</tt> is specified, the version records will simply be
        # dissociated from the versioned parent record by setting its foreign key to nil.
        def version_reset_method
          vestal_versions_options[:dependent].to_s.sub(/_all$/, '').to_sym
        end
    end

    # Instance methods added to the VestalVersions::Version model to accomodate resetting the
    # parent ActiveRecord::Base instance.
    module VersionMethods
      # The +nullify+ method is meant to mimic the behavior of ActiveRecord when the parent of a
      # +has_many+ association (with <tt>:dependent => :nullify</tt>) is destroyed and the child
      # records are dissociated from the parent's primary key.
      def nullify
        update_attribute(:versioned_id, nil)
      end
    end
  end
end
