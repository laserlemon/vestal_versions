require 'test_helper'

class ChangesTest < Test::Unit::TestCase
  context "A version's changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
    end

    should "initially be blank" do
      assert @user.versions.first.changes.blank?
    end

    should 'contain all changed attributes' do
      @user.name = 'Steve Jobs'
      changes = @user.changes
      @user.save
      assert_equal changes, @user.versions.last.changes.slice(*changes.keys)
    end

    should 'contain no more than the changed attributes and timestamps' do
      timestamps = %w(created_at created_on updated_at updated_on)
      @user.name = 'Steve Jobs'
      changes = @user.changes
      @user.save
      assert_equal changes, @user.versions.last.changes.except(*timestamps)
    end
  end
end
