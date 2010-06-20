require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ResetTest < Test::Unit::TestCase
  context 'Resetting a model' do
    setup do
      @original_dependent = User.reflect_on_association(:versions).options[:dependent]
      @user, @versions = User.new, []
      @names = ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
      @names.each do |name|
        @user.update_attribute(:name, name)
        @versions << @user.version
      end
    end

    should "properly revert the model's attributes" do
      @versions.reverse.each_with_index do |version, i|
        @user.reset_to!(version)
        assert_equal @names.reverse[i], @user.name
      end
    end

    should 'dissociate all versions after the target' do
      @versions.reverse.each do |version|
        @user.reset_to!(version)
        assert_equal 0, @user.versions(true).after(version).count
      end
    end

    context 'with the :dependent option as :delete_all' do
      setup do
        User.reflect_on_association(:versions).options[:dependent] = :delete_all
      end

      should 'delete all versions after the target version' do
        @versions.reverse.each do |version|
          later_versions = @user.versions.after(version)
          @user.reset_to!(version)
          later_versions.each do |later_version|
            assert_raise ActiveRecord::RecordNotFound do
              later_version.reload
            end
          end
        end
      end

      should 'not destroy all versions after the target version' do
        VestalVersions::Version.any_instance.stubs(:destroy).raises(RuntimeError)
        @versions.reverse.each do |version|
          assert_nothing_raised do
            @user.reset_to!(version)
          end
        end
      end
    end

    context 'with the :dependent option as :destroy' do
      setup do
        User.reflect_on_association(:versions).options[:dependent] = :destroy
      end

      should 'delete all versions after the target version' do
        @versions.reverse.each do |version|
          later_versions = @user.versions.after(version)
          @user.reset_to!(version)
          later_versions.each do |later_version|
            assert_raise ActiveRecord::RecordNotFound do
              later_version.reload
            end
          end
        end
      end

      should 'destroy all versions after the target version' do
        VestalVersions::Version.any_instance.stubs(:destroy).raises(RuntimeError)
        @versions.reverse.each do |version|
          later_versions = @user.versions.after(version)
          if later_versions.empty?
            assert_nothing_raised do
              @user.reset_to!(version)
            end
          else
            assert_raise RuntimeError do
              @user.reset_to!(version)
            end
          end
        end
      end
    end

    context 'with the :dependent option as :nullify' do
      setup do
        User.reflect_on_association(:versions).options[:dependent] = :nullify
      end

      should 'leave all versions after the target version' do
        @versions.reverse.each do |version|
          later_versions = @user.versions.after(version)
          @user.reset_to!(version)
          later_versions.each do |later_version|
            assert_nothing_raised do
              later_version.reload
            end
          end
        end
      end
    end

    teardown do
      User.reflect_on_association(:versions).options[:dependent] = @original_dependent
    end
  end
end
