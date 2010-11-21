require 'spec_helper'

describe VestalVersions::Versioned do
  it 'respond to the "versioned?" method' do
    ActiveRecord::Base.should respond_to(:versioned?)
    User.should respond_to(:versioned?)
  end

  it 'return true for the "versioned?" method if the model is versioned' do
    User.should be_versioned
  end

  it 'return false for the "versioned?" method if the model is not versioned' do
    ActiveRecord::Base.should_not be_versioned
  end
end
