require 'test_helper'

class LastChangesTest < Test::Unit::TestCase
  context "A created model's last changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
    end

    should 'be blank' do
      assert @user.last_changes.blank?
      assert @user.last_changed.blank?
    end
  end

  context "An updated model's last changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @previous_attributes = @user.attributes
      @user.update_attribute(:name, 'Steve Jobs')
      @current_attributes = @user.attributes
    end

    should 'have keys matching its last changed attributes' do
      assert_equal @user.last_changes.keys, @user.last_changed
    end

    should 'values of two-element arrays with unique values' do
      @user.last_changes.values.each do |value|
        assert_kind_of Array, value
        assert_equal 2, value.size
        assert_equal value, value.uniq
      end
    end

    should 'begin with the previous attribute values' do
      changes = @user.last_changes.inject({}){|h,(k,v)| h.update(k => v.first) }
      previous = @previous_attributes.slice(*@user.last_changed)
      assert_equal previous, changes
    end

    should 'end with the current attribute values' do
      changes = @user.last_changes.inject({}){|h,(k,v)| h.update(k => v.last) }
      current = @current_attributes.slice(*@user.last_changed)
      assert_equal current, changes
    end
  end
end
