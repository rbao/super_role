require 'spec_helper'

describe SuperRole::PermissionHierarchy do

  describe '.create' do
   subject { SuperRole::PermissionHierarchy.create(resource_type, options) } 
   let(:hierarchy) { double('hierarchy') }
   let(:resource_type) { 'Organization' }
   let(:options) { { a: 1 } }

   it 'should return a new instance of SuperRole::PermissionHierarchy' do
    expect(SuperRole::PermissionHierarchy).to receive(:new).with(resource_type, options).and_return(hierarchy)
    expect { subject }.to change { SuperRole::PermissionHierarchy.count }.by 1
    should eq hierarchy
   end
  end
  
end