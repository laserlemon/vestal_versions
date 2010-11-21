require 'spec_helper'

describe VestalVersions::Reload do
  let(:user){ User.create(:name => 'Steve Richert') }

  before do
    first_version = user.version
    user.update_attribute(:last_name, 'Jobs')
    @last_version = user.version
    user.revert_to(first_version)
  end

  it 'resets the version number to the most recent version' do
    user.version.should_not == @last_version
    user.reload
    user.version.should == @last_version
  end
end
