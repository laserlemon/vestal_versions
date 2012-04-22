class User < ActiveRecord::Base
  versioned

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name= names
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
end

class DeletedUser < ActiveRecord::Base
  table_name 'users'
  versioned :dependent => :tracking
end

class MyCustomVersion < VestalVersions::Version
end
