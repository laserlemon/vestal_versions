require 'test_helper'

class ComparableTest < Test::Unit::TestCase
  context 'A comparable version' do
    setup do
      @version_1 = Version.new(:number => 1)
      @version_2 = Version.new(:number => 2)
    end

    should 'equal itself' do
      assert @version_1 == @version_1
      assert @version_2 == @version_2
    end

    context 'with version number 1' do
      should 'not equal a version with version number 2' do
        assert @version_1 != @version_2
      end

      should 'be less than a version with version number 2' do
        assert @version_1 < @version_2
      end
    end

    context 'with version number 2' do
      should 'not equal a version with version number 1' do
        assert @version_2 != @version_1
      end

      should 'be greater than a version with version number 1' do
        assert @version_2 > @version_1
      end
    end
  end
end
