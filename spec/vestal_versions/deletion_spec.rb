require 'spec_helper'

describe VestalVersions::Deletion do
  let(:name){ 'Steve Richert' }
  subject{ DeletedUser.create(:first_name => 'Steve', :last_name => 'Richert') }

  context "a deleted version's changes" do

    before do
      subject.update_attribute(:last_name, 'Jobs')
    end

    it "removes the original record" do
      subject.destroy

      DeletedUser.find_by_id(subject.id).should be_nil
    end

    it "creates another version record" do
      expect{ subject.destroy }.to change{ VestalVersions::Version.count }.by(1)
    end

    it "creates a version with a tag 'deleted'" do
      subject.destroy
      VestalVersions::Version.last.tag.should == 'deleted'
    end

  end

  context "deleted versions" do
    let(:last_version){ VestalVersions::Version.last }
    before do
      subject.update_attribute(:last_name, 'Jobs')
      subject.destroy
    end

    context "restoring a record with a bang" do
      it "is able to restore the user record" do
        last_version.restore!

        last_version.versioned.should == subject
      end

      it "removes the last versioned entry" do
        expect{
          last_version.restore!
        }.to change{ VestalVersions::Version.count }.by(-1)
      end

      it "works properly even if it's not on the proper version" do
        another_version = VestalVersions::Version.where(
          :versioned_id   => last_version.versioned_id,
          :versioned_type => last_version.versioned_type
        ).first

        another_version.should_not == last_version

        another_version.restore!.should == subject
      end

      it "restores even if the schema has changed" do
        new_mods = last_version.modifications.merge(:old_column => 'old')
        last_version.update_attributes(:modifications => new_mods)

        last_version.restore.should == subject
      end
    end

    context "restoring a record without a save" do
      it "does not save the DeletedUser when restoring" do
        last_version.restore.should be_new_record
      end

      it "restores the user object properly" do
        last_version.restore.should == subject
      end

      it "does not decrement the versions table" do
        expect{
          last_version.restore
        }.to change{ VestalVersions::Version.count }.by(0)
      end
    end
  end

end
