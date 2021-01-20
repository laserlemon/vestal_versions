ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => File.expand_path('../../test.db', __FILE__)
)

major, minor = ActiveRecord.version.segments[0..1]
ar_migration = ActiveRecord::Migration
ar_migration = ar_migration["#{major}.#{minor}"] if major > 4

class CreateSchema < ar_migration
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
  end
end
