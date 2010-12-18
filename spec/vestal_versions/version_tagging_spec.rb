require 'spec_helper'

describe VestalVersions::VersionTagging do
  let(:user){ User.create(:name => 'Steve Richert') }

  before do
    user.update_attribute(:last_name, 'Jobs')
  end

  context 'an untagged version' do
    it "updates the version record's tag column" do
      tag_name = 'TAG'
      last_version = user.versions.last

      last_version.tag.should_not == tag_name
      user.tag_version(tag_name)
      last_version.reload.tag.should == tag_name
    end

    it 'creates a version record for an initial version' do
      user.revert_to(1)
      user.versions.at(1).should be_nil

      user.tag_version('TAG')
      user.versions.at(1).should_not be_nil
    end
  end

  context 'A tagged version' do
    subject{ user.versions.last }

    before do
      user.tag_version('TAG')
    end

    it { should be_tagged }
  end

end
