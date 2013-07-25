require 'spec_helper'

describe SuperRole::ResourcePermission do

  describe '.related_to' do
    subject { ResourcePermission.related_to(actions, resource) }
    
    before do
      ResourcePermission.any_instance.stub(:valid?).and_return(true)
    end
    
    let(:organization) { Organization.create! }
    let(:project) { Project.create!(owner: organization) }
    let(:update) { Permission.create!(action: 'update', resource_type: 'Project') }
    let!(:resource_permission1) { ResourcePermission.create!(permission: update, resource_id: project.id) }
    let!(:resource_permission2) { ResourcePermission.create!(permission: update, reference: organization) }
 
    let(:actions) { :update }
    let(:resource) { project }

    it 'should include the resource permission that have the corresponding permission and
      resource_id matches the given resource, or resource_id is nil' do
      should match_array [resource_permission1, resource_permission2]
    end
  end

  describe '#include_resource?' do
    subject { resource_permission.include_resource?(resource) }
    
    context 'when the resource is persisted and resource.id matches resource_permission.resource_id' do
      let(:resource_permission) { ResourcePermission.new(resource_id: 1) }
      let(:resource) { double(:persisted? => true) }

      before do
        expect(resource).to receive(:id).and_return(1)
      end

      it { should be_true }
    end

    context 'when the resource is persisted and its id does not match resource_permission.resource_id' do
      let(:hierarchy) { double('hierarchy') }
      let(:resource) { double(:persisted? => true, :id => 1) }
      let(:reference) { double('reference') }
      let(:permission) { double('permission') }
      let(:resource_permission) { ResourcePermission.new }
      
      before do
        resource_permission.stub(:reference => reference)
        resource_permission.stub(:permission => permission)
      end

      context 'and there is no corresponding hierarchy for the resource_permission' do
        before { resource_permission.stub(:permission_hierarchy => nil) }
        it { should be_false }
      end

      context 'and hierarchy.ancestor_resource? returns true' do
        before do
          resource_permission.stub(:permission_hierarchy => hierarchy)
          hierarchy.should_receive(:ancestor_resource?).with(resource, reference, permission).and_return(true)
        end

        it { should be_true }
      end

      context 'and hierarchy.ancestor_resource? returns false' do
        before do
          resource_permission.stub(:permission_hierarchy => hierarchy)
          hierarchy.should_receive(:ancestor_resource?).with(resource, reference, permission).and_return(false)
        end

        it { should be_false }
      end
    end

    context 'when the resource is not persisted' do
      let(:hierarchy) { double('hierarchy') }
      let(:resource) { double(:persisted? => false) }
      let(:reference) { double('reference') }
      let(:permission) { double('permission') }
      let(:resource_permission) { ResourcePermission.new }

      before do
        resource_permission.stub(:reference => reference)
        resource_permission.stub(:permission => permission)
      end

      context 'and there is no corresponding hierarchy for the resource_permission' do
        before { resource_permission.stub(:permission_hierarchy => nil) }
        it { should be_false }
      end

      context 'and hierarchy.ancestor_resource? returns true' do
        before do
          resource_permission.stub(:permission_hierarchy => hierarchy)
          hierarchy.should_receive(:ancestor_resource?).with(resource, reference, permission).and_return(true)
        end

        it { should be_true }
      end

      context 'and hierarchy.ancestor_resource? returns false' do
        before do
          resource_permission.stub(:permission_hierarchy => hierarchy)
          hierarchy.should_receive(:ancestor_resource?).with(resource, reference, permission).and_return(false)
        end

        it { should be_false }
      end
    end
  end
  
end