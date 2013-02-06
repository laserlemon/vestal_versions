class User < ActiveRecord::Base
  versioned

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name= names
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
end

class Admin < User
  has_and_belongs_to_many :posts
end

class Section < ActiveRecord::Base
  has_and_belongs_to_many :admins
  has_many :posts

  versioned :notify_dependencies => %w(admins), :initial_version => true, :dependent => :tracking
end

class Post < ActiveRecord::Base
  belongs_to :section

  versioned :notify_dependencies => %w(section), :initial_version => true, :dependent => :tracking
end

class DeletedUser < ActiveRecord::Base
  self.table_name = 'users'
  versioned :dependent => :tracking
end

class MyCustomVersion < VestalVersions::Version
end
