require 'spec_helper'

describe VestalVersions::Control do
  let(:user){ User.create(:name => 'Steve Richert') }
  let(:other_user){ User.create(:name => 'Michael Rossin') }
  before do
    @count = user.versions.count
  end

  shared_examples_for 'a version preserver' do |method|
    it 'creates one version with a model update' do
      user.send(method){ user.update_attribute(:last_name, 'Jobs') }

      user.versions.count.should == @count
    end

    it 'creates one version with multiple model updates' do
      user.send(method) do
        user.update_attribute(:first_name, 'Stephen')
        user.update_attribute(:last_name, 'Jobs')
        user.update_attribute(:first_name, 'Steve')
      end

      user.versions.count.should == @count
    end

  end

  shared_examples_for 'a version incrementer' do |method|
    it 'creates one version with a model update' do
      user.send(method){ user.update_attribute(:last_name, 'Jobs') }

      user.versions.count.should == @count + 1
    end

    it 'creates one version with multiple model updates' do
      user.send(method) do
        user.update_attribute(:first_name, 'Stephen')
        user.update_attribute(:last_name, 'Jobs')
        user.update_attribute(:first_name, 'Steve')
      end

      user.versions.count.should == @count + 1
    end

  end

  it_should_behave_like 'a version preserver', :skip_version
  it_should_behave_like 'a version incrementer', :merge_version

  context "when operating on the class level" do
    before do
      @count = user.versions.count
      @other_user_count = other_user.versions.count
    end
    it 'skip_version doesn\' create versions on multiple models' do
      other_user_count = other_user.versions.count

      User.skip_version do
        user.update_attribute(:first_name, 'Stephen')
        user.update_attribute(:last_name, 'Jobs')
        user.update_attribute(:first_name, 'Steve')

        other_user.update_attribute(:first_name, 'Stephen')
        other_user.update_attribute(:last_name, 'Jobs')
        other_user.update_attribute(:first_name, 'Steve')
      end
      user.versions.count.should == @count
      other_user.versions.count.should == @other_user_count
    end

  end

  context 'within a append_version block' do

    context 'when no versions exist' do
      it_should_behave_like 'a version incrementer', :append_version
    end

    context 'when versions exist' do
      let(:last_version){ user.versions.last }

      before do
        user.update_attribute(:last_name, 'Jobs')
        user.update_attribute(:last_name, 'Richert')

        @count = user.versions.count
      end

      it_should_behave_like 'a version preserver', :append_version

      it "updates the last version with one update" do
        original_id = last_version.id
        original_attrs = last_version.attributes

        user.append_version{ user.update_attribute(:last_name, 'Jobs') }

        other_last_version = user.versions(true).last
        other_last_version.id.should == original_id
        other_last_version.attributes.should_not == original_attrs
      end

      it "updates the last version with multiple updates" do
        original_id = last_version.id
        original_attrs = last_version.attributes

        user.append_version do
          user.update_attribute(:first_name, 'Stephen')
          user.update_attribute(:last_name, 'Jobs')
          user.update_attribute(:first_name, 'Steve')
        end

        other_last_version = user.versions(true).last
        other_last_version.id.should == original_id
        other_last_version.attributes.should_not == original_attrs
      end

    end
  end
end
