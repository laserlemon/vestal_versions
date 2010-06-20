require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class TaggingTest < Test::Unit::TestCase
  context 'Tagging a version' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @user.update_attribute(:last_name, 'Jobs')
    end

    should "update the version record's tag column" do
      tag_name = 'TAG'
      last_version = @user.versions.last
      assert_not_equal tag_name, last_version.tag
      @user.tag_version(tag_name)
      assert_equal tag_name, last_version.reload.tag
    end

    should 'create a version record for an initial version' do
      @user.revert_to(1)
      assert_nil @user.versions.at(1)
      @user.tag_version('TAG')
      assert_not_nil @user.versions.at(1)
    end
  end

  context 'A tagged version' do
    setup do
      user = User.create(:name => 'Steve Richert')
      user.update_attribute(:last_name, 'Jobs')
      user.tag_version('TAG')
      @version = user.versions.last
    end

    should 'return true for the "tagged?" method' do
      assert @version.respond_to?(:tagged?)
      assert_equal true, @version.tagged?
    end
  end
end
