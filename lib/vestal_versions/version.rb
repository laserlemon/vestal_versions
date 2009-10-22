module VestalVersions
  class Version < ActiveRecord::Base
    include Comparable

    belongs_to :versioned, :polymorphic => true

    undef_method :changes
    serialize :changes, Hash

    def <=>(other)
      number <=> other.number
    end

    def initial?
      number == 1
    end
  end
end
