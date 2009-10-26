class CreateVestalVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.text :changes
      t.integer :number
      t.string :tag

      t.timestamps
    end

    change_table :versions do |t|
      t.index [:versioned_id, :versioned_type]
      t.index :number
      t.index :tag
      t.index :created_at
    end
  end

  def self.down
    drop_table :versions
  end
end
