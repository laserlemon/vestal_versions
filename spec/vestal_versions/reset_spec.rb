require 'spec_helper'

describe VestalVersions::Reset do
  let(:names){
    ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
  }

  subject{ User.new }
  let(:versions){ names.map{ |name|
    subject.update_attribute :name, name
    subject.version
  } }

  before do
    @dependent = User.reflect_on_association(:versions).options[:dependent]
  end

  after do
    User.reflect_on_association(:versions).options[:dependent] = @dependent
  end

  it "properly reverts the model's attributes" do
    versions.reverse.each_with_index do |version, i|
      subject.reset_to!(version)
      subject.name.should == names.reverse[i]
    end
  end

  it 'dissociates all versions after the target' do
    versions.reverse.each do |version|
      subject.reset_to!(version)
      subject.versions(true).after(version).count.should == 0
    end
  end

  context 'with the :dependent option as :delete_all' do
    before do
      User.reflect_on_association(:versions).options[:dependent] = :delete_all
    end

    it 'deletes all versions after the target version' do
      versions.reverse.each do |version|
        later_versions = subject.versions.after(version)
        subject.reset_to!(version)

        later_versions.each do |later_version|
          expect{
            later_version.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    it 'does not destroy all versions after the target version' do
      expect {
        versions.reverse.each do |version|
          subject.reset_to! version
        end
      }.to_not change{ VestalVersions::Version.count }
    end
  end

  context 'with the :dependent option as :destroy' do
    before do
      User.reflect_on_association(:versions).options[:dependent] = :destroy
    end

    it 'deletes all versions after the target version' do
      versions.reverse.each do |version|
        later_versions = subject.versions.after(version)
        subject.reset_to!(version)

        later_versions.each do |later_version|
          expect{
            later_version.reload
          }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    it 'destroys all versions after the target version' do
      expect {
        versions.reverse.each do |version|
          later_versions = subject.versions.after(version)

          subject.reset_to!(version)
        end
      }.to change{ VestalVersions::Version.count }.by(-versions.size + 1)
    end
  end

  context 'with the :dependent option as :nullify' do
    before do
      User.reflect_on_association(:versions).options[:dependent] = :nullify
    end

    it 'leaves all versions after the target version' do
      versions.reverse.each do |version|
        later_versions = subject.versions.after(version)
        subject.reset_to!(version)

        later_versions.each do |later_version|
          expect{
            later_version.reload
          }.to_not raise_error
        end
      end
    end
  end

end
