require 'spec_helper'

describe VestalVersions::Versions do
  subject{ User.new }
  let(:times){ {} }
  let(:names){
    ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
  }

  before do
    time = names.size.hours.ago

    names.each do |name|
      subject.update_attribute(:name, name)
      subject.tag_version(subject.version.to_s)
      time += 1.hour

      subject.versions.last.update_attribute(:created_at, time)
      times[subject.version] = time
    end
  end

  it 'is searchable between two valid version values' do
    times.keys.each do |number|
      times.values.each do |time|
        subject.versions.between(number, number).should be_a(Array)
        subject.versions.between(number, time).should be_a(Array)
        subject.versions.between(time, number).should be_a(Array)
        subject.versions.between(time, time).should be_a(Array)
        subject.versions.between(number, number).should_not be_empty
        subject.versions.between(number, time).should_not be_empty
        subject.versions.between(time, number).should_not be_empty
        subject.versions.between(time, time).should_not be_empty
      end
    end
  end

  it 'returns an empty array when searching between a valid and an invalid version value' do
    times.each do |number, time|
      subject.versions.between(number, nil).should == []
      subject.versions.between(time, nil).should == []
      subject.versions.between(nil, number).should == []
      subject.versions.between(nil, time).should == []
    end
  end

  it 'returns an empty array when searching between two invalid version values' do
    subject.versions.between(nil, nil).should == []
  end

  it 'is searchable before a valid version value' do
    times.sort.each_with_index do |(number, time), i|
      subject.versions.before(number).size.should == i
      subject.versions.before(time).size.should == i
    end
  end

  it 'returns an empty array when searching before an invalid version value' do
    subject.versions.before(nil).should == []
  end

  it 'is searchable after a valid version value' do
    times.sort.reverse.each_with_index do |(number, time), i|
      subject.versions.after(number).size.should == i
      subject.versions.after(time).size.should == i
    end
  end

  it 'returns an empty array when searching after an invalid version value' do
    subject.versions.after(nil).should == []
  end

  it 'is fetchable by version number' do
    times.keys.each do |number|
      subject.versions.at(number).should be_a(VestalVersions::Version)
      subject.versions.at(number).number.should == number
    end
  end

  it 'is fetchable by tag' do
    times.keys.map{|n| [n, n.to_s] }.each do |number, tag|
      subject.versions.at(tag).should be_a(VestalVersions::Version)
      subject.versions.at(tag).number.should == number
    end
  end

  it "is fetchable by the exact time of a version's creation" do
    times.each do |number, time|
      subject.versions.at(time).should be_a(VestalVersions::Version)
      subject.versions.at(time).number.should == number
    end
  end

  it "is fetchable by any time after the model's creation" do
    times.each do |number, time|
      subject.versions.at(time + 30.minutes).should be_a(VestalVersions::Version)
      subject.versions.at(time + 30.minutes).number.should == number
    end
  end

  it "returns nil when fetching a time before the model's creation" do
    creation = times.values.min
    subject.versions.at(creation - 1.second).should be_nil
  end

  it 'is fetchable by an association extension method' do
    subject.versions.at(:first).should be_a(VestalVersions::Version)
    subject.versions.at(:last).should be_a(VestalVersions::Version)
    subject.versions.at(:first).number.should == times.keys.min
    subject.versions.at(:last).number.should == times.keys.max
  end

  it 'is fetchable by a version object' do
    times.keys.each do |number|
      version = subject.versions.at(number)

      subject.versions.at(version).should be_a(VestalVersions::Version)
      subject.versions.at(version).number.should == number
    end
  end

  it 'returns nil when fetching an invalid version value' do
    subject.versions.at(nil).should be_nil
  end

  it 'provides a version number for any given numeric version value' do
    times.keys.each do |number|
      subject.versions.number_at(number).should be_a(Integer)
      subject.versions.number_at(number + 0.5).should be_a(Integer)
      subject.versions.number_at(number).should == subject.versions.number_at(number + 0.5)
    end
  end

  it 'provides a version number for a valid tag' do
    times.keys.map{|n| [n, n.to_s] }.each do |number, tag|
      subject.versions.number_at(tag).should be_a(Integer)
      subject.versions.number_at(tag).should == number
    end
  end

  it 'returns nil when providing a version number for an invalid tag' do
    subject.versions.number_at('INVALID').should be_nil
  end

  it 'provides a version number of a version corresponding to an association extension method' do
    subject.versions.at(:first).should be_a(VestalVersions::Version)
    subject.versions.at(:last).should be_a(VestalVersions::Version)
    subject.versions.number_at(:first).should == times.keys.min
    subject.versions.number_at(:last).should == times.keys.max
  end

  it 'returns nil when providing a version number for an invalid association extension method' do
    subject.versions.number_at(:INVALID).should be_nil
  end

  it "provides a version number for any time after the model's creation" do
    times.each do |number, time|
      subject.versions.number_at(time + 30.minutes).should be_a(Integer)
      subject.versions.number_at(time + 30.minutes).should == number
    end
  end

  it "provides a version number of 1 for a time before the model's creation" do
    creation = times.values.min
    subject.versions.number_at(creation - 1.second).should == 1
  end

  it 'provides a version number for a given version object' do
    times.keys.each do |number|
      version = subject.versions.at(number)

      subject.versions.number_at(version).should == number
    end
  end

end
