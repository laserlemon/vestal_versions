require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class DeletionTest < Test::Unit::TestCase
  # context 'The number of versions' do
  #   setup do
  #     @name = 'Steve Richert'
  #     @user = User.create(:name => @name)
  #     @count = @user.versions.count
  #   end
  # 
  #   should 'initially equal zero' do
  #     assert_equal 0, @count
  #   end
  # 
  #   should 'not increase when no changes are made in an update' do
  #     @user.update_attribute(:name, @name)
  #     assert_equal @count, @user.versions.count
  #   end
  # 
  #   should 'not increase when no changes are made before a save' do
  #     @user.save
  #     assert_equal @count, @user.versions.count
  #   end
  # 
  #   context 'after an update' do
  #     setup do
  #       @user.update_attribute(:last_name, 'Jobs')
  #     end
  # 
  #     should 'increase by one' do
  #       assert_equal @count + 1, @user.versions.count
  #     end
  #   end
  # 
  #   context 'after multiple updates' do
  #     setup do
  #       @user.update_attribute(:last_name, 'Jobs')
  #       @user.update_attribute(:last_name, 'Richert')
  #     end
  # 
  #     should 'increase multiple times' do
  #       assert_operator @count + 1, :<, @user.versions.count
  #     end
  #   end
  # end

  context "A deleted version's changes" do
    setup do
      @user = DeletedUser.create(:first_name => 'Steve', :last_name => 'Richert')
      @user.update_attribute(:last_name, 'Jobs')
      @original_version_count = VestalVersions::Version.count
      @user.destroy
      @user_id = @user.id
    end
    
    should "remove the original record" do
      assert_equal nil, DeletedUser.find_by_id(@user_id)
    end

    should "create another version record" do
      assert_equal @original_version_count + 1, VestalVersions::Version.count
    end
    
    should "create a version with a tag 'deleted'" do
      assert_equal 'deleted', VestalVersions::Version.last.tag
    end

  end
  
  context "restoring a deleted version" do
    setup do
      @user = DeletedUser.create(:first_name => 'Steve', :last_name => 'Richert')
      @user.update_attribute(:last_name, 'Jobs')
      @user.destroy
      @last_version = VestalVersions::Version.last
    end
    should "be able to restore the user record" do
      @last_version.restore!
      assert_equal @user, @last_version.versioned
    end
    should "remove the last versioned entry" do
      old_version_count = VestalVersions::Version.count
      @last_version.restore!
      assert_equal old_version_count - 1, VestalVersions::Version.count
    end
    should "work properly even if it's not on the proper version" do
      another_version = VestalVersions::Version.find(:first, :conditions => {:versioned_id => @last_version.versioned_id, :versioned_type => @last_version.versioned_type})
      assert_not_equal another_version, @last_version

      restored_user = another_version.restore!

      assert_equal @user, restored_user
    end
  end
  context "restoring a deleted version without save" do
    setup do
      @user = DeletedUser.create(:first_name => 'Steve', :last_name => 'Richert')
      @user.update_attribute(:last_name, 'Jobs')
      @user.destroy
      @last_version = VestalVersions::Version.last
    end
    should "not save the DeletedUser when restoring" do
      user = @last_version.restore
      assert_equal user.new_record?, true
    end
    should "restore the user object properly" do
      user = @last_version.restore
      assert_equal user, @user
    end
    should "not decrement the versions table" do
      old_version_count = VestalVersions::Version.count
      @last_version.restore
      assert_equal old_version_count, VestalVersions::Version.count
    end
  end
end
