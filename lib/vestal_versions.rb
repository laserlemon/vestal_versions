require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext/module/delegation'
require 'active_record'

# +vestal_versions+ keeps track of updates to ActiveRecord models, leveraging the introduction of
# dirty attributes in Rails 2.1. By storing only the updated attributes in a serialized column of a
# single version model, the history is kept DRY and no additional schema changes are necessary.
#
# Author:: Steve Richert
# Copyright:: Copyright (c) 2009 Steve Richert
# License:: MIT License (http://www.opensource.org/licenses/mit-license.php)
#
# To enable versioning on a model, simply use the +versioned+ method:
#
#   class User < ActiveRecord::Base
#     versioned
#   end
#
#   user = User.create(:name => "Steve Richert")
#   user.version # => 1
#   user.update_attribute(:name, "Steve Jobs")
#   user.version # => 2
#   user.revert_to(1)
#   user.name # => "Steve Richert"
#
# See the +versioned+ documentation for more details.

# The base module that gets included in ActiveRecord::Base. See the documentation for
# VestalVersions::ClassMethods for more useful information.
module VestalVersions
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :Changes
  autoload :Conditions
  autoload :Control
  autoload :Creation
  autoload :Deletion
  autoload :Options
  autoload :Reload
  autoload :Reset
  autoload :Reversion
  autoload :Users
  autoload :Version
  autoload :VERSION, 'vestal_versions/version_num'
  autoload :VersionTagging
  autoload :Versioned
  autoload :Versions

  class << self
    delegate :config, :configure, :to => Version
  end

  included do
    include Versioned
  end

  module ClassMethods
    # +versioned+ associates an ActiveRecord model with many versions. When the object is updated,
    # a new version containing the changes is created. There are several options available to the
    # +versioned+ method, most of which are passed to the +has_many+ association itself:
    # * <tt>:class_name</tt>: The class name of the version model to use for the association. By
    #   default, this is set to "VestalVersions::Version", representing the built-in version class.
    #   By specifying this option, you can override the version class, to include custom version
    #   behavior. It's recommended that a custom version inherit from VestalVersions::Version.
    # * <tt>:dependent</tt>: Also common to +has_many+ associations, this describes the behavior of
    #   version records when the parent object is destroyed. This defaults to :delete_all, which
    #   will permanently remove all associated versions *without* triggering any destroy callbacks.
    #   Other options are :destroy which removes the associated versions *with* callbacks, or
    #   :nullify which leaves the version records in the database, but dissociates them from the
    #   parent object by setting the foreign key columns to +nil+ values.  Setting this option to 
    #   :tracking will perform a soft delete on destroy and create a new version record preserving
    #   details of this record for later restoration.
    # * <tt>:except</tt>: An update will trigger version creation as long as at least one column
    #   outside those specified here was updated. Also, upon version creation, the columns
    #   specified here will be excluded from the change history. This is useful when dealing with
    #   unimportant, constantly changing, or sensitive information. This option accepts a symbol,
    #   string or an array of either, representing column names to exclude. It is completely
    #   optional and defaults to +nil+, allowing all columns to be versioned. This option is also
    #   ignored if the +only+ option is used.
    # * <tt>:extend</tt>: This option allows you to extend the +has_many+ association proxy with a
    #   module or an array of modules. Any methods defined in those modules become available on the
    #   +versions+ association. The VestalVersions::Versions module is essential to the
    #   functionality of +vestal_versions+ and so is prepended to any additional modules that you
    #   might specify here.
    # * <tt>:if</tt>: Accepts a symbol, a proc or an array of either to be evaluated when the parent
    #   object is updated to determine whether a new version should be created. +to_proc+ is called
    #   on any symbols given and the resulting procs are called, passing in the object itself. If
    #   an array is given, all must be evaluate to +true+ in order for a version to be created.
    # * <tt>:initial_version</tt>: When set to true, an initial version is always created when the
    #   parent object is created. This initial version will have nil changes however it can be
    #   used to store who created the original version.
    # * <tt>:only</tt>: An update will trigger version creation as long as at least one updated
    #   column falls within those specified here. Also, upon version creation, only the columns
    #   specified here will be included in the change history. This option accepts a symbol, string
    #   or an array of either, representing column names to include. It is completely optional and
    #   defaults to +nil+, allowing all columns to be versioned. This option takes precedence over
    #   the +except+ option if both are specified.
    # * <tt>:unless</tt>: Accepts a symbol, a proc or an array of either to be evaluated when the
    #   parent object is updated to determine whether version creation should be skipped. +to_proc+
    #   is called on any symbols given and the resulting procs are called, passing in the object
    #   itself. If an array is given and any element evaluates as +true+, the version creation will
    #   be skipped.
    def versioned(options = {}, &block)
      return if versioned?

      include Options
      include Changes
      include Creation
      include Users
      include Reversion
      include Reset
      include Conditions
      include Control
      include VersionTagging
      include Reload
      include Deletion

      prepare_versioned_options(options)
      has_many :versions, options, &block
    end
  end
end

ActiveRecord::Base.class_eval{ include VestalVersions }
