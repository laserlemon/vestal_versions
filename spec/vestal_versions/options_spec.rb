require 'spec_helper'

describe VestalVersions::Options do
  context 'with explicit configuration' do
    let(:options){ {:dependent => :destroy} }
    let(:prepared_options){ User.prepare_versioned_options(options.dup) }

    before do
      VestalVersions::Version.config.clear
      VestalVersions::Version.config.class_name = 'MyCustomVersion'
    end

    it 'has symbolized keys' do
      User.vestal_versions_options.keys.all?{|k| k.is_a?(Symbol) }
    end

    it 'combines class-level and global configuration options' do
      prepared_options.slice(:dependent, :class_name).should == {
        :dependent  => :destroy,
        :class_name => 'MyCustomVersion'
      }
    end

  end

  context 'default configuration options' do
    subject { User.prepare_versioned_options({}) }

    it 'defaults to "VestalVersions::Version" for :class_name' do
      subject[:class_name].should == 'VestalVersions::Version'
    end

    it 'defaults to :delete_all for :dependent' do
      subject[:dependent].should == :delete_all
    end

    it 'forces the :as option value to :versioned' do
      subject[:as].should == :versioned
    end

    it 'defaults to [VestalVersions::Versions] for :extend' do
      subject[:extend].should == [VestalVersions::Versions]
    end
  end
end
