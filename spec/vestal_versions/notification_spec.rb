require 'spec_helper'

describe VestalVersions::Notification do
  let(:admin) { Admin.create }
  let(:section) { Section.create(:admins => [admin]) }
  let(:post) { Post.create(:title => "Titre", :section_id => section.id) }

  subject { post }

  context "Creation" do
    it "should notify section and admins with status created" do
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "created"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end

  context "Update" do
    before { subject.update_attributes :title => "Title" }

    it "should notify section and admins with status updated" do
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "updated"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end

  context "Deletion" do
    before { subject.destroy }

    it "should notify section and admins with status updated" do
      subject.section.versions.order("number DESC").first.modifications.should eql "post" => [post.id, "deleted"]
      subject.section.admins.first.versions.order("number DESC").first.modifications.should eql "section" => [section.id, "updated"]
    end
  end

  context "No changes" do
    before { subject.update_attributes :title => "Titre" }

    it "should not notify section and admins" do
      subject.section.versions.order("number DESC").first.try(:modifications).should_not eql "post" => [post.id, nil]
      subject.section.admins.first.versions.order("number DESC").first.try(:modifications).should_not eql "section" => [section.id, nil]
    end
  end
end
