class Version < ActiveRecord::Base
  
  belongs_to :versioned, :polymorphic => true
  
  serialize :changes, Hash
  
  alias_attribute :version, :number
  
  def <=>(other)
    number <=> other.number
  end
  
  def <(other)
    number < other.number
  end
  
  def >(other)
    number > other.number
  end
end