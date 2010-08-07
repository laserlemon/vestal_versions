require File.join(File.dirname(__FILE__), 'test_helper')

class VersionableTaggingTest < Test::Unit::TestCase
  context 'VersionableTagging a version' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @user.update_attribute(:last_name, 'Jobs')
    end

    should "update the version record's versionable_tag column" do
      versionable_tag_name = 'TAG'
      last_version = @user.versions.last
      assert_not_equal versionable_tag_name, last_version.versionable_tag
      @user.versionable_tag_version(versionable_tag_name)
      assert_equal versionable_tag_name, last_version.reload.versionable_tag
    end

    should 'create a version record for an initial version' do
      @user.revert_to(1)
      assert_nil @user.versions.at(1)
      @user.versionable_tag_version('TAG')
      assert_not_nil @user.versions.at(1)
    end
  end

  context 'A versionable_tagged version' do
    setup do
      user = User.create(:name => 'Steve Richert')
      user.update_attribute(:last_name, 'Jobs')
      user.versionable_tag_version('TAG')
      @version = user.versions.last
    end

    should 'return true for the "versionable_tagged?" method' do
      assert @version.respond_to?(:versionable_tagged?)
      assert_equal true, @version.versionable_tagged?
    end
  end
end
