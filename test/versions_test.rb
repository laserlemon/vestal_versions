require File.join(File.dirname(__FILE__), 'test_helper')

class VersionsTest < Test::Unit::TestCase
  context 'A collection of associated versions' do
    setup do
      @user, @times = User.new, {}
      names = ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
      time = names.size.hours.ago
      names.each do |name|
        @user.update_attribute(:name, name)
        time += 1.hour
        @user.versions.last.try(:update_attribute, :created_at, time)
        @times[@user.version] = time
        @user.tag_version(@user.version.to_s)
      end
    end

    should 'be searchable between two valid version values' do
      @times.keys.each do |number|
        @times.values.each do |time|
          assert_kind_of Array, @user.versions.between(number, number)
          assert_kind_of Array, @user.versions.between(number, time)
          assert_kind_of Array, @user.versions.between(time, number)
          assert_kind_of Array, @user.versions.between(time, time)
          assert !@user.versions.between(number, number).empty?
          assert !@user.versions.between(number, time).empty?
          assert !@user.versions.between(time, number).empty?
          assert !@user.versions.between(time, time).empty?
        end
      end
    end

    should 'return an empty array when searching between a valid and an invalid version value' do
      @times.each do |number, time|
        assert_equal [], @user.versions.between(number, nil)
        assert_equal [], @user.versions.between(time, nil)
        assert_equal [], @user.versions.between(nil, number)
        assert_equal [], @user.versions.between(nil, time)
      end
    end

    should 'return an empty array when searching between two invalid version values' do
      assert_equal [], @user.versions.between(nil, nil)
    end

    should 'be searchable before a valid version value' do
      @times.sort.each_with_index do |(number, time), i|
        assert_equal i, @user.versions.before(number).size
        assert_equal i, @user.versions.before(time).size
      end
    end

    should 'return an empty array when searching before an invalid version value' do
      assert_equal [], @user.versions.before(nil)
    end

    should 'be searchable after a valid version value' do
      @times.sort.reverse.each_with_index do |(number, time), i|
        assert_equal i, @user.versions.after(number).size
        assert_equal i, @user.versions.after(time).size
      end
    end

    should 'return an empty array when searching after an invalid version value' do
      assert_equal [], @user.versions.after(nil)
    end
  end
end
