require 'spec_helper'

describe VestalVersions::Plugins do
  context 'when a plugin is requested' do
    before do
      User.prepare_versioned_options(:plugins => 'MyCustomPlugin')
    end

    it 'stores plugins the options hash' do
      User.vestal_versions_options[:plugins].should == [MyCustomPlugin]
    end

    it 'converts strings to modules' do
      User.vestal_versions_options[:plugins].all?{|p| p.is_a?(Module)}
    end

    it 'modifies versioned models if requested' do
      User.should respond_to(:plugged_in_model)
    end

    it 'modifies Version if requested' do
      VestalVersions::Version.should respond_to(:plugged_in_version)
    end
  end
end
