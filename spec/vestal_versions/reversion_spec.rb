require 'spec_helper'

describe VestalVersions::Reversion do
  subject{ User.new }
  let(:attributes){ {} }
  let(:first_version){ attributes.keys.min }
  let(:last_version){ attributes.keys.max }
  let(:times){ {} }
  let(:names){
    ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
  }

  before do
    time = names.size.hours.ago

    names.each do |name|
      subject.update_attribute(:name, name)
      attributes[subject.version] = subject.attributes
      time += 1.hour

      subject.versions.last.try(:update_attribute, :created_at, time)

      times[subject.version] = time
    end
  end

  it 'returns the new version number' do
    subject.revert_to(first_version).should == first_version
  end

  it 'changes the version number when saved' do
    expect{ subject.revert_to! first_version }.to change{ subject.version }
  end

  it 'does nothing for a invalid argument' do
    [nil, :bogus, 'bogus', (1..2)].each do |invalid|
      expect{ subject.revert_to(invalid) }.to_not change{ subject.version }
    end
  end

  it 'is able to target a version number' do
    subject.revert_to(1)
    subject.version.should == 1
  end

  it 'is able to target a date and time' do
    times.each do |version, time|
      subject.revert_to(time + 1.second)
      subject.version.should == version
    end
  end

  it 'is able to target a version object' do
    subject.versions.each do |version|
      subject.revert_to(version)
      subject.version.should == version.number
    end
  end

  it "correctly rolls back the model's attributes" do
    except = %w(created_at created_on updated_at updated_on)

    attributes.each do |version, attributes|
      subject.revert_to!(version)
      subject.attributes.except(*except).should == attributes.except(*except)
    end
  end

  it "stores the reverted_from pointing to the previous version" do
    subject.revert_to!(1)
    subject.versions.last.reverted_from.should == 1
  end

  it "does not store the reverted_from for subsequent saves" do
    subject.revert_to!(1)
    subject.update_attributes(:name => 'Bill Gates')
    subject.versions.last.reverted_from.should be_nil
  end

  it "stores the reverted_from pointing to the version it was reverted from when save is called later" do
    subject.revert_to(1)
    subject.name = "Reverted"
    subject.save
    subject.versions.last.reverted_from.should == 1
  end

  it "does not store the reverted_from for subsequent saves when the revert_to-save is called later" do
    subject.revert_to(1)
    subject.name = "Reverted"
    subject.save
    subject.update_attributes(:name => 'Bill Gates')
    subject.versions.last.reverted_from.should be_nil
  end

  it "clears the reverted_from if the model is reloaded after a revert_to without a save" do
    subject.revert_to(1)
    subject.reload
    subject.update_attributes(:name => 'Bill Gates')

    subject.versions.last.reverted_from.should be_nil
  end

end
