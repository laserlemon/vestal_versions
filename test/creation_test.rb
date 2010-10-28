require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class CreationTest < Test::Unit::TestCase
  context 'The number of versions' do
    setup do
      @name = 'Steve Richert'
      @user = User.create(:name => @name)
      @count = @user.versions.count
    end

    should 'initially equal zero' do
      assert_equal 0, @count
    end
    
    context '(with :initial_version option)' do
      setup do
        User.prepare_versioned_options(:initial_version => true)
        @user = User.create(:name => @name)
        @count = @user.versions.count
      end
      should 'initially equal one' do
        assert_equal 1, @count
      end
      teardown do
        User.prepare_versioned_options(:initial_version => nil)
      end
    end

    should 'not increase when no changes are made in an update' do
      @user.update_attribute(:name, @name)
      assert_equal @count, @user.versions.count
    end

    should 'not increase when no changes are made before a save' do
      @user.save
      assert_equal @count, @user.versions.count
    end

    context 'after an update' do
      setup do
        @user.update_attribute(:last_name, 'Jobs')
      end

      should 'increase by one' do
        assert_equal @count + 1, @user.versions.count
      end
    end

    context 'after multiple updates' do
      setup do
        @user.update_attribute(:last_name, 'Jobs')
        @user.update_attribute(:last_name, 'Richert')
      end

      should 'increase multiple times' do
        assert_operator @count + 1, :<, @user.versions.count
      end
    end
  end

  context "A created version's changes" do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @user.update_attribute(:last_name, 'Jobs')
    end

    should 'not contain Rails timestamps' do
      %w(created_at created_on updated_at updated_on).each do |timestamp|
        assert_does_not_contain @user.versions.last.changes.keys, timestamp
      end
    end

    context '(with :only options)' do
      setup do
        @only = %w(first_name)
        User.prepare_versioned_options(:only => @only)
        @user.update_attribute(:name, 'Steven Tyler')
      end

      should 'only contain the specified columns' do
        assert_equal @only, @user.versions.last.changes.keys
      end

      teardown do
        User.prepare_versioned_options(:only => nil)
      end
    end

    context '(with :except options)' do
      setup do
        @except = %w(first_name)
        User.prepare_versioned_options(:except => @except)
        @user.update_attribute(:name, 'Steven Tyler')
      end

      should 'not contain the specified columns' do
        @except.each do |column|
          assert_does_not_contain @user.versions.last.changes.keys, column
        end
      end

      teardown do
        User.prepare_versioned_options(:except => nil)
      end
    end

    context '(with both :only and :except options)' do
      setup do
        @only = %w(first_name)
        @except = @only
        User.prepare_versioned_options(:only => @only, :except => @except)
        @user.update_attribute(:name, 'Steven Tyler')
      end

      should 'respect only the :only options' do
        assert_equal @only, @user.versions.last.changes.keys
      end

      teardown do
        User.prepare_versioned_options(:only => nil, :except => nil)
      end
    end
  end

  context 'First version' do
    setup do
      @name = 'Steve Richert'
      @user = User.create(:name => @name)
    end
    should 'should be number 2 (after an update)' do
      @user.update_attribute(:last_name, 'Jobs')
      assert_equal 2, @user.versions.first.number
    end
    
    context "With :initial_version option" do
      setup do
        User.prepare_versioned_options(:initial_version => true)
        @user = User.create(:name => @name)
      end
      should 'should be number 1' do
        assert_equal 1, @user.versions.first.number
      end
      teardown do
        User.prepare_versioned_options(:initial_version => nil)
      end
    end
  end
end
