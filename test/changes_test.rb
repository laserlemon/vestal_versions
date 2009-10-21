require 'test_helper'

class ChangesTest < Test::Unit::TestCase
  context "A version's changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
    end

    should 'contain only the changed attributes' do
      @user.name = 'Steve Jobs'
      changes = @user.changes
      @user.save
      assert_equal changes, @user.versions.last.changes
    end
  end
end
