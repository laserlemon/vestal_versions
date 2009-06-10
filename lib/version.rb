class VestalVersion < ActiveRecord::Base
  
  set_table_name 'versions'
  
  belongs_to :versioned, :polymorphic => true
  
  validates_presence_of :versioned, :changes, :number
  validates_numericality_of :number, :greater_than => 0, :only_integer => true
  validates_uniqueness_of :number, :scope => ['versioned_type', 'versioned_id']
  
  serialize :changes, Hash
  
  before_create :set_number
  
  def version
    number
  end
  
  def <=>(other)
    number <=> other.number
  end
  
  def <(other)
    number < other.number
  end
  
  def >(other)
    number > other.number
  end
  
  private
  
  def set_number
    write_attribute(:number, versioned.versions.maximum(:number).to_i + 1)
  end
end