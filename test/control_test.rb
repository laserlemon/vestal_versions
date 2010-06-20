require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ControlTest < Test::Unit::TestCase
  context 'Within a skip_version block,' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @count = @user.versions.count
    end

    context 'a model update' do
      setup do
        @user.skip_version do
          @user.update_attribute(:last_name, 'Jobs')
        end
      end

      should 'not create a version' do
        assert_equal @count, @user.versions.count
      end
    end

    context 'multiple model updates' do
      setup do
        @user.skip_version do
          @user.update_attribute(:first_name, 'Stephen')
          @user.update_attribute(:last_name, 'Jobs')
          @user.update_attribute(:first_name, 'Steve')
        end
      end

      should 'not create a version' do
        assert_equal @count, @user.versions.count
      end
    end
  end

  context 'Within a merge_version block,' do
    setup do
      @user = User.create(:name => 'Steve Richert')
      @count = @user.versions.count
    end

    context 'a model update' do
      setup do
        @user.merge_version do
          @user.update_attribute(:last_name, 'Jobs')
        end
      end

      should 'create a version' do
        assert_equal @count + 1, @user.versions.count
      end
    end

    context 'multiple model updates' do
      setup do
        @user.merge_version do
          @user.update_attribute(:first_name, 'Stephen')
          @user.update_attribute(:last_name, 'Jobs')
          @user.update_attribute(:first_name, 'Steve')
        end
      end

      should 'create a version' do
        assert_equal @count + 1, @user.versions.count
      end
    end
  end

  context 'Within a append_version block' do
    context '(when no versions exist),' do
      setup do
        @user = User.create(:name => 'Steve Richert')
        @count = @user.versions.count
      end

      context 'a model update' do
        setup do
          @user.append_version do
            @user.update_attribute(:last_name, 'Jobs')
          end
        end

        should 'create a version' do
          assert_equal @count + 1, @user.versions.count
        end
      end

      context 'multiple model updates' do
        setup do
          @user.append_version do
            @user.update_attribute(:first_name, 'Stephen')
            @user.update_attribute(:last_name, 'Jobs')
            @user.update_attribute(:first_name, 'Steve')
          end
        end

        should 'create a version' do
          assert_equal @count + 1, @user.versions.count
        end
      end
    end

    context '(when versions exist),' do
      setup do
        @user = User.create(:name => 'Steve Richert')
        @user.update_attribute(:last_name, 'Jobs')
        @user.update_attribute(:last_name, 'Richert')
        @last_version = @user.versions.last
        @count = @user.versions.count
      end

      context 'a model update' do
        setup do
          @user.append_version do
            @user.update_attribute(:last_name, 'Jobs')
          end
        end

        should 'not create a version' do
          assert_equal @count, @user.versions.count
        end

        should 'update the last version' do
          last_version = @user.versions(true).last
          assert_equal @last_version.id, last_version.id
          assert_not_equal @last_version.attributes, last_version.attributes
        end
      end

      context 'multiple model updates' do
        setup do
          @user.append_version do
            @user.update_attribute(:first_name, 'Stephen')
            @user.update_attribute(:last_name, 'Jobs')
            @user.update_attribute(:first_name, 'Steve')
          end
        end

        should 'not create a version' do
          assert_equal @count, @user.versions.count
        end

        should 'update the last version' do
          last_version = @user.versions(true).last
          assert_equal @last_version.id, last_version.id
          assert_not_equal @last_version.attributes, last_version.attributes
        end
      end
    end
  end
end
