require File.join(File.dirname(__FILE__), 'test_helper')

class ChangesTest < Test::Unit::TestCase
  context "A version's changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @user.update_attribute(:last_name, 'Jobs')
      @changes = @user.versions.last.changes
    end

    should 'be a hash' do
      assert_kind_of Hash, @changes
    end

    should 'not be empty' do
      assert !@changes.empty?
    end

    should 'have string keys' do
      @changes.keys.each do |key|
        assert_kind_of String, key
      end
    end

    should 'have array values' do
      @changes.values.each do |value|
        assert_kind_of Array, value
      end
    end

    should 'have two-element values' do
      @changes.values.each do |value|
        assert_equal 2, value.size
      end
    end

    should 'have unique-element values' do
      @changes.values.each do |value|
        assert_equal value.uniq, value
      end
    end

    should "equal the model's changes" do
      @user.first_name = 'Stephen'
      model_changes = @user.changes
      @user.save
      changes = @user.versions.last.changes
      assert_equal model_changes, changes
    end
  end

  context 'A hash of changes' do
    setup do
      @changes = {'first_name' => ['Steve', 'Stephen']}
      @other = {'first_name' => ['Catie', 'Catherine']}
    end

    should 'properly append other changes' do
      expected = {'first_name' => ['Steve', 'Catherine']}
      changes = @changes.append_changes(@other)
      assert_equal expected, changes
      @changes.append_changes!(@other)
      assert_equal expected, @changes
    end

    should 'properly prepend other changes' do
      expected = {'first_name' => ['Catie', 'Stephen']}
      changes = @changes.prepend_changes(@other)
      assert_equal expected, changes
      @changes.prepend_changes!(@other)
      assert_equal expected, @changes
    end

    should 'be reversible' do
      expected = {'first_name' => ['Stephen', 'Steve']}
      changes = @changes.reverse_changes
      assert_equal expected, changes
      @changes.reverse_changes!
      assert_equal expected, @changes
    end
  end
end
