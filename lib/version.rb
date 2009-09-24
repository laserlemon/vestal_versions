class Version < ActiveRecord::Base
  include Comparable

  belongs_to :versioned, :polymorphic => true

  undef_method :changes
  serialize :changes, Hash

  alias_attribute :version, :number

  def <=>(other)
    number <=> other.number
  end
end
