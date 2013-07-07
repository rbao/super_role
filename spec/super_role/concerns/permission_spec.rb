require 'spec_helper'

describe SuperRole::Permission do
  describe '#==' do
    subject { permission1 == permission2 }
    let(:permission1) { Permission.new(action: 'create', resource_type: 'Project') }
    let(:permission2) { Permission.new(action: 'create', resource_type: 'Project') }

    context 'when the other permission have the same action and resource_type' do
      it { should be_true }
    end

    context 'when the other permission have the same action and resource_type is in an array' do
      it('should be considered included in that array') { [permission1].should include(permission2) }
    end
  end

  describe 'eql?' do
    subject { permission1.eql? permission2 }
    let(:permission1) { Permission.new(action: 'create', resource_type: 'Project') }
    let(:permission2) { Permission.new(action: 'create', resource_type: 'Project') }

    context 'when the other permission have the same action and resource_type' do
      it { should be_true }
    end

    context 'when subtracting two array where each of the array have a permission with the same action and resource_type' do
      it { ([permission1] - [permission2]).should eq [] }
    end
  end
end