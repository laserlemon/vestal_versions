require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class VersionedTest < Test::Unit::TestCase
  context 'ActiveRecord models' do
    should 'respond to the "versioned?" method' do
      assert ActiveRecord::Base.respond_to?(:versioned?)
      assert User.respond_to?(:versioned?)
    end

    should 'return true for the "versioned?" method if the model is versioned' do
      assert_equal true, User.versioned?
    end

    should 'return false for the "versioned?" method if the model is not versioned' do
      assert_equal false, ActiveRecord::Base.versioned?
    end
  end
end
