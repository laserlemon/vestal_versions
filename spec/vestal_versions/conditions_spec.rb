require 'spec_helper'

describe VestalVersions::Conditions do
  shared_examples_for 'a conditional option' do |option|
    before do
      User.class_eval do
        def true; true; end
      end
    end

    it 'is an array' do
      User.vestal_versions_options[option].should be_a(Array)
      User.prepare_versioned_options(option => :true)
      User.vestal_versions_options[option].should be_a(Array)
    end

    it 'has proc values' do
      User.prepare_versioned_options(option => :true)
      User.vestal_versions_options[option].each{|i| i.should be_a(Proc) }
    end
  end

  it_should_behave_like 'a conditional option', :if
  it_should_behave_like 'a conditional option', :unless

  context 'a new version' do
    subject{ User.create(:name => 'Steve Richert') }
    let(:count){ subject.versions.count }

    before do
      User.class_eval do
        def true; true; end
        def false; false; end
      end
      count # memoize this value
    end

    after do
      User.prepare_versioned_options(:if => [], :unless => [])
    end

    context 'with :if conditions' do
      context 'that pass' do
        before do
          User.prepare_versioned_options(:if => [:true])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count + 1 }
      end

      context 'that fail' do
        before do
          User.prepare_versioned_options(:if => [:false])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count }
      end
    end

    context 'with :unless conditions' do
      context 'that pass' do
        before do
          User.prepare_versioned_options(:unless => [:true])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count }
      end

      context 'that fail' do
        before do
          User.prepare_versioned_options(:unless => [:false])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count + 1 }
      end
    end

    context 'with :if and :unless conditions' do
      context 'that pass' do
        before do
          User.prepare_versioned_options(:if => [:true], :unless => [:true])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count }
      end

      context 'that fail' do
        before do
          User.prepare_versioned_options(:if => [:false], :unless => [:false])
          subject.update_attribute(:last_name, 'Jobs')
        end

        its('versions.count'){ should == count }
      end
    end

  end
end
