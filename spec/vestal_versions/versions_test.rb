require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class VersionsTest < Test::Unit::TestCase
  context 'A collection of associated versions' do
    setup do
      @user, @times = User.new, {}
      names = ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
      time = names.size.hours.ago
      names.each do |name|
        @user.update_attribute(:name, name)
        @user.tag_version(@user.version.to_s)
        time += 1.hour
        @user.versions.last.update_attribute(:created_at, time)
        @times[@user.version] = time
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

    should 'be fetchable by version number' do
      @times.keys.each do |number|
        assert_kind_of VestalVersions::Version, @user.versions.at(number)
        assert_equal number, @user.versions.at(number).number
      end
    end

    should 'be fetchable by tag' do
      @times.keys.map{|n| [n, n.to_s] }.each do |number, tag|
        assert_kind_of VestalVersions::Version, @user.versions.at(tag)
        assert_equal number, @user.versions.at(tag).number
      end
    end

    should "be fetchable by the exact time of a version's creation" do
      @times.each do |number, time|
        assert_kind_of VestalVersions::Version, @user.versions.at(time)
        assert_equal number, @user.versions.at(time).number
      end
    end

    should "be fetchable by any time after the model's creation" do
      @times.each do |number, time|
        assert_kind_of VestalVersions::Version, @user.versions.at(time + 30.minutes)
        assert_equal number, @user.versions.at(time + 30.minutes).number
      end
    end

    should "return nil when fetching a time before the model's creation" do
      creation = @times.values.min
      assert_nil @user.versions.at(creation - 1.second)
    end

    should 'be fetchable by an association extension method' do
      assert_kind_of VestalVersions::Version, @user.versions.at(:first)
      assert_kind_of VestalVersions::Version, @user.versions.at(:last)
      assert_equal @times.keys.min, @user.versions.at(:first).number
      assert_equal @times.keys.max, @user.versions.at(:last).number
    end

    should 'be fetchable by a version object' do
      @times.keys.each do |number|
        version = @user.versions.at(number)
        assert_kind_of VestalVersions::Version, version
        assert_kind_of VestalVersions::Version, @user.versions.at(version)
        assert_equal number, @user.versions.at(version).number
      end
    end

    should 'return nil when fetching an invalid version value' do
      assert_nil @user.versions.at(nil)
    end

    should 'provide a version number for any given numeric version value' do
      @times.keys.each do |number|
        assert_kind_of Fixnum, @user.versions.number_at(number)
        assert_kind_of Fixnum, @user.versions.number_at(number + 0.5)
        assert_equal @user.versions.number_at(number), @user.versions.number_at(number + 0.5)
      end
    end

    should 'provide a version number for a valid tag' do
      @times.keys.map{|n| [n, n.to_s] }.each do |number, tag|
        assert_kind_of Fixnum, @user.versions.number_at(tag)
        assert_equal number, @user.versions.number_at(tag)
      end
    end

    should 'return nil when providing a version number for an invalid tag' do
      assert_nil @user.versions.number_at('INVALID')
    end

    should 'provide a version number of a version corresponding to an association extension method' do
      assert_kind_of VestalVersions::Version, @user.versions.at(:first)
      assert_kind_of VestalVersions::Version, @user.versions.at(:last)
      assert_equal @times.keys.min, @user.versions.number_at(:first)
      assert_equal @times.keys.max, @user.versions.number_at(:last)
    end

    should 'return nil when providing a version number for an invalid association extension method' do
      assert_nil @user.versions.number_at(:INVALID)
    end

    should "provide a version number for any time after the model's creation" do
      @times.each do |number, time|
        assert_kind_of Fixnum, @user.versions.number_at(time + 30.minutes)
        assert_equal number, @user.versions.number_at(time + 30.minutes)
      end
    end

    should "provide a version number of 1 for a time before the model's creation" do
      creation = @times.values.min
      assert_equal 1, @user.versions.number_at(creation - 1.second)
    end

    should 'provide a version number for a given version object' do
      @times.keys.each do |number|
        version = @user.versions.at(number)
        assert_kind_of VestalVersions::Version, version
        assert_kind_of Fixnum, @user.versions.number_at(version)
        assert_equal number, @user.versions.number_at(version)
      end
    end
  end
end
