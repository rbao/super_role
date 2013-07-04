require 'spec_helper'

describe SuperRole::Permission do
  describe '#==' do
    subject { permission1 == permission2 }
    let(:permission1) { Permission.new(action: 'create', resource_type: 'Project') }
    let(:permission2) { Permission.new(action: 'create', resource_type: 'Project') }

    it 'should return true iff the other permission have the same action and resource_type' do
      should be_true
    end

    it 'should be consider included in an array which have a permission with the same action and resource_type' do
      [permission1].should include(permission2)
    end
  end

  describe 'eql?' do
    subject { permission1.eql? permission2 }
    let(:permission1) { Permission.new(action: 'create', resource_type: 'Project') }
    let(:permission2) { Permission.new(action: 'create', resource_type: 'Project') }

    it 'should return true iff the other permission have the same action and resource_type' do
      should be_true
    end

    it 'should make array subtraction work' do
      ([permission1] - [permission2]).should eq []
    end
  end
end