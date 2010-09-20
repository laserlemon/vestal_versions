require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class VersionTest < Test::Unit::TestCase
  context 'Versions' do
    setup do
      @user = User.create(:name => 'Stephen Richert')
      @user.update_attribute(:name, 'Steve Jobs')
      @user.update_attribute(:last_name, 'Richert')
      @first_version, @last_version = @user.versions.first, @user.versions.last
    end

    should 'be comparable to another version based on version number' do
      assert @first_version == @first_version
      assert @last_version == @last_version
      assert @first_version != @last_version
      assert @last_version != @first_version
      assert @first_version < @last_version
      assert @last_version > @first_version
      assert @first_version <= @last_version
      assert @last_version >= @first_version
    end

    should "not equal a separate model's version with the same number" do
      user = User.create(:name => 'Stephen Richert')
      user.update_attribute(:name, 'Steve Jobs')
      user.update_attribute(:last_name, 'Richert')
      first_version, last_version = user.versions.first, user.versions.last
      assert_not_equal @first_version, first_version
      assert_not_equal @last_version, last_version
    end

    should 'default to ordering by number when finding through association' do
      numbers = @user.versions.map(&:number)
      assert_equal numbers.sort, numbers
    end

    should 'return true for the "initial?" method when the version number is 1' do
      version = @user.versions.build(:number => 1)
      assert_equal 1, version.number
      assert_equal true, version.initial?
    end
    
    should "return the version number if it is not a revert" do
      assert_equal @user.version, @user.versions.last.original_number
    end

    should "return the reverted_version if it is a revert" do
      @user.revert_to!(1)
      assert_equal 1, @user.versions.last.original_number
    end

    should "return the original version if it is a double revert" do
      @user.revert_to!(2)
      version = @user.version
      @user.update_attributes(:last_name => 'Gates')
      @user.revert_to!(version)
      assert_equal 2, @user.versions.last.original_number
    end
    
  end
end
