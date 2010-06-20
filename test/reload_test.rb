require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ReloadTest < Test::Unit::TestCase
  context 'Reloading a reverted model' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      first_version = @user.version
      @user.update_attribute(:last_name, 'Jobs')
      @last_version = @user.version
      @user.revert_to(first_version)
    end

    should 'reset the version number to the most recent version' do
      assert_not_equal @last_version, @user.version
      @user.reload
      assert_equal @last_version, @user.version
    end
  end
end
