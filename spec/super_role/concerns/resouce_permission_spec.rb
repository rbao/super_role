require 'spec_helper'

describe SuperRole::ResourcePermission do
  describe '.related_to' do
    subject { ResourcePermission.related_to(actions, resource) }
    
    before do
      create_permissions_for(Organization, Project)
      SuperRole::PermissionHierarchy.create(nil)
      ResourcePermission.any_instance.stub(:permission_valid_for_role).and_return(true)
    end
    setup_resources

    let(:role) { Role.create! }
    let(:create_project_permission) { Permission.find_by(action: 'create', resource_type: 'Project') }
    let!(:resource_permission1) { ResourcePermission.create!(role: role, permission: create_project_permission, resource_id: project1.id) }
    let!(:resource_permission2) { ResourcePermission.create!(role: role, permission: create_project_permission, reference: organization1) }
 
    let(:actions) { :create }
    let(:resource) { project1 }

    it 'should include the resource permission that have the corresponding permission and
      resource_id matches the given resource, or resource_id is nil' do
      should match_array [resource_permission1, resource_permission2]
    end
  end

  describe '#include_resource?' do
    subject { resource_permission.include_resource?(resource) }
    
    before do
      create_permissions_for(Organization, Project, ProjectProfile, Ticket, Employee, EmployeeStatus, EmployeeProfile)
      SuperRole::PermissionHierarchy.create(nil)
      ResourcePermission.any_instance.stub(:permission_valid_for_role).and_return(true)
    end
    setup_resources

    let(:role) { Role.create! }
    let(:update_project_permission) { Permission.find_by(action: 'update', resource_type: 'Project') }
    
    context 'when resource.id matches resource_permission.resource_id' do
      let(:resource_permission) { ResourcePermission.create!(role: role, permission: update_project_permission, resource_id: project1.id) }
      let(:resource) { project1 }
      it { should be_true }
    end

    context 'when resource_permission.resource_id is nil and resource eventually belongs_to the reference' do
      let(:hierarchy) { double('hierarchy') }
      let(:resource_permission) { ResourcePermission.create!(role: role, permission: update_project_permission, reference: organization1) }
      let(:resource) { project1 }
      before do
        resource_permission.stub(:permission_hierarchy => hierarchy)
        hierarchy.should_receive(:ancestor_resource?).and_return(true)
      end
      it { should be_true }
    end

    context 'when resource_permission.resource_id is nil and resource does not eventually belongs_to the reference' do
      let(:hierarchy) { double('hierarchy') }
      let(:resource_permission) { ResourcePermission.create!(role: role, permission: update_project_permission, reference: organization1) }
      let(:resource) { project1 }
      before do
        resource_permission.stub(:permission_hierarchy => hierarchy)
        hierarchy.should_receive(:ancestor_resource?).and_return(false)
      end
      it { should be_false }
    end

    context 'when resource_permission.resource_id is nil and resource.id is also nil' do
      let(:hierarchy) { double('hierarchy') }
      let(:resource_permission) { ResourcePermission.create!(role: role, permission: update_project_permission, reference: organization1) }
      let(:resource) { Project.new(owner: organization1) }
      before do
        resource_permission.stub(:permission_hierarchy => hierarchy)
        hierarchy.should_receive(:ancestor_resource?).and_return(true)
      end
      it { should be_true }
    end
  end
end