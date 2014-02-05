require 'spec_helper'

describe VestalVersions::Notification do
  let!(:admin) { Admin.create }
  let!(:section) { Section.create(:admins => [admin]) }
  let!(:post) { Post.create(:title => "Titre", :section_id => section.id) }

  subject { post }

  describe VestalVersions::Notification, "Touch" do
    context "Creation" do
      let!(:post) { Post.new(:title => "Titre", :section_id => section.id) }

      it "should touch dependencies" do
        Admin.any_instance.should_receive(:touch)
        Section.any_instance.should_receive(:touch)

        subject.save
      end
    end

    context "Update" do
      it "should touch dependencies" do
        Admin.any_instance.should_receive(:touch)
        Section.any_instance.should_receive(:touch)

        subject.update_attributes :title => "Title"
      end
    end

    context "Deletion" do
      it "should touch dependencies" do
        Admin.any_instance.should_receive(:touch)
        Section.any_instance.should_receive(:touch)

        subject.destroy
      end
    end

    context "No changes" do
      it "should not touch dependencies" do
        Admin.any_instance.should_not_receive(:touch)
        Section.any_instance.should_not_receive(:touch)

        subject.update_attributes :title => "Titre"
      end
    end
  end

  describe VestalVersions::Notification, "Modifications" do
    context "Creation" do
      it "should notify section and admins with status created" do
        section.versions.map(&:modifications).should include("post" => [post.id, "created"])
        admin.versions.map(&:modifications).should include("section" => [section.id, "updated"])
      end
    end

    context "Update" do
      before { subject.update_attributes :title => "Title" }

      it "should notify section and admins with status updated" do
        section.versions.map(&:modifications).should include("post" => [subject.id, "updated"])
        admin.versions.map(&:modifications).should include("section" => [section.id, "updated"])
      end
    end

    context "Deletion" do
      before { subject.destroy }

      it "should notify section and admins with status updated" do
        section.versions.map(&:modifications).should include("post" => [subject.id, "deleted"])
        admin.versions.map(&:modifications).should include("section" => [section.id, "updated"])
      end
    end

    context "No changes" do
      before { subject.update_attributes :title => "Titre" }

      it "should not notify section and admins" do
        section.versions.map(&:modifications).should_not include("post" => [subject.id, nil])
        admin.versions.map(&:modifications).should_not include("section" => [section.id, nil])
      end
    end
  end
end
