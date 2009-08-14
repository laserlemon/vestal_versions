ActiveRecord::Base.establish_connection(
  :adapter => defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby' ? 'jdbcsqlite3' : 'sqlite3',
  :database => File.join(File.dirname(__FILE__), 'test.db')
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
      t.text :changes
      t.integer :number
      t.datetime :created_at
    end
  end
end

CreateSchema.suppress_messages do
  CreateSchema.migrate(:up)
end

class User < ActiveRecord::Base
  versioned

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name=(names)
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
end
