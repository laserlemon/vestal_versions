require 'test_helper'

class BetweenTest < Test::Unit::TestCase
  context 'The number of versions between' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @version = @user.version
      @valid = [@version, 0, 1_000_000, :first, :last, 1.day.since(@user.created_at), @user.versions.first]
      @invalid = [nil, :bogus, 'bogus', Date.parse('0001-12-25')]
    end

    context 'the current version and the current version' do
      should 'equal one' do
        assert_equal 1, @user.versions.between(@version, @version).size
      end
    end

    context 'the current version and a valid value' do
      should 'not equal zero' do
        @valid.each do |valid|
          assert_not_equal 0, @user.versions.between(@version, valid).size
          assert_not_equal 0, @user.versions.between(valid, @version).size
        end
      end
    end

    context 'the current version and an invalid value' do
      should 'equal zero' do
        @invalid.each do |invalid|
          assert_equal 0, @user.versions.between(@version, invalid).size
          assert_equal 0, @user.versions.between(invalid, @version).size
        end
      end
    end

    context 'two invalid values' do
      should 'equal zero' do
        @invalid.each do |first|
          @invalid.each do |second|
            assert_equal 0, @user.versions.between(first, second).size
            assert_equal 0, @user.versions.between(second, first).size
          end
        end
      end
    end

    context 'a valid value and an invalid value' do
      should 'equal zero' do
        @valid.each do |valid|
          @invalid.each do |invalid|
            assert_equal 0, @user.versions.between(valid, invalid).size
            assert_equal 0, @user.versions.between(invalid, valid).size
          end
        end
      end
    end
  end
end
