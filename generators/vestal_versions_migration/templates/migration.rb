class CreateVestalVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.text :changes
      t.integer :number
      t.datetime :created_at
    end

    change_table :versions do |t|
      t.index [:versioned_type, :versioned_id]
      t.index :number
      t.index :created_at
    end
  end

  def self.down
    drop_table :versions
  end
end
