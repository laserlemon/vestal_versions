ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => File.expand_path('../../test.db', __FILE__)
)

class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end

    create_table :versions, :force => true do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.belongs_to :user, :polymorphic => true
      t.string :user_name
      t.text :modifications
      t.integer :number
      t.integer :reverted_from
      t.string :tag
      t.timestamps
    end

    create_table :sections, :force => true do |t|
      t.timestamps
    end

    create_table :posts, :force => true do |t|
      t.string  :title
      t.integer :section_id
      t.timestamps
    end

    create_table :admins_sections, :force => true do |t|
      t.integer :admin_id
      t.integer :section_id
    end
  end
end
