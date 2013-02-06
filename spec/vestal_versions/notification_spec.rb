require 'spec_helper'

describe VestalVersions::Notification do
  let(:admin) { Admin.create }
  let(:section) { Section.create(:admins => [admin]) }
  let(:post) { Post.create(:section_id => section.id) }

  subject { post }

  context "Creation" do
    it "should notify section and admins with status created" do
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "created"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end

  context "Update" do
    it "should notify section and admins with status updated" do
      subject.update_attributes :title => "Title"
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "updated"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end

  context "Deletion" do
    before { post.destroy }

    it "should notify section and admins with status updated" do
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "deleted"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end
end
