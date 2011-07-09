require 'spec_helper'

describe VestalVersions::Changes do
  context "a version's changes" do
    let(:user){ User.create(:name => 'Steve Richert') }
    subject{ user.versions.last.changes }

    before do
      user.update_attribute(:last_name, 'Jobs')
    end

    it { should be_a(Hash) }
    it { should_not be_empty }

    it 'has string keys' do
      subject.keys.each{ |key| key.should be_a(String) }
    end

    it 'has two-element array values' do
      subject.values.each do |key|
        key.should be_a(Array)
        key.size.should == 2
      end
    end

    it 'has unique-element values' do
      subject.values.each{ |v| v.uniq.should == v }
    end

    it "equals the model's changes" do
      user.first_name = 'Stephen'
      model_changes = user.changes
      user.save
      changes = user.versions.last.changes

      model_changes.should == changes
    end
  end

  context 'a hash of changes' do
    let(:changes){ {'first_name' => ['Steve', 'Stephen']} }
    let(:other){ {'first_name' => ['Catie', 'Catherine']} }

    it 'properly appends other changes' do
      expected = {'first_name' => ['Steve', 'Catherine']}

      changes.append_changes(other).should == expected

      changes.append_changes!(other)
      changes.should == expected
    end

    it 'properly prepends other changes' do
      expected = {'first_name' => ['Catie', 'Stephen']}

      changes.prepend_changes(other).should == expected

      changes.prepend_changes!(other)
      changes.should == expected
    end

    it 'is reversible' do
      expected = {'first_name' => ['Stephen', 'Steve']}

      changes.reverse_changes.should == expected

      changes.reverse_changes!
      changes.should == expected
    end
  end

  context 'the changes between two versions' do
    let(:name){ 'Steve Richert' }
    let(:user){ User.create(:name => name) }          # 1
    let(:version){ user.version }

    before do
      user.update_attribute(:last_name, 'Jobs')       # 2
      user.update_attribute(:first_name, 'Stephen')   # 3
      user.update_attribute(:last_name, 'Richert')    # 4
      user.update_attribute(:name, name)              # 5
    end

    it 'is a hash' do
      1.upto(version) do |i|
        1.upto(version) do |j|
          user.changes_between(i, j).should be_a(Hash)
        end
      end
    end

    it 'has string keys' do
      1.upto(version) do |i|
        1.upto(version) do |j|
          user.changes_between(i, j).keys.each{ |key| key.should be_a(String) }
        end
      end
    end

    it 'has two-element arrays with unique values' do
      1.upto(version) do |i|
        1.upto(version) do |j|
          user.changes_between(i, j).values.each do |value|
            value.should be_a(Array)
            value.size.should == 2
            value.uniq.should == value
          end
        end
      end
    end

    it 'is empty between identical versions' do
      user.changes_between(1, version).should be_empty
      user.changes_between(version, 1).should be_empty
    end

    it 'is should reverse with direction' do
      1.upto(version) do |i|
        i.upto(version) do |j|
          up    = user.changes_between(i, j)
          down  = user.changes_between(j, i)
          up.should == down.reverse_changes
        end
      end
    end

    it 'is empty with invalid arguments' do
      1.upto(version) do |i|
        user.changes_between(i, nil).should be_blank
        user.changes_between(nil, i).should be_blank
      end
    end
  end
end
