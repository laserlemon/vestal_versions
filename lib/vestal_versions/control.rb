module VestalVersions
  # The control feature allows use of several code blocks that provide finer control over whether
  # a new version is created, or a previous version is updated.
  module Control
    extend ActiveSupport::Concern

    included do
      class_attribute :_skip_version, :instance_writer => false
    end


    # Control blocks are called on ActiveRecord::Base instances as to not cause any conflict with
    # other instances of the versioned class whose behavior could be inadvertently altered within
    # a control block.

		# The +skip_version+ block simply allows for updates to be made to an instance of a versioned
		# ActiveRecord model while ignoring all new version creation. The <tt>:if</tt> and
		# <tt>:unless</tt> conditions (if given) will not be evaulated inside a +skip_version+ block.
		#
		# When the block closes, the instance is automatically saved, so explicitly saving the
		# object within the block is unnecessary.
		#
		# == Example
		#
		#   user = User.find_by_first_name("Steve")
		#   user.version # => 1
		#   user.skip_version do
		#     user.first_name = "Stephen"
		#   end
		#   user.version # => 1
		def skip_version
			_with_version_flag(:_skip_version) do
				yield if block_given?
				save
			end
		end

		# Behaving almost identically to the +skip_version+ block, the only difference with the
		# +skip_version!+ block is that the save automatically performed at the close of the block
		# is a +save!+, meaning that an exception will be raised if the object cannot be saved.
		def skip_version!
			_with_version_flag(:_skip_version) do
				yield if block_given?
				save!
			end
		end

		# Merging versions with the +merge_version+ block will take all of the versions that would
		# be created within the block and merge them into one version and pushing that single version
		# onto the ActiveRecord::Base instance's version history. A new version will be created and
		# the instance's version number will be incremented.
		#
		# == Example
		#
		#   user = User.find_by_first_name("Steve")
		#   user.version # => 1
		#   user.merge_version do
		#     user.update_attributes(:first_name => "Steven", :last_name => "Tyler")
		#     user.update_attribute(:first_name, "Stephen")
		#     user.update_attribute(:last_name, "Richert")
		#   end
		#   user.version # => 2
		#   user.versions.last.changes
		#   # => {"first_name" => ["Steve", "Stephen"], "last_name" => ["Jobs", "Richert"]}
		#
		# See VestalVersions::Changes for an explanation on how changes are appended.
		def merge_version
			_with_version_flag(:merge_version) do
				yield if block_given?
			end
			save
		end

		# Behaving almost identically to the +merge_version+ block, the only difference with the
		# +merge_version!+ block is that the save automatically performed at the close of the block
		# is a +save!+, meaning that an exception will be raised if the object cannot be saved.
		def merge_version!
			_with_version_flag(:merge_version) do
				yield if block_given?
			end
			save!
		end

		# A convenience method for determining whether a versioned instance is set to merge its next
		# versions into one before version creation.
		def merge_version?
			!!@merge_version
		end

		# Appending versions with the +append_version+ block acts similarly to the +merge_version+
		# block in that all would-be version creations within the block are defered until the block
		# closes. The major difference is that with +append_version+, a new version is not created.
		# Rather, the cumulative changes are appended to the serialized changes of the instance's
		# last version. A new version is not created, so the version number is not incremented.
		#
		# == Example
		#
		#   user = User.find_by_first_name("Steve")
		#   user.version # => 2
		#   user.versions.last.changes
		#   # => {"first_name" => ["Stephen", "Steve"]}
		#   user.append_version do
		#     user.last_name = "Jobs"
		#   end
		#   user.versions.last.changes
		#   # => {"first_name" => ["Stephen", "Steve"], "last_name" => ["Richert", "Jobs"]}
		#   user.version # => 2
		#
		# See VestalVersions::Changes for an explanation on how changes are appended.
		def append_version
			_with_version_flag(:merge_version) do
				yield if block_given?
			end

			_with_version_flag(:append_version) do
				save
			end
		end

		# Behaving almost identically to the +append_version+ block, the only difference with the
		# +append_version!+ block is that the save automatically performed at the close of the block
		# is a +save!+, meaning that an exception will be raised if the object cannot be saved.
		def append_version!
			_with_version_flag(:merge_version) do
				yield if block_given?
			end

			_with_version_flag(:append_version) do
				save!
			end
		end

		# A convenience method for determining whether a versioned instance is set to append its next
		# version's changes into the last version changes.
		def append_version?
			!!@append_version
		end

		# Used for each control block, the +_with_version_flag+ method sets a given variable to
		# true and then executes the given block, ensuring that the variable is returned to a nil
		# value before returning. This is useful to be certain that one of the control flag
		# instance variables isn't inadvertently left in the "on" position by execution within the
		# block raising an exception.
		def _with_version_flag(flag)
			instance_variable_set("@#{flag}", true)
			yield
		ensure
			remove_instance_variable("@#{flag}")
		end

		# Overrides the basal +create_version?+ method to make sure that new versions are not
		# created when inside any of the control blocks (until the block terminates).
		def create_version?
			!_skip_version? && !merge_version? && !append_version? && super
		end

		# Overrides the basal +update_version?+ method to allow the last version of an versioned
		# ActiveRecord::Base instance to be updated at the end of an +append_version+ block.
		def update_version?
			append_version?
		end

    module ClassMethods
      # The +skip_version+ block simply allows for updates to be made to an instance of a versioned
      # ActiveRecord model while ignoring all new version creation. The <tt>:if</tt> and
      # <tt>:unless</tt> conditions (if given) will not be evaulated inside a +skip_version+ block.
      #
      # When the block closes, the instance is automatically saved, so explicitly saving the
      # object within the block is unnecessary.
      #
      # == Example
      #
      #   user = User.find_by_first_name("Steve")
      #   user.version # => 1
      #   user.skip_version do
      #     user.first_name = "Stephen"
      #   end
      #   user.version # => 1
      def skip_version
        _with_version_flag(:_skip_version) do
          yield if block_given?
        end
      end

      # Used for each control block, the +with_version_flag+ method sets a given variable to
      # true and then executes the given block, ensuring that the variable is returned to a nil
      # value before returning. This is useful to be certain that one of the control flag
      # instance variables isn't inadvertently left in the "on" position by execution within the
      # block raising an exception.
      def _with_version_flag(flag)
        self.send("#{flag}=", true)
        yield
      ensure
        self.send("#{flag}=", nil)
      end

    end
  end
end
