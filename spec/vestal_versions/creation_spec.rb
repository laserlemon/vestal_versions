require 'spec_helper'

describe VestalVersions::Creation do
  let(:name){ 'Steve Richert' }
  subject{ User.create(:name => name) }

  context 'the number of versions' do

    its('versions.count'){ should == 0 }

    context 'with :initial_version option' do
      before do
        User.prepare_versioned_options(:initial_version => true)
      end

      its('versions.count'){ should == 1 }
    end

    it 'does not increase when no changes are made in an update' do
      expect {
        subject.update_attribute(:name, name)
      }.to change{ subject.versions.count }.by(0)
    end

    it 'does not increase when no changes are made before a save' do
      expect{ subject.save }.to change{ subject.versions.count }.by(0)
    end

    it 'increases by one after an update' do
      expect{
        subject.update_attribute(:last_name, 'Jobs')
      }.to change{ subject.versions.count }.by(1)
    end

    it 'increases multiple times after multiple updates' do
      expect{
        subject.update_attribute(:last_name, 'Jobs')
        subject.update_attribute(:first_name, 'Brian')
      }.to change{ subject.versions.count }.by(2)
    end

  end

  context "a created version's changes" do
    before do
      subject.update_attribute(:last_name, 'Jobs')
    end

    it 'does not contain Rails timestamps' do
      %w(created_at created_on updated_at updated_on).each do |timestamp|
        subject.versions.last.changes.keys.should_not include(timestamp)
      end
    end

    it 'allows the columns tracked to be restricted via :only' do
      User.prepare_versioned_options(:only => [:first_name])
      subject.update_attribute(:name, 'Steven Tyler')

      subject.versions.last.changes.keys.should == ['first_name']
    end

    it 'allows specific columns to be excluded via :except' do
      User.prepare_versioned_options(:except => [:first_name])
      subject.update_attribute(:name, 'Steven Tyler')

      subject.versions.last.changes.keys.should_not include('first_name')
    end

    it "prefers :only to :except" do
      User.prepare_versioned_options(:only => [:first_name],
        :except => [:first_name])
      subject.update_attribute(:name, 'Steven Tyler')

      subject.versions.last.changes.keys.should == ['first_name']
    end
  end

  context 'first version' do
    it 'is number 2 after an update' do
      subject.update_attribute(:last_name, 'Jobs')
      subject.versions.first.number.should == 2
    end

    it "is number 1 if :initial_version is true" do
      User.prepare_versioned_options(:initial_version => true)
      subject.versions.first.number.should == 1
    end
  end

end
